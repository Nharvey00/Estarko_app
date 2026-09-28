import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/skeleton_loader.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/verification_model.dart';
import '../services/verification_service.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final VerificationService _verificationService = VerificationService();
  final Set<String> _processingIds = <String>{};

  Future<void> _updateStatus(
    VerificationModel verification,
    String status,
  ) async {
    setState(() {
      _processingIds.add(verification.id);
    });

    try {
      await _verificationService.updateVerificationStatus(
        verification.id,
        verification.sellerId,
        status,
      );

      if (!mounted) return;

      final isApproved = status.toLowerCase() == 'approved';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isApproved
                ? '${verification.sellerName} was successfully approved and verified!'
                : '${verification.sellerName}\'s verification was rejected.',
          ),
          backgroundColor: isApproved
              ? const Color(0xFF111827)
              : Colors.grey.shade800,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update verification: $e'),
          backgroundColor: const Color(0xFFE11D48),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _processingIds.remove(verification.id);
        });
      }
    }
  }

  void _showImagePreview(String imageUrl) {
    if (imageUrl.isEmpty) return;
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(16.0),
          child: Stack(
            alignment: Alignment.topRight,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16.0),
                child: InteractiveViewer(
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
                    fit: BoxFit.contain,
                    placeholder: (context, url) => Container(
                      height: 300,
                      color: Colors.black26,
                      child: const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Color(0xFFE11D48),
                          ),
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      height: 200,
                      color: Colors.white,
                      child: const Center(
                        child: Icon(
                          Icons.broken_image_outlined,
                          size: 48.0,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: IconButton(
                  icon: const CircleAvatar(
                    backgroundColor: Colors.black54,
                    child: Icon(Icons.close, color: Colors.white, size: 20),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final difference = now.difference(dt);
    if (difference.inMinutes < 60) {
      final mins = difference.inMinutes;
      return mins <= 1 ? 'Just now' : '$mins mins ago';
    } else if (difference.inHours < 24) {
      final hours = difference.inHours;
      return '$hours ${hours == 1 ? 'hour' : 'hours'} ago';
    } else {
      return '${dt.month}/${dt.day}/${dt.year}';
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle_outline,
                size: 72.0,
                color: Colors.grey.shade400,
              ),
            ),
            const SizedBox(height: 24.0),
            const Text(
              'All Caught Up',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 32.0,
                fontWeight: FontWeight.w900,
                letterSpacing: -1.0,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 8.0),
            Text(
              'No pending identity documents require moderation at this time.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15.0,
                color: Colors.grey.shade500,
                height: 1.4,
              ),
            ),
          ]
              .animate(interval: 100.ms)
              .fade(duration: 400.ms)
              .slideY(begin: 0.1, curve: Curves.easeOutQuad),
        ),
      ),
    );
  }

  Widget _buildVerificationCard(VerificationModel verification) {
    final isProcessing = _processingIds.contains(verification.id);

    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 20.0,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thumbnail of the ID (CachedNetworkImage)
              GestureDetector(
                onTap: () => _showImagePreview(verification.idImageUrl),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12.0),
                  child: CachedNetworkImage(
                    imageUrl: verification.idImageUrl,
                    width: 84.0,
                    height: 84.0,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => const EstarSkeleton(
                      width: 84.0,
                      height: 84.0,
                      borderRadius: BorderRadius.all(Radius.circular(12.0)),
                    ),
                    errorWidget: (context, url, error) => Container(
                      width: 84.0,
                      height: 84.0,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: Icon(
                        Icons.badge_outlined,
                        color: Colors.grey.shade400,
                        size: 32.0,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16.0),

              // Seller Information
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            verification.sellerName.isNotEmpty
                                ? verification.sellerName
                                : 'Unnamed Seller',
                            style: const TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF111827),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8.0,
                            vertical: 4.0,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFFBEB),
                            borderRadius: BorderRadius.circular(6.0),
                            border: Border.all(
                              color: const Color(0xFFFDE68A),
                            ),
                          ),
                          child: const Text(
                            'PENDING',
                            style: TextStyle(
                              fontSize: 10.0,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                              color: Color(0xFFB45309),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6.0),
                    Text(
                      'Seller ID: ${verification.sellerId}',
                      style: TextStyle(
                        fontSize: 13.0,
                        color: Colors.grey.shade500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      'Submitted ${_formatDate(verification.submittedAt)}',
                      style: TextStyle(
                        fontSize: 12.0,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20.0),

          // Two buttons: Reject (Grey standard button) and Approve (Ruby Red EstarButton)
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 56.0,
                  child: ElevatedButton(
                    onPressed: isProcessing
                        ? null
                        : () => _updateStatus(verification, 'rejected'),
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: Colors.grey.shade200,
                      foregroundColor: const Color(0xFF374151),
                      shape: const StadiumBorder(),
                    ),
                    child: const Text(
                      'Reject',
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12.0),
              Expanded(
                child: EstarButton(
                  text: 'Approve',
                  isLoading: isProcessing,
                  onPressed: () => _updateStatus(verification, 'approved'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.logout_outlined,
              color: Color(0xFF111827),
            ),
            tooltip: 'Log Out',
            onPressed: () {
              Provider.of<AuthProvider>(context, listen: false).logout();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: StreamBuilder<List<VerificationModel>>(
          stream: _verificationService.getPendingVerifications(),
          builder: (context, snapshot) {
            // Loading State: Return a ListView.builder of EstarSkeleton widgets (height: 120, rounded corners)
            if (snapshot.connectionState == ConnectionState.waiting) {
              return ListView.builder(
                padding: const EdgeInsets.all(24.0),
                itemCount: 6,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: EstarSkeleton(
                      height: 120.0,
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                  );
                },
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline_rounded,
                        color: Color(0xFFE11D48),
                        size: 48.0,
                      ),
                      const SizedBox(height: 16.0),
                      Text(
                        'Unable to load verification queue',
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      Text(
                        '${snapshot.error}',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14.0,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            final verifications = snapshot.data ?? [];

            // Empty State
            if (verifications.isEmpty) {
              return _buildEmptyState();
            }

            // Data State: Main list wrapped in staggered .animate() cascade
            return ListView(
              padding: const EdgeInsets.all(24.0),
              children: [
                const Text(
                  'Verification Queue',
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
                  'Moderate pending government ID documents submitted by sellers.',
                  style: TextStyle(
                    fontSize: 15.0,
                    color: Colors.grey.shade500,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24.0),
                ...verifications.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: _buildVerificationCard(item),
                  ),
                ),
              ]
                  .animate(interval: 100.ms)
                  .fade(duration: 400.ms)
                  .slideY(begin: 0.1, curve: Curves.easeOutQuad),
            );
          },
        ),
      ),
    );
  }
}
