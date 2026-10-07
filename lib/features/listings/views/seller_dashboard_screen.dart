import 'dart:ui' as ui;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../../shared/widgets/estar_friendly_error.dart';
import '../../../shared/widgets/skeleton_loader.dart';
import '../../auth/providers/auth_provider.dart';
import '../../inquiries/models/inquiry_model.dart';
import '../../inquiries/services/inquiry_service.dart';
import '../../inquiries/views/seller_inbox_screen.dart';
import '../models/listing_model.dart';
import '../services/listing_service.dart';
import 'create_listing_screen.dart';

/// Direct alias so LandlordDashboardScreen can be imported directly
typedef LandlordDashboardScreen = SellerDashboardScreen;

/// Task 1: Seller / Landlord Dashboard (The "Bento Box" Upgrade)
/// Designed with Apple Widget & Stripe Dashboard aesthetics:
/// - Asymmetrical Bento Box grid layout of crisp white surfaces (0% elevation)
/// - Ultra-soft highly diffused drop shadow (Color(0x0A000000), blur 24)
/// - Microscopic hairline border (Colors.grey.withOpacity(0.1))
/// - Glowing emerald pulse for active metrics
/// - Massive typography for data with tiny bold uppercase Plus Jakarta Sans labels
/// - 130px bottom clearance dock padding
class SellerDashboardScreen extends StatefulWidget {
  const SellerDashboardScreen({super.key});

  @override
  State<SellerDashboardScreen> createState() => _SellerDashboardScreenState();
}

class _SellerDashboardScreenState extends State<SellerDashboardScreen> {
  final ListingService _listingService = ListingService();
  final InquiryService _inquiryService = InquiryService();

  String _getSellerId(BuildContext context) {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.currentUser != null &&
          authProvider.currentUser!.uid.isNotEmpty) {
        return authProvider.currentUser!.uid;
      }
    } catch (_) {}
    return FirebaseAuth.instance.currentUser?.uid ?? '';
  }

  // Apple & Stripe Bento Box Surface Decoration
  BoxDecoration _bentoDecoration({Color? bgColor}) {
    return BoxDecoration(
      color: bgColor ?? Colors.white,
      borderRadius: BorderRadius.circular(24.0),
      border: Border.all(
        color: Colors.grey.withValues(alpha: 0.10),
        width: 1.0,
      ),
      boxShadow: const [
        BoxShadow(
          color: Color(0x0A000000),
          blurRadius: 24.0,
          spreadRadius: 0.0,
          offset: Offset(0, 4),
        ),
      ],
    );
  }

  // Subtle Glowing Emerald Pulse Indicator
  Widget _buildEmeraldPulse() {
    return Container(
      width: 10.0,
      height: 10.0,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF10B981),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF10B981).withValues(alpha: 0.55),
            blurRadius: 10.0,
            spreadRadius: 2.0,
          ),
        ],
      ),
    )
        .animate(onPlay: (controller) => controller.repeat(reverse: true))
        .scaleXY(begin: 0.85, end: 1.25, duration: 1100.ms, curve: Curves.easeInOut);
  }

  // Bento Box Section (Asymmetrical Apple-Style Grid)
  Widget _buildBentoBoxGrid({
    required List<ListingModel> listings,
    required List<InquiryModel> inquiries,
  }) {
    final activeCount = listings.where((l) => l.isAvailable).length;
    final totalUnits = listings.length;
    final pendingInquiries = inquiries
        .where((i) => i.status.toLowerCase() == 'pending')
        .length;

    final occupancyRate = totalUnits > 0
        ? ((activeCount / totalUnits) * 100).toInt()
        : 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Upper Bento Row: Hero Active Listings (Left) + Total Units (Right)
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bento Tile 1: Hero Active Listings (Large card with Emerald Glow & Micro-chart)
            Expanded(
              flex: 6,
              child: Container(
                height: 180.0,
                padding: const EdgeInsets.all(20.0),
                decoration: _bentoDecoration(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            _buildEmeraldPulse(),
                            const SizedBox(width: 8.0),
                            const Text(
                              'ACTIVE LISTINGS',
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.1,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8.0,
                            vertical: 3.5,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFECFDF5),
                            borderRadius: BorderRadius.circular(10.0),
                            border: Border.all(
                              color: const Color(0xFFA7F3D0),
                              width: 0.8,
                            ),
                          ),
                          child: const Text(
                            'LIVE',
                            style: TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF059669),
                              letterSpacing: 0.6,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$activeCount',
                          style: const TextStyle(
                            fontSize: 42.0,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -1.5,
                            color: Color(0xFF0F172A),
                            height: 1.0,
                          ),
                        ),
                        const SizedBox(height: 4.0),
                        Text(
                          '$occupancyRate% occupancy rate',
                          style: TextStyle(
                            fontSize: 12.0,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                    // Micro Progress Bar / Sparkline
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6.0),
                      child: Container(
                        height: 6.0,
                        width: double.infinity,
                        color: const Color(0xFFF1F5F9),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: totalUnits > 0
                              ? (activeCount / totalUnits).clamp(0.05, 1.0)
                              : 0.05,
                          child: Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Color(0xFF34D399), Color(0xFF10B981)],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12.0),

            // Bento Tile 2: Total Units / Tenants
            Expanded(
              flex: 4,
              child: Container(
                height: 180.0,
                padding: const EdgeInsets.all(20.0),
                decoration: _bentoDecoration(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 38.0,
                      height: 38.0,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: const Icon(
                        Icons.holiday_village_rounded,
                        color: Color(0xFF0F172A),
                        size: 20.0,
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$totalUnits',
                          style: const TextStyle(
                            fontSize: 34.0,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -1.0,
                            color: Color(0xFF0F172A),
                            height: 1.0,
                          ),
                        ),
                        const SizedBox(height: 4.0),
                        const Text(
                          'TOTAL UNITS',
                          style: TextStyle(
                            fontSize: 10.0,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.0,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '${totalUnits - activeCount} unlisted',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12.0),

        // Lower Bento Row: Pending Inquiries (Interactive) + Add Listing Quick Action
        Row(
          children: [
            // Bento Tile 3: Pending Inquiries Lead Card (Navigates to Inbox)
            Expanded(
              flex: 5,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SellerInboxScreen(),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(24.0),
                  child: Ink(
                    height: 140.0,
                    padding: const EdgeInsets.all(18.0),
                    decoration: _bentoDecoration(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'PENDING INQUIRIES',
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.0,
                                color: Color(0xFF64748B),
                              ),
                            ),
                            if (pendingInquiries > 0)
                              Container(
                                width: 8.0,
                                height: 8.0,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color(0xFFE11D48),
                                ),
                              )
                                  .animate(onPlay: (controller) => controller.repeat(reverse: true))
                                  .scaleXY(begin: 0.8, end: 1.3, duration: 800.ms)
                            else
                              const Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 11.0,
                                color: Color(0xFF94A3B8),
                              ),
                          ],
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              '$pendingInquiries',
                              style: TextStyle(
                                fontSize: 32.0,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -1.0,
                                color: pendingInquiries > 0
                                    ? const Color(0xFFE11D48)
                                    : const Color(0xFF0F172A),
                              ),
                            ),
                            const SizedBox(width: 6.0),
                            Text(
                              'tenant leads',
                              style: TextStyle(
                                fontSize: 12.0,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          pendingInquiries > 0
                              ? 'Tap to review inbox'
                              : 'All caught up',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: pendingInquiries > 0
                                ? const Color(0xFFE11D48)
                                : const Color(0xFF10B981),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12.0),

            // Bento Tile 4: Quick Action Add Property Banner
            Expanded(
              flex: 5,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CreateListingScreen(),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(24.0),
                  child: Ink(
                    height: 140.0,
                    padding: const EdgeInsets.all(18.0),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24.0),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x1A000000),
                          blurRadius: 24.0,
                          offset: Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'FAST ACTION',
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.0,
                                color: Color(0xFF94A3B8),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(5.0),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.add_rounded,
                                color: Colors.white,
                                size: 14.0,
                              ),
                            ),
                          ],
                        ),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Publish Unit',
                              style: TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: -0.3,
                              ),
                            ),
                            SizedBox(height: 2.0),
                            Text(
                              'Reach 5k+ tenants',
                              style: TextStyle(
                                fontSize: 11.5,
                                color: Color(0xFF94A3B8),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const Row(
                          children: [
                            Text(
                              'Get Started',
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFFFB7185),
                              ),
                            ),
                            SizedBox(width: 4.0),
                            Icon(
                              Icons.arrow_forward_rounded,
                              size: 11.0,
                              color: Color(0xFFFB7185),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Crisp White Property Listing Card (0% Elevation, Custom Soft Shadow)
  Widget _buildListingCard(BuildContext context, ListingModel listing) {
    final hasImage = listing.imageUrls.isNotEmpty;
    final firstImage = hasImage ? listing.imageUrls.first : '';

    return Container(
      decoration: _bentoDecoration(),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cover Photo with Status Pill & Rate Overlay
          Stack(
            children: [
              if (hasImage && firstImage.isNotEmpty)
                SizedBox(
                  height: 195.0,
                  width: double.infinity,
                  child: CachedNetworkImage(
                    imageUrl: firstImage,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => const EstarSkeleton(
                      height: 195.0,
                      width: double.infinity,
                    ),
                    errorWidget: (context, url, error) => Container(
                      height: 195.0,
                      color: const Color(0xFFF1F5F9),
                      child: const Center(
                        child: Icon(
                          Icons.apartment_rounded,
                          size: 48.0,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                    ),
                  ),
                )
              else
                Container(
                  height: 160.0,
                  width: double.infinity,
                  color: const Color(0xFFF1F5F9),
                  child: const Center(
                    child: Icon(
                      Icons.apartment_rounded,
                      size: 48.0,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                ),

              // Live Status Pill (Frosted Glass with glowing indicator)
              Positioned(
                top: 14.0,
                left: 14.0,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20.0),
                  child: BackdropFilter(
                    filter: ui.ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10.0,
                        vertical: 5.0,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F172A).withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(20.0),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.15),
                          width: 0.8,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (listing.isAvailable)
                            _buildEmeraldPulse()
                          else
                            Container(
                              width: 8.0,
                              height: 8.0,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xFF94A3B8),
                              ),
                            ),
                          const SizedBox(width: 6.0),
                          Text(
                            listing.isAvailable ? 'LIVE' : 'UNLISTED',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.6,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Monthly Rate Floating Tag (Top Right)
              Positioned(
                top: 14.0,
                right: 14.0,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20.0),
                  child: BackdropFilter(
                    filter: ui.ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12.0,
                        vertical: 5.0,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.90),
                        borderRadius: BorderRadius.circular(20.0),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.80),
                          width: 1.0,
                        ),
                      ),
                      child: Text(
                        '₱${listing.monthlyRate.toStringAsFixed(0)}/mo',
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFFE11D48),
                          letterSpacing: -0.3,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Property Information & Controls
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  listing.title,
                  style: const TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                    letterSpacing: -0.4,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (listing.address.isNotEmpty) ...[
                  const SizedBox(height: 5.0),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 14.0,
                        color: Color(0xFF64748B),
                      ),
                      const SizedBox(width: 4.0),
                      Expanded(
                        child: Text(
                          listing.address,
                          style: const TextStyle(
                            fontSize: 13.0,
                            color: Color(0xFF64748B),
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
                if (listing.amenities.isNotEmpty) ...[
                  const SizedBox(height: 12.0),
                  Wrap(
                    spacing: 6.0,
                    runSpacing: 5.0,
                    children: listing.amenities.take(4).map((amenity) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10.0,
                          vertical: 4.0,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(10.0),
                          border: Border.all(
                            color: Colors.grey.withValues(alpha: 0.12),
                            width: 1.0,
                          ),
                        ),
                        child: Text(
                          amenity,
                          style: const TextStyle(
                            fontSize: 11.0,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF475569),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
                const SizedBox(height: 16.0),
                Divider(
                  color: Colors.grey.withValues(alpha: 0.10),
                  height: 1.0,
                ),
                const SizedBox(height: 12.0),

                // Management Row: Availability Switch & Actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Transform.scale(
                          scale: 0.85,
                          child: Switch.adaptive(
                            value: listing.isAvailable,
                            activeThumbColor: const Color(0xFF10B981),
                            activeTrackColor: const Color(0xFFA7F3D0),
                            onChanged: (newValue) async {
                              HapticFeedback.lightImpact();
                              await _listingService.updateListingAvailability(
                                listing.id,
                                newValue,
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 4.0),
                        Text(
                          listing.isAvailable ? 'Active' : 'Paused',
                          style: TextStyle(
                            fontSize: 13.0,
                            fontWeight: FontWeight.w700,
                            color: listing.isAvailable
                                ? const Color(0xFF10B981)
                                : Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.delete_outline_rounded,
                        color: Color(0xFFE11D48),
                        size: 20.0,
                      ),
                      tooltip: 'Delete Listing',
                      onPressed: () async {
                        HapticFeedback.lightImpact();
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(22.0),
                            ),
                            title: const Text(
                              'Delete Listing',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                            content: const Text(
                              'Are you sure you want to permanently delete this listing?',
                              style: TextStyle(
                                color: Color(0xFF64748B),
                                height: 1.4,
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, false),
                                child: Text(
                                  'Cancel',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, true),
                                child: const Text(
                                  'Delete',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFFE11D48),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                        if (confirm == true) {
                          await _listingService.deleteListing(listing.id);
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sellerId = _getSellerId(context);

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
              'HOST PORTAL',
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
                color: Color(0xFF64748B),
              ),
            ),
            SizedBox(height: 2.0),
            Text(
              'Portfolio Dashboard',
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.w900,
                color: Color(0xFF0F172A),
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        actions: [
          // Leads Inbox Button
          IconButton(
            icon: const Icon(
              Icons.mail_outline_rounded,
              color: Color(0xFF0F172A),
            ),
            tooltip: 'Tenant Inquiries',
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SellerInboxScreen(),
                ),
              );
            },
          ),
          // Logout Button
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
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30.0),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFE11D48).withValues(alpha: 0.35),
              blurRadius: 20.0,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: () {
            HapticFeedback.lightImpact();
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const CreateListingScreen(),
              ),
            );
          },
          backgroundColor: const Color(0xFFE11D48),
          foregroundColor: Colors.white,
          elevation: 0,
          highlightElevation: 0,
          icon: const Icon(Icons.add_rounded, size: 22.0),
          label: const Text(
            'New Property',
            style: TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.2,
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: StreamBuilder<List<ListingModel>>(
          stream: _listingService.getSellerListings(sellerId),
          builder: (context, listingsSnapshot) {
            if (listingsSnapshot.connectionState == ConnectionState.waiting) {
              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(20.0, 16.0, 20.0, 130.0),
                itemCount: 3,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: EstarSkeleton(
                      height: 170.0,
                      borderRadius: BorderRadius.circular(24.0),
                    ),
                  );
                },
              );
            }

            if (listingsSnapshot.hasError) {
              return EstarErrorView(
                error: listingsSnapshot.error,
                title: 'Unable to Load Properties',
                onRetry: () => setState(() {}),
              );
            }

            final listings = listingsSnapshot.data ?? [];

            // Stream seller inquiries for real-time Bento Box metrics
            return StreamBuilder<List<InquiryModel>>(
              stream: _inquiryService.getSellerInquiries(sellerId),
              builder: (context, inquiriesSnapshot) {
                final inquiries = inquiriesSnapshot.data ?? [];

                // Empty state if no listings exist
                if (listings.isEmpty) {
                  return EstarEmptyStateView(
                    icon: Icons.holiday_village_outlined,
                    title: 'No properties listed yet',
                    message:
                        'You have not added any properties yet. Tap below to publish your first rental listing and begin welcoming tenants.',
                    actionText: 'Add First Property',
                    onAction: () {
                      HapticFeedback.lightImpact();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CreateListingScreen(),
                        ),
                      );
                    },
                  );
                }

                // Bento Box Dashboard Screen with 130px Bottom Clearance Dock Padding
                return ListView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20.0, 12.0, 20.0, 130.0),
                  children: [
                    // Bento Box Metrics Grid
                    _buildBentoBoxGrid(
                      listings: listings,
                      inquiries: inquiries,
                    ),

                    const SizedBox(height: 28.0),

                    // Section Heading: Managed Properties
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'PORTFOLIO',
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.1,
                                color: Color(0xFF64748B),
                              ),
                            ),
                            SizedBox(height: 2.0),
                            Text(
                              'Your Properties',
                              style: TextStyle(
                                fontSize: 22.0,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.6,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '${listings.length} total',
                          style: TextStyle(
                            fontSize: 13.0,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16.0),

                    // Property Management Cards
                    ...listings.map(
                      (listing) => Padding(
                        padding: const EdgeInsets.only(bottom: 18.0),
                        child: _buildListingCard(context, listing),
                      ),
                    ),
                  ]
                      .animate(interval: 50.ms)
                      .fade(duration: 400.ms)
                      .slideY(begin: 0.05, curve: Curves.easeOutCubic),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
