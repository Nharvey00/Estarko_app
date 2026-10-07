import 'dart:io';
import 'dart:ui' as ui;
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../shared/widgets/custom_button.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/verification_model.dart';
import '../providers/verification_provider.dart';
import '../services/verification_service.dart';

class SellerUploadScreen extends StatefulWidget {
  final VerificationService? verificationService;

  const SellerUploadScreen({
    super.key,
    this.verificationService,
  });

  @override
  State<SellerUploadScreen> createState() => _SellerUploadScreenState();
}

class _SellerUploadScreenState extends State<SellerUploadScreen> {
  File? _selectedImage;
  bool _isLoading = false;
  late final VerificationProvider _fallbackProvider = VerificationProvider();
  late final VerificationService _verificationService;

  @override
  void initState() {
    super.initState();
    _verificationService = widget.verificationService ?? VerificationService();
  }

  VerificationProvider _getProvider(BuildContext context) {
    try {
      return Provider.of<VerificationProvider>(context, listen: false);
    } catch (_) {
      return _fallbackProvider;
    }
  }

  String _getSellerId(BuildContext context) {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.currentUser != null &&
          authProvider.currentUser!.uid.isNotEmpty) {
        return authProvider.currentUser!.uid;
      }
    } catch (_) {}
    try {
      return FirebaseAuth.instance.currentUser?.uid ?? '';
    } catch (_) {
      return '';
    }
  }

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to pick image: $e'),
          backgroundColor: const Color(0xFFE11D48),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _handleSubmit() async {
    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select your government ID image first.'),
          backgroundColor: Color(0xFFE11D48),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      String sellerId = _getSellerId(context);
      String sellerName = 'Seller';

      try {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        if (authProvider.currentUser != null) {
          sellerName = authProvider.currentUser!.name;
        }
      } catch (_) {}

      final provider = _getProvider(context);
      final success = await provider.uploadAndSubmitVerification(
        sellerId: sellerId,
        sellerName: sellerName,
        imageFile: _selectedImage!,
      );

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Identity document submitted successfully! Our moderators will review it shortly.',
            ),
            backgroundColor: Color(0xFF111827),
            behavior: SnackBarBehavior.floating,
          ),
        );
        setState(() {
          _selectedImage = null;
        });
      } else {
        final error =
            provider.errorMessage ?? 'Submission failed. Please try again.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error),
            backgroundColor: const Color(0xFFE11D48),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Submission error: $e'),
          backgroundColor: const Color(0xFFE11D48),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildUnderReviewState(VerificationModel verification) {
    final formattedDate =
        '${verification.submittedAt.month}/${verification.submittedAt.day}/${verification.submittedAt.year}';

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Massive Header
          const Text(
            'Under Review',
            style: TextStyle(
              fontSize: 36.0,
              fontWeight: FontWeight.w900,
              letterSpacing: -1.0,
              color: Color(0xFF111827),
              height: 1.15,
            ),
          ),
          const SizedBox(height: 8.0),
          Text(
            'Your identity verification request has been received and is currently being processed.',
            style: TextStyle(
              fontSize: 15.0,
              color: Colors.grey.shade500,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 32.0),

          // Big Under Review Status Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(28.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24.0),
              border: Border.all(color: const Color(0xFFF1F5F9)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0A000000),
                  blurRadius: 24.0,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  width: 84.0,
                  height: 84.0,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFF1F2),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.hourglass_top_rounded,
                      size: 42.0,
                      color: Color(0xFFE11D48),
                    ),
                  ),
                ),
                const SizedBox(height: 20.0),
                const Text(
                  'Review in Progress',
                  style: TextStyle(
                    fontSize: 22.0,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF111827),
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 12.0),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14.0,
                    vertical: 6.0,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(20.0),
                    border: Border.all(
                      color: const Color(0xFFF59E0B).withValues(alpha: 0.3),
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.pending_actions_rounded,
                        size: 16.0,
                        color: Color(0xFFB45309),
                      ),
                      SizedBox(width: 6.0),
                      Text(
                        'STATUS: PENDING REVIEW',
                        style: TextStyle(
                          fontSize: 12.0,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFFB45309),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20.0),
                Text(
                  'Submitted on $formattedDate. Our trust & safety team reviews landlord credentials to protect our marketplace. Once approved, your Seller Dashboard will unlock automatically.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14.0,
                    color: Colors.grey.shade600,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24.0),

          // Security reassurance
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.0),
              border: Border.all(color: const Color(0xFFF1F5F9)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.shield_outlined,
                  size: 22.0,
                  color: Color(0xFFE11D48),
                ),
                const SizedBox(width: 14.0),
                Expanded(
                  child: Text(
                    'No further action is required from you. You can check back shortly or wait for moderator approval.',
                    style: TextStyle(
                      fontSize: 13.0,
                      color: Colors.grey.shade600,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 36.0),

          // Logout escape button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: _handleBackOrLogout,
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF64748B),
                side: const BorderSide(color: Color(0xFFCBD5E1)),
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0),
                ),
              ),
              child: const Text(
                'Log Out',
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24.0),
        ]
            .animate(interval: 100.ms)
            .fade(duration: 400.ms)
            .slideY(begin: 0.1, curve: Curves.easeOutQuad),
      ),
    );
  }

  Widget _buildUploadForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Massive Header
          const Text(
            'Verify Identity',
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
            'Upload a government-issued photo ID to become a trusted, verified seller on EstarKo.',
            style: TextStyle(
              fontSize: 15.0,
              color: Colors.grey.shade500,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 28.0),

          // Square Dashed Dropzone
          AspectRatio(
            aspectRatio: 1.0,
            child: GestureDetector(
              onTap: _pickImage,
              child: CustomPaint(
                painter: DashedBorderPainter(
                  color: _selectedImage != null
                      ? const Color(0xFFE11D48)
                      : const Color(0xFFCBD5E1),
                  strokeWidth: 2.0,
                  dashWidth: 8.0,
                  dashSpace: 6.0,
                  radius: 20.0,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: _selectedImage != null
                      ? Stack(
                          fit: StackFit.expand,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(20.0),
                              child: Image.file(
                                _selectedImage!,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              bottom: 16.0,
                              right: 16.0,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14.0,
                                  vertical: 8.0,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xBF111827),
                                  borderRadius: BorderRadius.circular(20.0),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.photo_library_outlined,
                                      color: Colors.white,
                                      size: 16.0,
                                    ),
                                    SizedBox(width: 6.0),
                                    Text(
                                      'Change ID',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 13.0,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        )
                      : Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 68.0,
                                  height: 68.0,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFFFF1F2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.badge_outlined,
                                    size: 34.0,
                                    color: Color(0xFFE11D48),
                                  ),
                                ),
                                const SizedBox(height: 16.0),
                                const Text(
                                  'Upload Government ID',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 17.0,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF111827),
                                  ),
                                ),
                                const SizedBox(height: 6.0),
                                Text(
                                  'Passport, Driver\'s License, or National ID',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 13.0,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                                const SizedBox(height: 14.0),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14.0,
                                    vertical: 6.0,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF1F5F9),
                                    borderRadius: BorderRadius.circular(20.0),
                                  ),
                                  child: const Text(
                                    'Browse Gallery',
                                    style: TextStyle(
                                      fontSize: 12.0,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF64748B),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24.0),

          // Trust / Security Badge
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.0),
              border: Border.all(color: const Color(0xFFF1F5F9)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0A000000),
                  blurRadius: 20.0,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.shield_outlined,
                  size: 22.0,
                  color: Color(0xFFE11D48),
                ),
                const SizedBox(width: 14.0),
                Expanded(
                  child: Text(
                    'Your document is stored securely and reviewed solely by EstarKo moderators to verify ownership.',
                    style: TextStyle(
                      fontSize: 13.0,
                      color: Colors.grey.shade600,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28.0),

          // Submit Action Button
          EstarButton(
            text: 'Submit for Verification',
            isLoading: _isLoading,
            onPressed: _handleSubmit,
          ),
          const SizedBox(height: 24.0),
        ]
            .animate(interval: 100.ms)
            .fade(duration: 400.ms)
            .slideY(begin: 0.1, curve: Curves.easeOutQuad),
      ),
    );
  }

  Stream<VerificationModel?>? _getVerificationStream(String sellerId) {
    if (sellerId.isEmpty) return null;
    try {
      return _verificationService.getSellerVerification(sellerId);
    } catch (_) {
      return null;
    }
  }

  Future<void> _handleBackOrLogout() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.logout(context: context);
  }

  @override
  Widget build(BuildContext context) {
    final sellerId = _getSellerId(context);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _handleBackOrLogout();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFFAFAFA),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_outlined,
              color: Color(0xFF111827),
            ),
            tooltip: 'Back to Sign In',
            onPressed: _handleBackOrLogout,
          ),
        ),
        body: SafeArea(
          child: sellerId.isEmpty
              ? _buildUploadForm()
              : StreamBuilder<VerificationModel?>(
                  stream: _getVerificationStream(sellerId),
                  builder: (context, snapshot) {
                    if (snapshot.hasData &&
                        snapshot.data != null &&
                        snapshot.data!.status.toLowerCase() == 'pending') {
                      return _buildUnderReviewState(snapshot.data!);
                    }
                    return _buildUploadForm();
                  },
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
    this.radius = 20.0,
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
