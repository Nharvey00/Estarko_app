import 'dart:io';
import 'dart:ui' as ui;
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart' hide Path;
import 'package:provider/provider.dart';
import '../../../core/services/cloudinary_service.dart';
import '../../../core/services/location_service.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../../auth/providers/auth_provider.dart';
import '../../monetization/views/mock_checkout_screen.dart';
import '../models/listing_model.dart';
import '../services/listing_service.dart';

class CreateListingScreen extends StatefulWidget {
  const CreateListingScreen({super.key});

  @override
  State<CreateListingScreen> createState() => _CreateListingScreenState();
}

class _CreateListingScreenState extends State<CreateListingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _rateController = TextEditingController();
  final _amenitiesController = TextEditingController();
  final _addressController = TextEditingController();

  final MapController _mapController = MapController();
  LatLng? _selectedLocation = const LatLng(7.0736, 125.6110);

  final List<File?> _selectedImages = [null, null, null];
  bool _isLoading = false;
  bool _isGeocoding = false;

  final LocationService _locationService = LocationService();
  final CloudinaryService _cloudinaryService = CloudinaryService();
  final ListingService _listingService = ListingService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkListingQuota();
    });
  }

  String _getSellerId() {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.currentUser != null &&
          authProvider.currentUser!.uid.isNotEmpty) {
        return authProvider.currentUser!.uid;
      }
    } catch (_) {}
    return FirebaseAuth.instance.currentUser?.uid ?? '';
  }

  Future<void> _checkListingQuota() async {
    final sellerId = _getSellerId();
    if (sellerId.isEmpty) return;

    try {
      final existingListings =
          await _listingService.getSellerListings(sellerId).first;
      final activeCount = existingListings.where((l) => l.isAvailable).length;

      if (activeCount >= 1 && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const MockCheckoutScreen(),
          ),
        );
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _rateController.dispose();
    _amenitiesController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(int index) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (image != null) {
        setState(() {
          _selectedImages[index] = File(image.path);
        });
      }
    } catch (e) {
      if (!mounted) return;
      _showError('Failed to pick image: $e');
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages[index] = null;
    });
  }

  Future<void> _locateAddressOnMap() async {
    final address = _addressController.text.trim();
    if (address.isEmpty) {
      _showError('Please enter an address to search.');
      return;
    }

    setState(() {
      _isGeocoding = true;
    });

    try {
      final coords = await _locationService.getCoordinatesFromAddress(address);
      if (coords != null) {
        final lat = coords['latitude'] ?? coords['lat'];
        final lon = coords['longitude'] ?? coords['lon'];
        if (lat != null && lon != null) {
          final newLocation = LatLng(lat, lon);
          setState(() {
            _selectedLocation = newLocation;
          });
          _mapController.move(newLocation, 15.0);
        }
      } else {
        _showError('Address not found on map. You can tap the map to place the pin.');
      }
    } catch (e) {
      _showError('Geocoding error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isGeocoding = false;
        });
      }
    }
  }

  Future<void> _handlePublish() async {
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();
    final rateText = _rateController.text.trim();
    final amenitiesText = _amenitiesController.text.trim();
    final address = _addressController.text.trim();

    if (title.isEmpty) {
      _showError('Please enter a property title.');
      return;
    }
    if (description.isEmpty) {
      _showError('Please enter a property description.');
      return;
    }
    if (rateText.isEmpty) {
      _showError('Please enter a monthly rate.');
      return;
    }
    final monthlyRate = double.tryParse(rateText);
    if (monthlyRate == null || monthlyRate <= 0) {
      _showError('Please enter a valid numeric monthly rate.');
      return;
    }
    if (address.isEmpty) {
      _showError('Please enter the property address.');
      return;
    }

    final hasAtLeastOneImage = _selectedImages.any((img) => img != null);
    if (!hasAtLeastOneImage) {
      _showError('Please upload at least 1 property photo.');
      return;
    }

    // Resolve Seller ID before async gaps (Fixes BUG-03: no hardcoded fallback)
    final sellerId = _getSellerId();
    if (sellerId.isEmpty) {
      _showError('Authentication error. Please log in again to publish.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // 1. Pass the final pinned coordinates (replacing hidden geocoding step)
      final latitude = _selectedLocation?.latitude ?? 7.0736;
      final longitude = _selectedLocation?.longitude ?? 125.6110;

      // 2. Upload images to Cloudinary
      final List<String> imageUrls = [];
      for (final imageFile in _selectedImages) {
        if (imageFile != null) {
          final url = await _cloudinaryService.uploadImage(imageFile);
          if (url != null && url.isNotEmpty) {
            imageUrls.add(url);
          }
        }
      }

      // 3. Parse amenities (comma separated)
      final List<String> amenities = amenitiesText.isNotEmpty
          ? amenitiesText
              .split(',')
              .map((a) => a.trim())
              .where((a) => a.isNotEmpty)
              .toList()
          : <String>[];

      // 4. Construct ListingModel with pinned coordinates & save
      final listing = ListingModel(
        id: '',
        sellerId: sellerId,
        title: title,
        description: description,
        monthlyRate: monthlyRate,
        address: address,
        latitude: latitude,
        longitude: longitude,
        imageUrls: imageUrls,
        amenities: amenities,
        isAvailable: true,
        createdAt: DateTime.now(),
      );

      await _listingService.createListing(listing);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Listing published successfully!'),
          backgroundColor: Color(0xFF111827),
          behavior: SnackBarBehavior.floating,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      _showError('Failed to publish listing: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFE11D48),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget _buildDropzone(int index) {
    final imageFile = _selectedImages[index];

    return SizedBox(
      width: 104.0,
      height: 104.0,
      child: GestureDetector(
        onTap: () => _pickImage(index),
        child: imageFile != null
            ? Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16.0),
                    child: Image.file(
                      imageFile,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 6.0,
                    right: 6.0,
                    child: GestureDetector(
                      onTap: () => _removeImage(index),
                      child: Container(
                        padding: const EdgeInsets.all(4.0),
                        decoration: const BoxDecoration(
                          color: Color(0xBF111827),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          size: 14.0,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : CustomPaint(
                painter: DashedBorderPainter(
                  color: const Color(0xFFCBD5E1),
                  strokeWidth: 2.0,
                  dashWidth: 8.0,
                  dashSpace: 6.0,
                  radius: 16.0,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.add_photo_alternate_outlined,
                        color: Color(0xFFE11D48),
                        size: 28.0,
                      ),
                      const SizedBox(height: 6.0),
                      Text(
                        'Photo ${index + 1}',
                        style: TextStyle(
                          fontSize: 12.0,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        scrolledUnderElevation: 0,
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Color(0xFF111827),
            size: 20.0,
          ),
          onPressed: () => Navigator.maybePop(context),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(24.0, 12.0, 24.0, 24.0),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 20.0,
              offset: Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: EstarButton(
            text: 'Publish Listing',
            isLoading: _isLoading,
            onPressed: _isLoading ? null : _handlePublish,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Massive Header
                const Text(
                  'Create Listing',
                  style: TextStyle(
                    fontSize: 36.0,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1.0,
                    color: Color(0xFF111827),
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 8.0),

                // Muted Subtitle
                Text(
                  'Add property details, rental pricing, and high-quality photos.',
                  style: TextStyle(
                    fontSize: 15.0,
                    color: Colors.grey.shade500,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 28.0),

                // Image Upload Label
                const Text(
                  'Property Photos (Up to 3)',
                  style: TextStyle(
                    fontSize: 13.0,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 10.0),

                // Horizontal scrollable row of 3 square dropzones
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List.generate(3, (index) {
                      return Padding(
                        padding: EdgeInsets.only(right: index < 2 ? 14.0 : 0.0),
                        child: _buildDropzone(index),
                      );
                    }),
                  ),
                ),
                const SizedBox(height: 24.0),

                // Title Input
                const Text(
                  'Property Title',
                  style: TextStyle(
                    fontSize: 13.0,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 8.0),
                EstarTextField(
                  controller: _titleController,
                  hintText: 'e.g. Modern Studio near University',
                ),
                const SizedBox(height: 20.0),

                // Description Input
                const Text(
                  'Description',
                  style: TextStyle(
                    fontSize: 13.0,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 8.0),
                EstarTextField(
                  controller: _descriptionController,
                  hintText:
                      'Describe property features, house rules, nearby transit...',
                ),
                const SizedBox(height: 20.0),

                // Monthly Rate Input
                const Text(
                  'Monthly Rate (₱)',
                  style: TextStyle(
                    fontSize: 13.0,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 8.0),
                EstarTextField(
                  controller: _rateController,
                  hintText: 'e.g. 15000',
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 20.0),

                // Amenities Input
                const Text(
                  'Amenities (comma separated)',
                  style: TextStyle(
                    fontSize: 13.0,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 8.0),
                EstarTextField(
                  controller: _amenitiesController,
                  hintText: 'e.g. WiFi, Air Conditioning, Kitchen, Gym',
                ),
                const SizedBox(height: 20.0),

                // Address Input with Auto-Locate Search Button
                const Text(
                  'Address',
                  style: TextStyle(
                    fontSize: 13.0,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 8.0),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: EstarTextField(
                        controller: _addressController,
                        hintText: 'e.g. 2401 Taft Ave, Malate, Manila',
                      ),
                    ),
                    const SizedBox(width: 10.0),
                    Container(
                      height: 52.0,
                      width: 52.0,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE11D48),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: IconButton(
                        icon: _isGeocoding
                            ? const SizedBox(
                                width: 20.0,
                                height: 20.0,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.0,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : const Icon(
                                Icons.search,
                                color: Colors.white,
                                size: 24.0,
                              ),
                        tooltip: 'Search & Locate',
                        onPressed: _isGeocoding ? null : _locateAddressOnMap,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),

                // Interactive Map Container
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Pin Location on Map',
                      style: TextStyle(
                        fontSize: 13.0,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    Text(
                      'Tap to place or move pin',
                      style: TextStyle(
                        fontSize: 12.0,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8.0),
                Container(
                  height: 250.0,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16.0),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x0A000000),
                        blurRadius: 20.0,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter:
                          _selectedLocation ?? const LatLng(7.0736, 125.6110),
                      initialZoom: 15.0,
                      onTap: (tapPosition, point) {
                        setState(() {
                          _selectedLocation = point;
                        });
                      },
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.example.estarko',
                      ),
                      if (_selectedLocation != null)
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: _selectedLocation!,
                              width: 44.0,
                              height: 44.0,
                              child: const Icon(
                                Icons.location_on,
                                color: Color(0xFFE11D48),
                                size: 44.0,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 32.0),
              ]
                  .animate(interval: 100.ms)
                  .fade(duration: 400.ms)
                  .slideY(begin: 0.1, curve: Curves.easeOutQuad),
            ),
          ),
        ),
      ),
    );
  }
}

class DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double dashWidth;
  final double dashSpace;
  final double radius;

  DashedBorderPainter({
    required this.color,
    this.strokeWidth = 2.0,
    this.dashWidth = 8.0,
    this.dashSpace = 6.0,
    this.radius = 16.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final RRect rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        strokeWidth / 2,
        strokeWidth / 2,
        size.width - strokeWidth,
        size.height - strokeWidth,
      ),
      Radius.circular(radius),
    );

    final Path path = Path()..addRRect(rrect);
    final Path dashedPath = Path();

    for (final ui.PathMetric metric in path.computeMetrics()) {
      double distance = 0.0;
      while (distance < metric.length) {
        final double length = (distance + dashWidth < metric.length)
            ? dashWidth
            : metric.length - distance;
        dashedPath.addPath(
          metric.extractPath(distance, distance + length),
          Offset.zero,
        );
        distance += dashWidth + dashSpace;
      }
    }

    canvas.drawPath(dashedPath, paint);
  }

  @override
  bool shouldRepaint(covariant DashedBorderPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.dashWidth != dashWidth ||
        oldDelegate.dashSpace != dashSpace ||
        oldDelegate.radius != radius;
  }
}
