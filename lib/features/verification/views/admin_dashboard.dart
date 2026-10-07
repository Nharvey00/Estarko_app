import 'dart:ui' as ui;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../../shared/widgets/estar_friendly_error.dart';
import '../../../shared/widgets/skeleton_loader.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/verification_model.dart';
import '../services/verification_service.dart';

/// Direct alias so AdminReviewDashboardScreen can be imported directly
typedef AdminReviewDashboardScreen = AdminDashboard;

/// Task 2: Admin Review Dashboard (The "Linear" Aesthetic)
/// Minimalist, hyper-clean startup CRM inspired by Linear & Vercel:
/// - Sleek edge-to-edge list rows with faint grey hover/tap background
/// - Vibrant status pills with exactly 10% opacity backgrounds
/// - iOS-style Dismissible swipe-to-approve & swipe-to-reject with vivid backgrounds
/// - Monospace ID tags and high-density metadata
/// - 130px bottom clearance dock padding
/// - Flutter Animate cascading entrance & light impact haptics
class AdminDashboard extends StatefulWidget {
  final VerificationService? verificationService;

  const AdminDashboard({super.key, this.verificationService});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  late final VerificationService _verificationService;
  final Set<String> _processingIds = <String>{};

  @override
  void initState() {
    super.initState();
    _verificationService =
        widget.verificationService ?? VerificationService();
  }

  Future<bool> _updateStatus(
    VerificationModel verification,
    String status,
  ) async {
    HapticFeedback.lightImpact();

    setState(() {
      _processingIds.add(verification.id);
    });

    try {
      await _verificationService.updateVerificationStatus(
        verification.id,
        verification.sellerId,
        status,
      );

      if (!mounted) return true;

      final isApproved = status.toLowerCase() == 'approved';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                isApproved
                    ? Icons.check_circle_rounded
                    : Icons.cancel_outlined,
                color: Colors.white,
                size: 20.0,
              ),
              const SizedBox(width: 10.0),
              Expanded(
                child: Text(
                  isApproved
                      ? '${verification.sellerName} was verified and approved!'
                      : '${verification.sellerName}\'s document was rejected.',
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: isApproved
              ? const Color(0xFF10B981)
              : const Color(0xFF1E293B),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14.0),
          ),
          margin: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 130.0),
        ),
      );
      return true;
    } catch (e) {
      if (!mounted) return false;
      EstarFriendlyError.showSnackBar(context, e);
      return false;
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
    HapticFeedback.selectionClick();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(16.0),
          child: Stack(
            alignment: Alignment.topRight,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(24.0),
                child: BackdropFilter(
                  filter: ui.ImageFilter.blur(sigmaX: 18.0, sigmaY: 18.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A).withValues(alpha: 0.88),
                      borderRadius: BorderRadius.circular(24.0),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.15),
                        width: 1.0,
                      ),
                    ),
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 24.0),
                        ConstrainedBox(
                          constraints: BoxConstraints(
                            maxHeight:
                                MediaQuery.sizeOf(dialogContext).height * 0.68,
                          ),
                          child: InteractiveViewer(
                            panEnabled: true,
                            minScale: 0.8,
                            maxScale: 4.0,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(14.0),
                              child: CachedNetworkImage(
                              imageUrl: imageUrl,
                              fit: BoxFit.contain,
                              placeholder: (context, url) => const SizedBox(
                                height: 300.0,
                                child: Center(
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Color(0xFFE11D48),
                                    ),
                                  ),
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
                                height: 220.0,
                                alignment: Alignment.center,
                                child: const Text(
                                  'Failed to load document image',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        ),
                        const SizedBox(height: 16.0),
                        const Text(
                          'Pinch or scroll to zoom document details',
                          style: TextStyle(
                            fontSize: 12.0,
                            color: Colors.white60,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 14.0,
                right: 14.0,
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Navigator.pop(dialogContext);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close_rounded,
                      color: Colors.white,
                      size: 20.0,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  // Vibrant Status Pill with exactly 10% opacity background of the text color
  Widget _buildStatusPill(String status) {
    Color textColor;
    switch (status.toLowerCase()) {
      case 'approved':
        textColor = const Color(0xFF10B981); // Emerald
        break;
      case 'rejected':
        textColor = const Color(0xFF64748B); // Slate
        break;
      case 'pending':
      default:
        textColor = const Color(0xFFE11D48); // Ruby Red
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: textColor.withValues(alpha: 0.10), // EXACTLY 10% opacity
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(
          color: textColor.withValues(alpha: 0.20),
          width: 1.0,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6.0,
            height: 6.0,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: textColor,
            ),
          ),
          const SizedBox(width: 5.0),
          Text(
            status.toUpperCase(),
            style: TextStyle(
              fontSize: 10.0,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.6,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  // Linear / Vercel Minimalist Header Bar
  Widget _buildLinearHeader(int queueCount) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 14.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.0),
        border: Border.all(
          color: Colors.grey.withValues(alpha: 0.12),
          width: 1.0,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 16.0,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Live Pulsing Emerald Status
          Container(
            width: 8.0,
            height: 8.0,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF10B981),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF10B981).withValues(alpha: 0.60),
                  blurRadius: 8.0,
                  spreadRadius: 1.5,
                ),
              ],
            ),
          )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .scaleXY(begin: 0.85, end: 1.25, duration: 1100.ms),
          const SizedBox(width: 10.0),
          const Expanded(
            child: Text(
              'REALTIME CRM',
              style: TextStyle(
                fontSize: 11.0,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.0,
                color: Color(0xFF0F172A),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8.0),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF1F2),
              borderRadius: BorderRadius.circular(12.0),
              border: Border.all(
                color: const Color(0xFFFFE4E6),
                width: 1.0,
              ),
            ),
            child: Text(
              '$queueCount PENDING',
              style: const TextStyle(
                fontSize: 11.0,
                fontWeight: FontWeight.w800,
                color: Color(0xFFE11D48),
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Linear Sleek Edge-to-Edge List Row with iOS Dismissible Swipe Actions
  Widget _buildLinearRow(VerificationModel verification) {
    final isProcessing = _processingIds.contains(verification.id);
    final shortUid = verification.sellerId.length > 8
        ? verification.sellerId.substring(0, 8).toUpperCase()
        : verification.sellerId.toUpperCase();

    return Dismissible(
      key: ValueKey(verification.id),
      direction: DismissDirection.horizontal,
      // Left-to-right swipe background: Vivid Emerald Approve
      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        decoration: BoxDecoration(
          color: const Color(0xFF10B981),
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: const Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Colors.white, size: 24.0),
            SizedBox(width: 10.0),
            Text(
              'APPROVE LANDLORD',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 12.0,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
      ),
      // Right-to-left swipe background: Vivid Ruby Red Reject
      secondaryBackground: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        decoration: BoxDecoration(
          color: const Color(0xFFE11D48),
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              'REJECT APPLICATION',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 12.0,
                letterSpacing: 0.8,
              ),
            ),
            SizedBox(width: 10.0),
            Icon(Icons.cancel_rounded, color: Colors.white, size: 24.0),
          ],
        ),
      ),
      confirmDismiss: (direction) async {
        HapticFeedback.lightImpact();
        final status = direction == DismissDirection.startToEnd
            ? 'approved'
            : 'rejected';
        return await _updateStatus(verification, status);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(
            color: Colors.grey.withValues(alpha: 0.12),
            width: 1.0,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x06000000),
              blurRadius: 12.0,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16.0),
            hoverColor: const Color(0xFFF8FAFC),
            splashColor: const Color(0xFFF1F5F9),
            onTap: () => _showImagePreview(verification.idImageUrl),
            child: Padding(
              padding: const EdgeInsets.all(14.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Upper Row: Thumbnail + Landlord Info + Status Pill
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // ID Document Thumbnail / Squircle Avatar
                      Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12.0),
                            child: Container(
                              width: 48.0,
                              height: 48.0,
                              color: const Color(0xFFF1F5F9),
                              child: verification.idImageUrl.isNotEmpty
                                  ? CachedNetworkImage(
                                      imageUrl: verification.idImageUrl,
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) =>
                                          const EstarSkeleton(
                                        width: 48.0,
                                        height: 48.0,
                                      ),
                                      errorWidget: (context, url, error) =>
                                          const Icon(
                                        Icons.badge_rounded,
                                        color: Color(0xFF94A3B8),
                                        size: 24.0,
                                      ),
                                    )
                                  : const Icon(
                                      Icons.badge_rounded,
                                      color: Color(0xFF94A3B8),
                                      size: 24.0,
                                    ),
                            ),
                          ),
                          Positioned(
                            bottom: 2.0,
                            right: 2.0,
                            child: Container(
                              padding: const EdgeInsets.all(2.5),
                              decoration: const BoxDecoration(
                                color: Color(0xFF0F172A),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.zoom_in_rounded,
                                size: 10.0,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 12.0),

                      // Landlord Info & Monospace UID
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              verification.sellerName.isNotEmpty
                                  ? verification.sellerName
                                  : 'Unnamed Landlord',
                              style: const TextStyle(
                                fontSize: 15.0,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0F172A),
                                letterSpacing: -0.2,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4.0),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6.0,
                                    vertical: 2.0,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF1F5F9),
                                    borderRadius: BorderRadius.circular(6.0),
                                  ),
                                  child: Text(
                                    '#$shortUid',
                                    style: const TextStyle(
                                      fontSize: 10.5,
                                      fontFamily: 'monospace',
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF64748B),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6.0),
                                Flexible(
                                  child: Text(
                                    _formatDate(verification.submittedAt),
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      color: Colors.grey.shade500,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8.0),

                      // Vibrant Status Pill
                      _buildStatusPill(verification.status),
                    ],
                  ),

                  const SizedBox(height: 12.0),

                  // Action Footer Bar: View ID + Reject / Approve Buttons
                  Container(
                    padding: const EdgeInsets.only(top: 10.0),
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color: Colors.grey.withValues(alpha: 0.10),
                          width: 1.0,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        // View ID Button
                        InkWell(
                          onTap: verification.idImageUrl.isNotEmpty
                              ? () => _showImagePreview(verification.idImageUrl)
                              : null,
                          borderRadius: BorderRadius.circular(8.0),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6.0,
                              vertical: 4.0,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.visibility_outlined,
                                  size: 15.0,
                                  color: Colors.grey.shade600,
                                ),
                                const SizedBox(width: 4.0),
                                Text(
                                  'View ID',
                                  style: TextStyle(
                                    fontSize: 12.0,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const Spacer(),

                        // Inline Quick-Action Buttons (Reject / Approve)
                        if (isProcessing)
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.0),
                            child: SizedBox(
                              width: 18.0,
                              height: 18.0,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.0,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Color(0xFFE11D48),
                                ),
                              ),
                            ),
                          )
                        else ...[
                          // Quick Reject
                          Material(
                            color: const Color(0xFFFFF1F2),
                            borderRadius: BorderRadius.circular(8.0),
                            child: InkWell(
                              onTap: () =>
                                  _updateStatus(verification, 'rejected'),
                              borderRadius: BorderRadius.circular(8.0),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10.0,
                                  vertical: 6.0,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8.0),
                                  border: Border.all(
                                    color: const Color(0xFFFFE4E6),
                                  ),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.close_rounded,
                                      size: 14.0,
                                      color: Color(0xFFE11D48),
                                    ),
                                    SizedBox(width: 4.0),
                                    Text(
                                      'Reject',
                                      style: TextStyle(
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFFE11D48),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8.0),
                          // Quick Approve
                          Material(
                            color: const Color(0xFF10B981),
                            borderRadius: BorderRadius.circular(8.0),
                            child: InkWell(
                              onTap: () =>
                                  _updateStatus(verification, 'approved'),
                              borderRadius: BorderRadius.circular(8.0),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12.0,
                                  vertical: 6.0,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.check_rounded,
                                      size: 14.0,
                                      color: Colors.white,
                                    ),
                                    SizedBox(width: 4.0),
                                    Text(
                                      'Approve',
                                      style: TextStyle(
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
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
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'INTERNAL CRM',
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
                color: Color(0xFF64748B),
              ),
            ),
            SizedBox(height: 2.0),
            Text.rich(
              TextSpan(
                text: 'Admin Review ',
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0F172A),
                  letterSpacing: -0.5,
                ),
                children: [
                  TextSpan(
                    text: 'CRM',
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFFE11D48),
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.logout_rounded,
              color: Color(0xFF0F172A),
            ),
            tooltip: 'Log Out',
            onPressed: () {
              HapticFeedback.lightImpact();
              Provider.of<AuthProvider>(context, listen: false)
                  .logout(context: context);
            },
          ),
          const SizedBox(width: 8.0),
        ],
      ),
      body: SafeArea(
        child: StreamBuilder<List<VerificationModel>>(
          stream: _verificationService.getPendingVerifications(),
          builder: (context, snapshot) {
            // Skeleton Loader while waiting
            if (snapshot.connectionState == ConnectionState.waiting) {
              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 130.0),
                itemCount: 5,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: EstarSkeleton(
                      height: 72.0,
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                  );
                },
              );
            }

            // Error View
            if (snapshot.hasError) {
              return EstarErrorView(
                error: snapshot.error,
                title: 'Unable to Load Verification Queue',
                onRetry: () => setState(() {}),
              );
            }

            final verifications = snapshot.data ?? [];

            // Empty State
            if (verifications.isEmpty) {
              return const EstarEmptyStateView(
                icon: Icons.verified_user_rounded,
                title: 'Queue is Clear',
                message:
                    'All landlord identity documents have been processed. New submissions will appear here automatically in real time.',
              );
            }

            // Linear CRM Feed with 130px Clearance Padding
            return ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 130.0),
              children: [
                // Minimalist Linear Header Bar
                _buildLinearHeader(verifications.length),

                const SizedBox(height: 16.0),

                // Swipe Action Hint
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.swipe_rounded,
                        size: 14.0,
                        color: Color(0xFF94A3B8),
                      ),
                      const SizedBox(width: 6.0),
                      Expanded(
                        child: Text(
                          'Swipe right to approve • Swipe left to reject',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12.0),

                // Flat Edge-to-Edge List Rows with Cascading Animation
                ...verifications.map((item) => _buildLinearRow(item)),
              ]
                  .animate(interval: 40.ms)
                  .fade(duration: 350.ms)
                  .slideY(begin: 0.04, curve: Curves.easeOutCubic),
            );
          },
        ),
      ),
    );
  }
}
