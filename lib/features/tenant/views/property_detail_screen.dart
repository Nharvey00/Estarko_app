import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/skeleton_loader.dart';
import '../../auth/providers/auth_provider.dart';
import '../../inquiries/services/inquiry_service.dart';
import '../../favorites/providers/favorite_provider.dart';
import '../../listings/models/listing_model.dart';

class PropertyDetailScreen extends StatefulWidget {
  final ListingModel listing;
  final InquiryService? inquiryService;

  const PropertyDetailScreen({
    super.key,
    required this.listing,
    this.inquiryService,
  });

  @override
  State<PropertyDetailScreen> createState() => _PropertyDetailScreenState();
}

class _PropertyDetailScreenState extends State<PropertyDetailScreen> {
  final PageController _pageController = PageController();
  final TextEditingController _noteController = TextEditingController();
  int _currentPage = 0;

  late final InquiryService _inquiryService;
  bool _hasInquired = false;
  bool _isCheckingStatus = true;
  bool _isSubmitting = false;
  DateTime? _selectedViewingDate;

  @override
  void initState() {
    super.initState();
    _inquiryService = widget.inquiryService ?? InquiryService();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkInquiryStatus();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  String _getTenantId() {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.currentUser != null &&
          authProvider.currentUser!.uid.isNotEmpty) {
        return authProvider.currentUser!.uid;
      }
    } catch (_) {}
    return FirebaseAuth.instance.currentUser?.uid ?? '';
  }

  String _getTenantName() {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.currentUser != null &&
          authProvider.currentUser!.name.isNotEmpty) {
        return authProvider.currentUser!.name;
      }
    } catch (_) {}
    return FirebaseAuth.instance.currentUser?.displayName ?? 'Tenant';
  }

  String? _getTenantEmail() {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.currentUser != null &&
          authProvider.currentUser!.email.isNotEmpty) {
        return authProvider.currentUser!.email;
      }
    } catch (_) {}
    return FirebaseAuth.instance.currentUser?.email;
  }

  Future<void> _pickViewingDateTime() async {
    final now = DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 60)),
    );
    if (pickedDate == null || !mounted) return;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 10, minute: 0),
    );
    if (pickedTime == null || !mounted) return;

    setState(() {
      _selectedViewingDate = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime.hour,
        pickedTime.minute,
      );
    });
  }

  String _formatSchedule(DateTime dt) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final hour = dt.hour == 0 ? 12 : (dt.hour > 12 ? dt.hour - 12 : dt.hour);
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year} at $hour:$minute $period';
  }

  Future<void> _checkInquiryStatus() async {
    final tenantId = _getTenantId();
    if (tenantId.isEmpty) {
      if (mounted) {
        setState(() {
          _isCheckingStatus = false;
        });
      }
      return;
    }

    try {
      final alreadyInquired = await _inquiryService.hasInquired(
        tenantId,
        widget.listing.id,
      );
      if (mounted) {
        setState(() {
          _hasInquired = alreadyInquired;
          _isCheckingStatus = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isCheckingStatus = false;
        });
      }
    }
  }

  Future<void> _handleRequestViewing() async {
    final tenantId = _getTenantId();
    final tenantName = _getTenantName();
    final tenantEmail = _getTenantEmail();

    if (tenantId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please log in to request a viewing.'),
          backgroundColor: Color(0xFFE11D48),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final canInquire = await _inquiryService.checkDailyLimit(tenantId);
      if (!canInquire) {
        if (mounted) {
          setState(() {
            _isSubmitting = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Daily limit reached. Please try again tomorrow.'),
              backgroundColor: Color(0xFFE11D48),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        return;
      }

      await _inquiryService.createInquiry(
        propertyId: widget.listing.id,
        propertyTitle: widget.listing.title,
        tenantId: tenantId,
        tenantName: tenantName,
        tenantEmail: tenantEmail,
        sellerId: widget.listing.sellerId,
        scheduledDate: _selectedViewingDate,
        note: _noteController.text.trim().isNotEmpty
            ? _noteController.text.trim()
            : null,
      );

      if (mounted) {
        setState(() {
          _hasInquired = true;
          _isSubmitting = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Viewing requested successfully!'),
            backgroundColor: Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to request viewing: $e'),
            backgroundColor: const Color(0xFFE11D48),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Widget _buildImageGallery(double height) {
    final images = widget.listing.imageUrls;

    if (images.isEmpty) {
      return Container(
        height: height,
        color: Colors.grey.shade100,
        child: Center(
          child: Icon(
            Icons.holiday_village_outlined,
            size: 64.0,
            color: Colors.grey.shade400,
          ),
        ),
      );
    }

    if (images.length == 1) {
      return SizedBox(
        height: height,
        width: double.infinity,
        child: CachedNetworkImage(
          imageUrl: images.first,
          fit: BoxFit.cover,
          placeholder: (context, url) => EstarSkeleton(
            height: height,
            width: double.infinity,
          ),
          errorWidget: (context, url, error) => Container(
            color: Colors.grey.shade100,
            child: Icon(
              Icons.broken_image_outlined,
              size: 48.0,
              color: Colors.grey.shade400,
            ),
          ),
        ),
      );
    }

    return Stack(
      children: [
        PageView.builder(
          controller: _pageController,
          itemCount: images.length,
          onPageChanged: (index) {
            setState(() {
              _currentPage = index;
            });
          },
          itemBuilder: (context, index) {
            return CachedNetworkImage(
              imageUrl: images[index],
              fit: BoxFit.cover,
              placeholder: (context, url) => EstarSkeleton(
                height: height,
                width: double.infinity,
              ),
              errorWidget: (context, url, error) => Container(
                color: Colors.grey.shade100,
                child: Icon(
                  Icons.broken_image_outlined,
                  size: 48.0,
                  color: Colors.grey.shade400,
                ),
              ),
            );
          },
        ),
        // Dots indicator
        Positioned(
          bottom: 24.0,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(images.length, (index) {
              final isSelected = index == _currentPage;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 4.0),
                width: isSelected ? 20.0 : 8.0,
                height: 8.0,
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFFE11D48)
                      : Colors.white.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(4.0),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final galleryHeight = screenHeight * 0.40;

    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Color(0x1A000000),
                  blurRadius: 10.0,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Color(0xFF111827),
                size: 20.0,
              ),
              onPressed: () => Navigator.maybePop(context),
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Color(0x1A000000),
                    blurRadius: 10.0,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Consumer<FavoriteProvider>(
                builder: (context, favoriteProvider, _) {
                  final isFav = favoriteProvider.isFavorite(widget.listing.id);
                  return IconButton(
                    icon: Icon(
                      isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                      color: isFav
                          ? const Color(0xFFE11D48)
                          : Colors.grey.shade400,
                      size: 22.0,
                    ),
                    onPressed: () {
                      final userId = _getTenantId();
                      if (userId.isNotEmpty) {
                        favoriteProvider.toggleFavorite(userId, widget.listing);
                      }
                    },
                  );
                },
              ),
            ),
          ),
        ],
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (!_hasInquired) ...[
                // Viewing Date Picker Button
                InkWell(
                  onTap: _isSubmitting ? null : _pickViewingDateTime,
                  borderRadius: BorderRadius.circular(12.0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14.0,
                      vertical: 10.0,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12.0),
                      border: Border.all(
                        color: _selectedViewingDate != null
                            ? const Color(0xFFE11D48)
                            : const Color(0xFFE2E8F0),
                        width: _selectedViewingDate != null ? 1.5 : 1.0,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_month_rounded,
                          size: 20.0,
                          color: _selectedViewingDate != null
                              ? const Color(0xFFE11D48)
                              : const Color(0xFF64748B),
                        ),
                        const SizedBox(width: 10.0),
                        Expanded(
                          child: Text(
                            _selectedViewingDate != null
                                ? 'Scheduled: ${_formatSchedule(_selectedViewingDate!)}'
                                : 'Select viewing date & time (Optional)',
                            style: TextStyle(
                              fontSize: 13.0,
                              fontWeight: _selectedViewingDate != null
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                              color: _selectedViewingDate != null
                                  ? const Color(0xFF0F172A)
                                  : const Color(0xFF94A3B8),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (_selectedViewingDate != null)
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedViewingDate = null;
                              });
                            },
                            child: const Padding(
                              padding: EdgeInsets.only(left: 4.0),
                              child: Icon(
                                Icons.close_rounded,
                                size: 18.0,
                                color: Color(0xFF94A3B8),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8.0),
                // Optional Note TextField
                TextField(
                  controller: _noteController,
                  enabled: !_isSubmitting,
                  style: const TextStyle(
                    fontSize: 13.0,
                    color: Color(0xFF0F172A),
                  ),
                  decoration: InputDecoration(
                    hintText: 'Add an optional note for the host...',
                    hintStyle: const TextStyle(
                      fontSize: 13.0,
                      color: Color(0xFF94A3B8),
                    ),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14.0,
                      vertical: 10.0,
                    ),
                    fillColor: const Color(0xFFF8FAFC),
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: const BorderSide(
                        color: Color(0xFFE11D48),
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12.0),
              ],
              EstarButton(
                text: _hasInquired ? 'Viewing Requested' : 'Request Viewing',
                isLoading: _isSubmitting,
                onPressed: (_hasInquired || _isCheckingStatus || _isSubmitting)
                    ? null
                    : _handleRequestViewing,
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top 40% imagery with ShaderMask bottom-to-top gradient fade
            ShaderMask(
              shaderCallback: (rect) {
                return const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black,
                    Colors.black,
                    Colors.transparent,
                  ],
                  stops: [0.0, 0.70, 1.0],
                ).createShader(rect);
              },
              blendMode: BlendMode.dstIn,
              child: SizedBox(
                height: galleryHeight,
                width: double.infinity,
                child: _buildImageGallery(galleryHeight),
              ),
            ),

            // Property Details Content
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 8.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Massive Monthly Rate Typography
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '₱${widget.listing.monthlyRate.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 34.0,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -1.0,
                          color: Color(0xFFE11D48),
                        ),
                      ),
                      const SizedBox(width: 4.0),
                      Text(
                        ' /mo',
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10.0),

                  // Title
                  Text(
                    widget.listing.title,
                    style: const TextStyle(
                      fontSize: 22.0,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                      color: Color(0xFF111827),
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 10.0),

                  // Location
                  if (widget.listing.address.isNotEmpty)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 18.0,
                          color: Color(0xFFE11D48),
                        ),
                        const SizedBox(width: 6.0),
                        Expanded(
                          child: Text(
                            widget.listing.address,
                            style: TextStyle(
                              fontSize: 14.0,
                              color: Colors.grey.shade600,
                              height: 1.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 24.0),

                  const Divider(color: Color(0xFFF1F5F9), height: 1.0),
                  const SizedBox(height: 24.0),

                  // Description Section
                  const Text(
                    'About this home',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    widget.listing.description.isNotEmpty
                        ? widget.listing.description
                        : 'No description provided by the host.',
                    style: const TextStyle(
                      fontSize: 15.0,
                      color: Color(0xFF4B5563),
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 28.0),

                  // Amenities Section
                  if (widget.listing.amenities.isNotEmpty) ...[
                    const Text(
                      'Amenities & Features',
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 12.0),
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      children: widget.listing.amenities.map((amenity) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14.0,
                            vertical: 8.0,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(12.0),
                            border: Border.all(
                              color: const Color(0xFFE2E8F0),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.check_circle_outline_rounded,
                                size: 16.0,
                                color: Color(0xFFE11D48),
                              ),
                              const SizedBox(width: 6.0),
                              Text(
                                amenity,
                                style: const TextStyle(
                                  fontSize: 13.0,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF334155),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 32.0),
                  ],
                ]
                    .animate(interval: 100.ms)
                    .fade(duration: 400.ms)
                    .slideY(begin: 0.1, curve: Curves.easeOutQuad),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
