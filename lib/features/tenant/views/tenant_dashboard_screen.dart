import 'dart:ui' as ui;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' hide Path;
import 'package:provider/provider.dart';

import '../../../shared/widgets/estar_friendly_error.dart';
import '../../../shared/widgets/skeleton_loader.dart';
import '../../auth/providers/auth_provider.dart';
import '../../favorites/providers/favorite_provider.dart';
import '../../listings/models/listing_model.dart';
import '../../listings/services/listing_service.dart';
import 'property_detail_screen.dart';

/// Task 1: Tenant Discovery Dashboard with Airbnb-Style Map/List Toggle.
/// Features:
/// - 100% Full-Screen Interactive Map Mode with pulsing blue location dot & carousel
/// - Full-Screen Vertical List View Mode with pristine white iOS property cards (clearing dock by 120px)
/// - Floating glassmorphic pill button switching between "Show List" and "Show Map"
class TenantDashboardScreen extends StatefulWidget {
  const TenantDashboardScreen({super.key});

  @override
  State<TenantDashboardScreen> createState() => _TenantDashboardScreenState();
}

class _TenantDashboardScreenState extends State<TenantDashboardScreen> {
  final ListingService _listingService = ListingService();
  final MapController _mapController = MapController();
  late final PageController _pageController;

  static const LatLng _userLocation = LatLng(7.0736, 125.6110); // Davao City core
  int _selectedListingIndex = 0;
  bool _isCarouselVisible = true;
  bool _isListView = false; // Airbnb-style toggle state

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.88);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _navigateToDetail(BuildContext context, ListingModel listing) {
    HapticFeedback.lightImpact();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PropertyDetailScreen(listing: listing),
      ),
    );
  }

  void _selectListing(int index, List<ListingModel> listings) {
    if (index < 0 || index >= listings.length) return;

    setState(() {
      _selectedListingIndex = index;
      _isCarouselVisible = true;
    });

    final listing = listings[index];
    if (listing.latitude != 0.0 && listing.longitude != 0.0) {
      _mapController.move(
        LatLng(listing.latitude, listing.longitude),
        14.5,
      );
    }

    if (_pageController.hasClients) {
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _recenterToUser() {
    HapticFeedback.selectionClick();
    _mapController.move(_userLocation, 14.0);
  }

  // Minimalist Custom Marker Pin (Rule: Clean, uncluttered, no massive price tags)
  Marker _buildPropertyMarker({
    required ListingModel listing,
    required int index,
    required bool isSelected,
    required List<ListingModel> allListings,
  }) {
    return Marker(
      point: LatLng(listing.latitude, listing.longitude),
      width: isSelected ? 48.0 : 36.0,
      height: isSelected ? 48.0 : 36.0,
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          _selectListing(index, allListings);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isSelected ? const Color(0xFFE11D48) : Colors.white,
            border: Border.all(
              color: isSelected ? Colors.white : const Color(0xFFE11D48),
              width: isSelected ? 2.5 : 2.0,
            ),
            boxShadow: [
              BoxShadow(
                color: isSelected
                    ? const Color(0xFFE11D48).withValues(alpha: 0.50)
                    : Colors.black.withValues(alpha: 0.15),
                blurRadius: isSelected ? 16.0 : 8.0,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Center(
            child: Icon(
              Icons.roofing_rounded,
              color: isSelected ? Colors.white : const Color(0xFFE11D48),
              size: isSelected ? 22.0 : 16.0,
            ),
          ),
        ),
      ),
    );
  }

  // Apple Maps / Uber style animated pulsing blue user location indicator
  Marker _buildUserLocationMarker() {
    return const Marker(
      point: _userLocation,
      width: 56.0,
      height: 56.0,
      child: _PulsingLocationIndicator(),
    );
  }

  // Floating Glassmorphic Top Brand Header & Sleek iOS-Style Mode Toggle Pill
  Widget _buildTopHeaderAndToggle(BuildContext context, int totalCount) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Positioned(
      top: topPadding + 8.0,
      left: 16.0,
      right: 16.0,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Glassmorphic Brand & Status Header Card
          ClipRRect(
            borderRadius: BorderRadius.circular(24.0),
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 18.0, sigmaY: 18.0),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 12.0,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.90),
                  borderRadius: BorderRadius.circular(24.0),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.85),
                    width: 1.2,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x0F0B0F19),
                      blurRadius: 20.0,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Brand Badge
                    Container(
                      width: 36.0,
                      height: 36.0,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFB7185), Color(0xFFE11D48)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.roofing_rounded,
                          color: Colors.white,
                          size: 20.0,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12.0),

                    // Location / Subtitle
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'EstarKo Discover',
                            style: TextStyle(
                              fontSize: 15.0,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A),
                              letterSpacing: -0.3,
                            ),
                          ),
                          Text(
                            _isListView
                                ? '$totalCount verified properties'
                                : '$totalCount properties near Davao City',
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Action Button (Re-center in Map mode, Property count indicator in List mode)
                    GestureDetector(
                      onTap: _isListView ? null : _recenterToUser,
                      child: Container(
                        width: 36.0,
                        height: 36.0,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFFE2E8F0),
                            width: 1.0,
                          ),
                        ),
                        child: Icon(
                          _isListView
                              ? Icons.apartment_rounded
                              : Icons.my_location_rounded,
                          color: _isListView
                              ? const Color(0xFFE11D48)
                              : const Color(0xFF2563EB),
                          size: 18.0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 10.0),

          // Anchored Top Center: Sleek iOS-Style Glassmorphic Mode Toggle Pill
          _buildModeTogglePill(),
        ],
      ),
    );
  }

  // Sleek iOS-Style Glassmorphic Mode Toggle Pill
  Widget _buildModeTogglePill() {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() {
          _isListView = !_isListView;
        });
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30.0),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 18.0, sigmaY: 18.0),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 18.0,
              vertical: 9.0,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A).withValues(alpha: 0.90),
              borderRadius: BorderRadius.circular(30.0),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.18),
                width: 1.0,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x2E000000),
                  blurRadius: 18.0,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _isListView
                      ? Icons.map_rounded
                      : Icons.format_list_bulleted_rounded,
                  color: Colors.white,
                  size: 16.0,
                ),
                const SizedBox(width: 8.0),
                Text(
                  _isListView ? 'Show Map' : 'Show List',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Floating Carousel Card representing one property in Map Mode
  Widget _buildCarouselCard(
    BuildContext context,
    ListingModel listing,
    int index,
    int totalCount,
  ) {
    final hasImage = listing.imageUrls.isNotEmpty;
    final firstImage = hasImage ? listing.imageUrls.first : '';
    final isSelected = _selectedListingIndex == index;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6.0),
      child: GestureDetector(
        onTap: () => _navigateToDetail(context, listing),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22.0),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFFE11D48).withValues(alpha: 0.5)
                  : const Color(0xFFE2E8F0).withValues(alpha: 0.8),
              width: isSelected ? 1.8 : 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: isSelected
                    ? const Color(0xFFE11D48).withValues(alpha: 0.18)
                    : Colors.black.withValues(alpha: 0.10),
                blurRadius: isSelected ? 22.0 : 16.0,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              // Property Thumbnail with Hero Animation
              Hero(
                tag: 'property_image_${listing.id}',
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(21.0),
                    bottomLeft: Radius.circular(21.0),
                  ),
                  child: SizedBox(
                    width: 120.0,
                    height: double.infinity,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        if (hasImage && firstImage.isNotEmpty)
                          CachedNetworkImage(
                            imageUrl: firstImage,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => const EstarSkeleton(
                              width: 120.0,
                              height: 140.0,
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: const Color(0xFFF1F5F9),
                              child: const Icon(
                                Icons.apartment_rounded,
                                color: Color(0xFF94A3B8),
                                size: 32.0,
                              ),
                            ),
                          )
                        else
                          Container(
                            color: const Color(0xFFF1F5F9),
                            child: const Icon(
                              Icons.apartment_rounded,
                              color: Color(0xFF94A3B8),
                              size: 32.0,
                            ),
                          ),
                        // Availability Tag
                        Positioned(
                          top: 8.0,
                          left: 8.0,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7.0,
                              vertical: 3.0,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0F172A).withValues(alpha: 0.75),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: const Text(
                              'Verified',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10.0,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Property Information Details
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14.0, 12.0, 14.0, 12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Top Row: Category & Favorite Toggle
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8.0,
                              vertical: 3.0,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF1F2),
                              borderRadius: BorderRadius.circular(6.0),
                            ),
                            child: Text(
                              '${index + 1} of $totalCount',
                              style: const TextStyle(
                                color: Color(0xFFE11D48),
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          // Heart favorite button
                          Consumer<FavoriteProvider>(
                            builder: (context, favProvider, child) {
                              final isFav = favProvider.isFavorite(listing.id);
                              return GestureDetector(
                                onTap: () {
                                  HapticFeedback.lightImpact();
                                  final authProvider = Provider.of<AuthProvider>(
                                    context,
                                    listen: false,
                                  );
                                  final userId =
                                      authProvider.currentUser?.uid ??
                                      FirebaseAuth.instance.currentUser?.uid ??
                                      '';
                                  if (userId.isNotEmpty) {
                                    favProvider.toggleFavorite(userId, listing);
                                  }
                                },
                                child: Container(
                                  width: 30.0,
                                  height: 30.0,
                                  decoration: BoxDecoration(
                                    color: isFav
                                        ? const Color(0xFFFFF1F2)
                                        : const Color(0xFFF8FAFC),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    isFav
                                        ? Icons.favorite_rounded
                                        : Icons.favorite_border_rounded,
                                    color: isFav
                                        ? const Color(0xFFE11D48)
                                        : const Color(0xFF94A3B8),
                                    size: 16.0,
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),

                      // Title
                      Text(
                        listing.title,
                        style: const TextStyle(
                          fontSize: 15.0,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                          letterSpacing: -0.3,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                      // Address
                      if (listing.address.isNotEmpty)
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on_rounded,
                              size: 12.0,
                              color: Color(0xFF64748B),
                            ),
                            const SizedBox(width: 3.0),
                            Expanded(
                              child: Text(
                                listing.address,
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  color: Color(0xFF64748B),
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),

                      // Rate & CTA
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text:
                                      '₱${listing.monthlyRate.toStringAsFixed(0)}',
                                  style: const TextStyle(
                                    fontSize: 16.5,
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFFE11D48),
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                const TextSpan(
                                  text: ' / mo',
                                  style: TextStyle(
                                    fontSize: 11.0,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Row(
                            children: [
                              Text(
                                'View',
                                style: TextStyle(
                                  fontSize: 12.0,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFFE11D48),
                                ),
                              ),
                              Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 10.0,
                                color: Color(0xFFE11D48),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Bottom Swipeable Property Carousel (floating safely above the bottom dock)
  Widget _buildBottomCarousel(
    BuildContext context,
    List<ListingModel> listings,
  ) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final carouselBottom = bottomPadding > 0 ? bottomPadding + 100.0 : 120.0;

    if (!_isCarouselVisible) {
      return Positioned(
        bottom: carouselBottom,
        right: 16.0,
        child: GestureDetector(
          onTap: () {
            setState(() {
              _isCarouselVisible = true;
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(24.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.25),
                  blurRadius: 16.0,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.view_carousel_rounded,
                  color: Colors.white,
                  size: 16.0,
                ),
                const SizedBox(width: 8.0),
                Text(
                  'Show Properties (${listings.length})',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Positioned(
      left: 0,
      right: 0,
      bottom: carouselBottom,
      height: 140.0,
      child: PageView.builder(
        controller: _pageController,
        itemCount: listings.length,
        onPageChanged: (index) {
          HapticFeedback.selectionClick();
          setState(() {
            _selectedListingIndex = index;
          });
          final listing = listings[index];
          if (listing.latitude != 0.0 && listing.longitude != 0.0) {
            _mapController.move(
              LatLng(listing.latitude, listing.longitude),
              _mapController.camera.zoom,
            );
          }
        },
        itemBuilder: (context, index) {
          return _buildCarouselCard(
            context,
            listings[index],
            index,
            listings.length,
          );
        },
      ),
    );
  }

  // Pristine iOS-Grade Card for Vertical List View
  Widget _buildVerticalListCard(BuildContext context, ListingModel listing) {
    final hasImage = listing.imageUrls.isNotEmpty;
    final firstImage = hasImage ? listing.imageUrls.first : '';

    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22.0),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.0),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A0B0F19),
            blurRadius: 24.0,
            offset: Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _navigateToDetail(context, listing),
          borderRadius: BorderRadius.circular(22.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cover Photo with Tags and Favorite Button
              Stack(
                children: [
                  Hero(
                    tag: 'property_image_${listing.id}',
                    child: SizedBox(
                      height: 190.0,
                      width: double.infinity,
                      child: hasImage && firstImage.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: firstImage,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => const EstarSkeleton(
                                height: 190.0,
                                width: double.infinity,
                              ),
                              errorWidget: (context, url, error) => Container(
                                height: 190.0,
                                color: const Color(0xFFF1F5F9),
                                child: const Icon(
                                  Icons.apartment_rounded,
                                  size: 48.0,
                                  color: Color(0xFF94A3B8),
                                ),
                              ),
                            )
                          : Container(
                              height: 190.0,
                              color: const Color(0xFFF1F5F9),
                              child: const Icon(
                                Icons.apartment_rounded,
                                size: 48.0,
                                color: Color(0xFF94A3B8),
                              ),
                            ),
                    ),
                  ),

                  // Verified Pill Overlay
                  Positioned(
                    top: 14.0,
                    left: 14.0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10.0,
                        vertical: 5.0,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F172A).withValues(alpha: 0.82),
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.verified_rounded,
                            size: 13.0,
                            color: Color(0xFF10B981),
                          ),
                          SizedBox(width: 4.0),
                          Text(
                            'Verified',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11.0,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Glassmorphic Favorite Button Overlay
                  Positioned(
                    top: 12.0,
                    right: 12.0,
                    child: Consumer<FavoriteProvider>(
                      builder: (context, favProvider, _) {
                        final isFav = favProvider.isFavorite(listing.id);
                        return ClipOval(
                          child: BackdropFilter(
                            filter: ui.ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
                            child: GestureDetector(
                              onTap: () {
                                HapticFeedback.lightImpact();
                                final authProvider = Provider.of<AuthProvider>(
                                  context,
                                  listen: false,
                                );
                                final userId =
                                    authProvider.currentUser?.uid ??
                                    FirebaseAuth.instance.currentUser?.uid ??
                                    '';
                                if (userId.isNotEmpty) {
                                  favProvider.toggleFavorite(userId, listing);
                                }
                              },
                              child: Container(
                                width: 38.0,
                                height: 38.0,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.85),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  isFav
                                      ? Icons.favorite_rounded
                                      : Icons.favorite_border_rounded,
                                  color: isFav
                                      ? const Color(0xFFE11D48)
                                      : const Color(0xFF0F172A),
                                  size: 18.0,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),

              // Property Information Details
              Padding(
                padding: const EdgeInsets.all(18.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title and Price Row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
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
                        ),
                        const SizedBox(width: 8.0),
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text:
                                    '₱${listing.monthlyRate.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  fontSize: 19.0,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFFE11D48),
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const TextSpan(
                                text: ' / mo',
                                style: TextStyle(
                                  fontSize: 12.0,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    if (listing.address.isNotEmpty) ...[
                      const SizedBox(height: 6.0),
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
                        runSpacing: 4.0,
                        children: listing.amenities.take(3).map((amenity) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10.0,
                              vertical: 4.0,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(8.0),
                              border: Border.all(
                                color: const Color(0xFFE2E8F0),
                              ),
                            ),
                            child: Text(
                              amenity,
                              style: const TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF475569),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Full-Screen Vertical List View (clears floating dock with 130px bottom padding)
  Widget _buildVerticalListView(
    BuildContext context,
    List<ListingModel> listings,
    double topPadding,
  ) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final listBottomPadding = bottomPadding > 0 ? bottomPadding + 130.0 : 130.0;

    if (listings.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.only(
            top: topPadding + 120.0,
            bottom: listBottomPadding,
            left: 16.0,
            right: 16.0,
          ),
          child: const EstarEmptyStateView(
            icon: Icons.holiday_village_outlined,
            title: 'No properties available',
            message:
                'Check back soon as hosts add new listings near campus and workplaces.',
          ),
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.only(
        top: topPadding + 124.0, // Clears the top header and toggle pill by 12px
        left: 16.0,
        right: 16.0,
        bottom: listBottomPadding, // Rule: Clears floating dock comfortably with 130px padding
      ),
      itemCount: listings.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.only(top: 8.0, bottom: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Explore Properties',
                  style: TextStyle(
                    fontSize: 32.0,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1.0,
                    color: Color(0xFF0F172A),
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 6.0),
                Text(
                  '${listings.length} verified listings near your campus or workplace.',
                  style: TextStyle(
                    fontSize: 15.0,
                    color: Colors.grey.shade600,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          );
        }

        final listing = listings[index - 1];
        return _buildVerticalListCard(context, listing)
            .animate(delay: ((index - 1) * 60).ms)
            .fade(duration: 400.ms)
            .slideY(begin: 0.08, curve: Curves.easeOutQuad);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: StreamBuilder<List<ListingModel>>(
        stream: _listingService.getAllAvailableListings(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return EstarErrorView(
              error: snapshot.error,
              title: "Couldn't Load Properties",
              onRetry: () => setState(() {}),
            );
          }

          final listings = snapshot.data ?? [];
          final validListings = listings
              .where((l) => l.latitude != 0.0 && l.longitude != 0.0)
              .toList();

          return Stack(
            children: [
              // Content: Either full-screen Map OR full-screen vertical ListView
              if (_isListView)
                _buildVerticalListView(context, listings, topPadding)
              else
                Positioned.fill(
                  child: FlutterMap(
                    mapController: _mapController,
                    options: const MapOptions(
                      initialCenter: _userLocation,
                      initialZoom: 13.5,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.example.estarko',
                      ),
                      MarkerLayer(
                        markers: [
                          _buildUserLocationMarker(),
                          for (int i = 0; i < validListings.length; i++)
                            _buildPropertyMarker(
                              listing: validListings[i],
                              index: i,
                              isSelected: _selectedListingIndex == i,
                              allListings: validListings,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),

              // Bottom Carousel in Map Mode (hovering 14-16px cleanly above bottom dock)
              if (!_isListView && validListings.isNotEmpty)
                _buildBottomCarousel(context, validListings),

              // Anchored Top Center: Glassmorphic Brand Header & Mode Toggle Pill
              _buildTopHeaderAndToggle(context, validListings.length),
            ],
          );
        },
      ),
    );
  }
}

/// Animated Apple Maps / Uber style pulsing blue dot with expanding radar waves.
class _PulsingLocationIndicator extends StatefulWidget {
  const _PulsingLocationIndicator();

  @override
  State<_PulsingLocationIndicator> createState() =>
      _PulsingLocationIndicatorState();
}

class _PulsingLocationIndicatorState extends State<_PulsingLocationIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat();

    _scaleAnimation = Tween<double>(begin: 0.8, end: 2.4).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutQuad),
    );

    _opacityAnimation = Tween<double>(begin: 0.55, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutQuad),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 56.0,
      height: 56.0,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Expanding radar pulse wave
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: Container(
                  width: 22.0,
                  height: 22.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF2563EB)
                        .withValues(alpha: _opacityAnimation.value),
                  ),
                ),
              );
            },
          ),
          // Subtle soft aura halo
          Container(
            width: 24.0,
            height: 24.0,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF3B82F6).withValues(alpha: 0.22),
            ),
          ),
          // Solid blue center dot with crisp white border
          Container(
            width: 15.0,
            height: 15.0,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF2563EB),
              border: Border.all(color: Colors.white, width: 2.5),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2563EB).withValues(alpha: 0.50),
                  blurRadius: 8.0,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
