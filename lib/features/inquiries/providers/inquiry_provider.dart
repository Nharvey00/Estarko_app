import 'package:flutter/foundation.dart';
import '../models/inquiry_model.dart';
import '../services/inquiry_service.dart';

class InquiryProvider extends ChangeNotifier {
  final InquiryService _inquiryService;

  bool _isLoading = false;
  String? _errorMessage;

  InquiryProvider({InquiryService? inquiryService})
      : _inquiryService = inquiryService ?? InquiryService();

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  /// Checks if tenant is allowed to send an inquiry today (less than 3).
  Future<bool> checkDailyLimit(String tenantId) async {
    try {
      return await _inquiryService.checkDailyLimit(tenantId);
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      return false;
    }
  }

  /// Checks if tenant has already sent an inquiry for this property.
  Future<bool> hasInquired(String tenantId, String propertyId) async {
    try {
      return await _inquiryService.hasInquired(tenantId, propertyId);
    } catch (_) {
      return false;
    }
  }

  /// Orchestrates viewing request submission.
  Future<bool> submitInquiry({
    required String propertyId,
    required String propertyTitle,
    required String tenantId,
    required String tenantName,
    required String sellerId,
  }) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      await _inquiryService.createInquiry(
        propertyId: propertyId,
        propertyTitle: propertyTitle,
        tenantId: tenantId,
        tenantName: tenantName,
        sellerId: sellerId,
      );
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Updates lead status in seller inbox.
  Future<bool> updateStatus(String id, String status) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      await _inquiryService.updateInquiryStatus(id, status);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Stream of inquiries for a seller.
  Stream<List<InquiryModel>> getSellerInquiries(String sellerId) {
    return _inquiryService.getSellerInquiries(sellerId);
  }
}
