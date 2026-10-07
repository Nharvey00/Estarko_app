import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../../shared/widgets/skeleton_loader.dart';
import '../../auth/providers/auth_provider.dart';
import '../../listings/models/listing_model.dart';
import '../../tenant/views/property_detail_screen.dart';
import '../providers/favorite_provider.dart';
import '../services/favorite_service.dart';

class FavoritesScreen extends StatefulWidget {
  final String? userId;
  final FavoriteService? favoriteService;

  const FavoritesScreen({
    super.key,
    this.userId,
    this.favoriteService,
  });

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  late final FavoriteService _favoriteService;

  @override
  void initState() {
    super.initState();
    _favoriteService = widget.favoriteService ?? FavoriteService();
  }

  String _getTenantId(BuildContext context) {
    if (widget.userId != null && widget.userId!.isNotEmpty) {
      return widget.userId!;
    }
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.currentUser != null &&
          authProvider.currentUser!.uid.isNotEmpty) {
        return authProvider.currentUser!.uid;
      }
    } catch (_) {}
    return FirebaseAuth.instance.currentUser?.uid ?? '';
  }

  void _navigateToDetail(BuildContext context, ListingModel listing) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PropertyDetailScreen(listing: listing),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 48.0),
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
                Icons.favorite_border_rounded,
                size: 72.0,
                color: Colors.grey.shade400,
              ),
            ),
            const SizedBox(height: 24.0),
            const Text(
              'No saved properties',
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
              'Tap the heart icon on a listing to save it here.',
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

  Widget _buildLoadingState() {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      itemCount: 4,
      separatorBuilder: (context, index) => const SizedBox(height: 12.0),
      itemBuilder: (context, index) {
        return EstarSkeleton(
          height: 114.0,
          width: double.infinity,
          borderRadius: BorderRadius.circular(16.0),
        );
      },
    );
  }

  Widget _buildPropertyCard(
    BuildContext context,
    ListingModel listing,
    String userId,
  ) {
    final hasImage = listing.imageUrls.isNotEmpty;
    final firstImage = hasImage ? listing.imageUrls.first : '';

    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 10.0,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _navigateToDetail(context, listing),
          borderRadius: BorderRadius.circular(16.0),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                // Thumbnail
                ClipRRect(
                  borderRadius: BorderRadius.circular(12.0),
                  child: SizedBox(
                    width: 90.0,
                    height: 90.0,
                    child: hasImage && firstImage.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: firstImage,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => const EstarSkeleton(
                              width: 90.0,
                              height: 90.0,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(12.0)),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: Colors.grey.shade100,
                              child: Icon(
                                Icons.holiday_village_outlined,
                                color: Colors.grey.shade400,
                                size: 32.0,
                              ),
                            ),
                          )
                        : Container(
                            color: Colors.grey.shade100,
                            child: Icon(
                              Icons.holiday_village_outlined,
                              color: Colors.grey.shade400,
                              size: 32.0,
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 14.0),

                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        listing.title,
                        style: const TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF111827),
                          letterSpacing: -0.3,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4.0),
                      if (listing.address.isNotEmpty)
                        Row(
                          children: [
                            Icon(
                              Icons.location_on_outlined,
                              size: 13.0,
                              color: Colors.grey.shade500,
                            ),
                            const SizedBox(width: 4.0),
                            Expanded(
                              child: Text(
                                listing.address,
                                style: TextStyle(
                                  fontSize: 12.0,
                                  color: Colors.grey.shade500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      const SizedBox(height: 8.0),
                      Text(
                        '₱${listing.monthlyRate.toStringAsFixed(0)} /mo',
                        style: const TextStyle(
                          fontSize: 17.0,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFFE11D48),
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                ),

                // Heart Icon
                Consumer<FavoriteProvider>(
                  builder: (context, favProvider, _) {
                    final isFav = favProvider.isFavorite(listing.id);
                    return IconButton(
                      icon: Icon(
                        isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                        color: isFav ? const Color(0xFFE11D48) : Colors.grey.shade400,
                        size: 22.0,
                      ),
                      tooltip: isFav ? 'Remove from saved' : 'Save property',
                      onPressed: () {
                        if (userId.isNotEmpty) {
                          favProvider.toggleFavorite(userId, listing);
                        }
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userId = _getTenantId(context);

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SafeArea(
        child: StreamBuilder<List<ListingModel>>(
          stream: _favoriteService.getFavorites(userId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.fromLTRB(20.0, 16.0, 20.0, 8.0),
                    child: Text(
                      'Saved Properties',
                      style: TextStyle(
                        fontSize: 34.0,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1.0,
                        color: Color(0xFF111827),
                      ),
                    ),
                  ),
                  Expanded(child: _buildLoadingState()),
                ],
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Text(
                    'Failed to load saved properties: ${snapshot.error}',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ),
              );
            }

            final listings = snapshot.data ?? [];
            if (listings.isEmpty) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.fromLTRB(24.0, 16.0, 24.0, 8.0),
                    child: Text(
                      'Saved Properties',
                      style: TextStyle(
                        fontSize: 34.0,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1.0,
                        color: Color(0xFF111827),
                      ),
                    ),
                  ),
                  Expanded(child: _buildEmptyState()),
                ],
              );
            }

            return ListView(
              padding: const EdgeInsets.fromLTRB(24.0, 16.0, 24.0, 120.0),
              children: [
                const Text(
                  'Saved Properties',
                  style: TextStyle(
                    fontSize: 34.0,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1.0,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 6.0),
                Text(
                  'Properties you have bookmarked for later.',
                  style: TextStyle(
                    fontSize: 15.0,
                    color: Colors.grey.shade500,
                  ),
                ),
                const SizedBox(height: 24.0),
                ...listings.map(
                  (listing) => _buildPropertyCard(context, listing, userId),
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
