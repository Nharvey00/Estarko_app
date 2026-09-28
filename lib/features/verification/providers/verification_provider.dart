import 'dart:io';
import 'package:flutter/foundation.dart';
import '../../../core/services/cloudinary_service.dart';
import '../models/verification_model.dart';
import '../services/verification_service.dart';

class VerificationProvider extends ChangeNotifier {
  final VerificationService _verificationService;
  final CloudinaryService _cloudinaryService;

  bool _isLoading = false;
  String? _errorMessage;

  VerificationProvider({
    VerificationService? verificationService,
    CloudinaryService? cloudinaryService,
  })  : _verificationService = verificationService ?? VerificationService(),
        _cloudinaryService = cloudinaryService ?? CloudinaryService();

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  /// Exposes a stream of pending verifications from the service.
  Stream<List<VerificationModel>> getPendingVerifications() {
    return _verificationService.getPendingVerifications();
  }

  Stream<List<VerificationModel>> get pendingVerifications =>
      _verificationService.getPendingVerifications();

  /// Uploads an image to Cloudinary and returns the secure URL.
  Future<String?> uploadImage(File imageFile) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final secureUrl = await _cloudinaryService.uploadImage(imageFile);
      if (secureUrl == null || secureUrl.isEmpty) {
        _errorMessage = 'Failed to upload image. Please check your network and try again.';
      }
      return secureUrl;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  /// Submits verification record to Firestore.
  Future<bool> submitVerification({
    required String sellerId,
    required String sellerName,
    required String idImageUrl,
  }) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      await _verificationService.submitVerification(
        sellerId: sellerId,
        sellerName: sellerName,
        idImageUrl: idImageUrl,
      );
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Uploads image to Cloudinary and submits verification document in a single flow.
  Future<bool> uploadAndSubmitVerification({
    required String sellerId,
    required String sellerName,
    required File imageFile,
  }) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final secureUrl = await _cloudinaryService.uploadImage(imageFile);
      if (secureUrl == null || secureUrl.isEmpty) {
        _errorMessage = 'Image upload failed. Please try again.';
        return false;
      }

      await _verificationService.submitVerification(
        sellerId: sellerId,
        sellerName: sellerName,
        idImageUrl: secureUrl,
      );
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Updates status of a verification request and verifies user if approved.
  Future<bool> updateVerificationStatus(
    String id,
    String sellerId,
    String status,
  ) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      await _verificationService.updateVerificationStatus(id, sellerId, status);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
