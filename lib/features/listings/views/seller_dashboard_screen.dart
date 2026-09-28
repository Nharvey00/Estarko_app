import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../../shared/widgets/skeleton_loader.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/listing_model.dart';
import '../services/listing_service.dart';
import '../../inquiries/views/seller_inbox_screen.dart';
import 'create_listing_screen.dart';

class SellerDashboardScreen extends StatefulWidget {
  const SellerDashboardScreen({super.key});

  @override
  State<SellerDashboardScreen> createState() => _SellerDashboardScreenState();
}

class _SellerDashboardScreenState extends State<SellerDashboardScreen> {
  final ListingService _listingService = ListingService();

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

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.holiday_village_outlined,
                size: 72.0,
                color: Colors.grey.shade400,
              ),
            ),
            const SizedBox(height: 24.0),
            const Text(
              'No properties listed',
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
              'You have not added any properties yet. Tap the button below to publish your first listing.',
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

  Widget _buildListingCard(BuildContext context, ListingModel listing) {
    final hasImage = listing.imageUrls.isNotEmpty;
    final firstImage = hasImage ? listing.imageUrls.first : '';

    return Container(
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
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // First property image with CachedNetworkImage
          if (hasImage && firstImage.isNotEmpty)
            SizedBox(
              height: 180.0,
              width: double.infinity,
              child: CachedNetworkImage(
                imageUrl: firstImage,
                fit: BoxFit.cover,
                placeholder: (context, url) => const EstarSkeleton(
                  height: 180.0,
                  width: double.infinity,
                ),
                errorWidget: (context, url, error) => Container(
                  height: 180.0,
                  color: Colors.grey.shade100,
                  child: Center(
                    child: Icon(
                      Icons.holiday_village_outlined,
                      size: 48.0,
                      color: Colors.grey.shade400,
                    ),
                  ),
                ),
              ),
            )
          else
            Container(
              height: 140.0,
              width: double.infinity,
              color: Colors.grey.shade100,
              child: Center(
                child: Icon(
                  Icons.holiday_village_outlined,
                  size: 48.0,
                  color: Colors.grey.shade400,
                ),
              ),
            ),

          Padding(
            padding: const EdgeInsets.all(18.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        listing.title,
                        style: const TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF111827),
                          letterSpacing: -0.5,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    Text(
                      '₱${listing.monthlyRate.toStringAsFixed(0)}/mo',
                      style: const TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFFE11D48),
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
                if (listing.address.isNotEmpty) ...[
                  const SizedBox(height: 6.0),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 14.0,
                        color: Colors.grey.shade500,
                      ),
                      const SizedBox(width: 4.0),
                      Expanded(
                        child: Text(
                          listing.address,
                          style: TextStyle(
                            fontSize: 13.0,
                            color: Colors.grey.shade500,
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
                    runSpacing: 4.0,
                    children: listing.amenities.take(4).map((amenity) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8.0,
                          vertical: 4.0,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(6.0),
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
                const SizedBox(height: 14.0),
                const Divider(color: Color(0xFFF1F5F9), height: 1.0),
                const SizedBox(height: 8.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Transform.scale(
                          scale: 0.85,
                          child: Switch.adaptive(
                            value: listing.isAvailable,
                            activeThumbColor: const Color(0xFFE11D48),
                            activeTrackColor: const Color(0xFFFECDD3),
                            onChanged: (newValue) async {
                              await _listingService.updateListingAvailability(
                                listing.id,
                                newValue,
                              );
                            },
                          ),
                        ),
                        Text(
                          listing.isAvailable ? 'Active' : 'Inactive',
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
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Delete Listing'),
                            content: const Text(
                              'Are you sure you want to permanently delete this listing?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, false),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, true),
                                child: const Text(
                                  'Delete',
                                  style: TextStyle(color: Color(0xFFE11D48)),
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
        actions: [
          IconButton(
            icon: const Icon(
              Icons.mail_outline_rounded,
              color: Color(0xFF111827),
            ),
            tooltip: 'Your Leads',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SellerInboxScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(
              Icons.logout_rounded,
              color: Color(0xFF111827),
            ),
            tooltip: 'Log Out',
            onPressed: () {
              Provider.of<AuthProvider>(context, listen: false).logout();
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CreateListingScreen(),
            ),
          );
        },
        backgroundColor: const Color(0xFFE11D48),
        foregroundColor: Colors.white,
        elevation: 6.0,
        shape: const CircleBorder(),
        child: const Icon(Icons.add_rounded, size: 28.0),
      ),
      body: SafeArea(
        child: StreamBuilder<List<ListingModel>>(
          stream: _listingService.getSellerListings(sellerId),
          builder: (context, snapshot) {
            // Loading State: ListView.builder of EstarSkeleton widgets
            if (snapshot.connectionState == ConnectionState.waiting) {
              return ListView.builder(
                padding: const EdgeInsets.all(24.0),
                itemCount: 5,
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
                      const Text(
                        'Failed to load properties',
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF111827),
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

            final listings = snapshot.data ?? [];

            // Empty State
            if (listings.isEmpty) {
              return _buildEmptyState();
            }

            // Data State: Elevated white cards wrapped in staggered cascade
            return ListView(
              padding: const EdgeInsets.fromLTRB(24.0, 8.0, 24.0, 88.0),
              children: [
                const Text(
                  'Your Properties',
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
                  'Manage your active listings and rental properties.',
                  style: TextStyle(
                    fontSize: 15.0,
                    color: Colors.grey.shade500,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24.0),
                ...listings.map(
                  (listing) => Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: _buildListingCard(context, listing),
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
