import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' hide Path;
import '../../../shared/widgets/skeleton_loader.dart';
import '../../listings/models/listing_model.dart';
import '../../listings/services/listing_service.dart';
import 'property_detail_screen.dart';

class TenantDashboardScreen extends StatefulWidget {
  const TenantDashboardScreen({super.key});

  @override
  State<TenantDashboardScreen> createState() => _TenantDashboardScreenState();
}

class _TenantDashboardScreenState extends State<TenantDashboardScreen> {
  final ListingService _listingService = ListingService();
  final MapController _mapController = MapController();

  void _navigateToDetail(BuildContext context, ListingModel listing) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PropertyDetailScreen(listing: listing),
      ),
    );
  }

  Widget _buildPropertyCard(BuildContext context, ListingModel listing) {
    final hasImage = listing.imageUrls.isNotEmpty;
    final firstImage = hasImage ? listing.imageUrls.first : '';

    return Container(
      margin: const EdgeInsets.only(bottom: 14.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 15.0,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16.0),
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
                              borderRadius: BorderRadius.all(Radius.circular(12.0)),
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
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14.0,
                  color: Color(0xFF94A3B8),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.holiday_village_outlined,
              size: 56.0,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 12.0),
            const Text(
              'No properties available',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.w800,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 6.0),
            Text(
              'Check back soon as hosts add new listings.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.0,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: StreamBuilder<List<ListingModel>>(
        stream: _listingService.getAllAvailableListings(),
        builder: (context, snapshot) {
          final listings = snapshot.data ?? [];
          final isLoading = snapshot.connectionState == ConnectionState.waiting;

          return Stack(
            children: [
              // Base Layer: Full-screen interactive map
              FlutterMap(
                mapController: _mapController,
                options: const MapOptions(
                  initialCenter: LatLng(7.0736, 125.6110),
                  initialZoom: 13.0,
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.estarko',
                  ),
                  MarkerLayer(
                    markers: listings
                        .where((l) => l.latitude != 0.0 && l.longitude != 0.0)
                        .map((listing) {
                      return Marker(
                        point: LatLng(listing.latitude, listing.longitude),
                        width: 44.0,
                        height: 44.0,
                        child: GestureDetector(
                          onTap: () => _navigateToDetail(context, listing),
                          child: const Icon(
                            Icons.location_on,
                            color: Color(0xFFE11D48),
                            size: 40.0,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),

              // Floating Header Bar (Branding)
              Positioned(
                top: MediaQuery.of(context).padding.top + 8.0,
                left: 16.0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 10.0,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24.0),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x14000000),
                        blurRadius: 15.0,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Row(
                    children: [
                      Text(
                        'Estar',
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF111827),
                        ),
                      ),
                      Text(
                        'Ko',
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFFE11D48),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Overlay Layer (Feed): DraggableScrollableSheet
              DraggableScrollableSheet(
                initialChildSize: 0.4,
                minChildSize: 0.1,
                maxChildSize: 0.9,
                builder: (context, scrollController) {
                  return Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(24.0),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0x1A000000),
                          blurRadius: 20.0,
                          offset: Offset(0, -6),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Small grey drag handle
                        Container(
                          margin: const EdgeInsets.only(top: 12.0, bottom: 8.0),
                          width: 40.0,
                          height: 5.0,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(2.5),
                          ),
                        ),

                        // Feed Header Title
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20.0, 4.0, 20.0, 10.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Explore Properties',
                                style: TextStyle(
                                  fontSize: 19.0,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF111827),
                                  letterSpacing: -0.4,
                                ),
                              ),
                              Text(
                                '${listings.length} available',
                                style: TextStyle(
                                  fontSize: 13.0,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const Divider(color: Color(0xFFF1F5F9), height: 1.0),

                        // Feed Content List
                        Expanded(
                          child: isLoading
                              ? ListView.builder(
                                  controller: scrollController,
                                  padding: const EdgeInsets.all(16.0),
                                  itemCount: 4,
                                  itemBuilder: (context, index) {
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 12.0),
                                      child: EstarSkeleton(
                                        height: 104.0,
                                        borderRadius: BorderRadius.circular(16.0),
                                      ),
                                    );
                                  },
                                )
                              : listings.isEmpty
                                  ? _buildEmptyState()
                                  : ListView(
                                      controller: scrollController,
                                      padding: const EdgeInsets.all(16.0),
                                      children: listings
                                          .map((listing) =>
                                              _buildPropertyCard(context, listing))
                                          .toList()
                                          .animate(interval: 100.ms)
                                          .fade(duration: 400.ms)
                                          .slideY(
                                            begin: 0.1,
                                            curve: Curves.easeOutQuad,
                                          ),
                                    ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
