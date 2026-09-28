import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/services/cloudinary_service.dart';
import '../../../core/services/location_service.dart';
import '../models/listing_model.dart';
import '../services/listing_service.dart';

class ListingProvider extends ChangeNotifier {
  final ListingService _listingService;
  final LocationService _locationService;
  final CloudinaryService _cloudinaryService;
  final ImagePicker _imagePicker;

  bool _isLoading = false;
  String? _errorMessage;
  final List<File?> _selectedImages = [null, null, null];

  ListingProvider({
    ListingService? listingService,
    LocationService? locationService,
    CloudinaryService? cloudinaryService,
    ImagePicker? imagePicker,
  })  : _listingService = listingService ?? ListingService(),
        _locationService = locationService ?? LocationService(),
        _cloudinaryService = cloudinaryService ?? CloudinaryService(),
        _imagePicker = imagePicker ?? ImagePicker();

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<File?> get selectedImages => List.unmodifiable(_selectedImages);

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  /// Picks an image for a specific slot (0, 1, or 2).
  Future<void> pickImage(int index) async {
    if (index < 0 || index >= 3) return;
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (pickedFile != null) {
        _selectedImages[index] = File(pickedFile.path);
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Failed to select image: $e';
      notifyListeners();
    }
  }

  /// Sets an image directly at a slot.
  void setImage(int index, File? file) {
    if (index >= 0 && index < 3) {
      _selectedImages[index] = file;
      notifyListeners();
    }
  }

  /// Removes the image at a specific slot.
  void removeImage(int index) {
    if (index >= 0 && index < 3) {
      _selectedImages[index] = null;
      notifyListeners();
    }
  }

  /// Clears selected images and error state.
  void clearForm() {
    for (int i = 0; i < _selectedImages.length; i++) {
      _selectedImages[i] = null;
    }
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }

  /// Handles geocoding, Cloudinary image uploads (up to 3), and Firestore persistence.
  Future<bool> createListing({
    required String sellerId,
    required String title,
    required String description,
    required double monthlyRate,
    required String address,
    required List<String> amenities,
    List<File>? images,
  }) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      // 1. Geocode address via LocationService
      double latitude = 0.0;
      double longitude = 0.0;
      final coords = await _locationService.getCoordinatesFromAddress(address);
      if (coords != null) {
        latitude = coords['latitude'] ?? coords['lat'] ?? 0.0;
        longitude = coords['longitude'] ?? coords['lon'] ?? 0.0;
      }

      // 2. Upload images via CloudinaryService
      final List<File> filesToUpload = images ??
          _selectedImages.whereType<File>().toList();

      final List<String> uploadedUrls = [];
      for (final file in filesToUpload.take(3)) {
        final url = await _cloudinaryService.uploadImage(file);
        if (url != null && url.isNotEmpty) {
          uploadedUrls.add(url);
        }
      }

      // 3. Construct and save ListingModel
      final listing = ListingModel(
        id: '',
        sellerId: sellerId,
        title: title,
        description: description,
        monthlyRate: monthlyRate,
        address: address,
        latitude: latitude,
        longitude: longitude,
        imageUrls: uploadedUrls,
        amenities: amenities,
        isAvailable: true,
        createdAt: DateTime.now(),
      );

      await _listingService.createListing(listing);
      clearForm();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Real-time stream of seller listings.
  Stream<List<ListingModel>> getSellerListings(String sellerId) {
    return _listingService.getSellerListings(sellerId);
  }
}
