import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../favorites/providers/favorite_provider.dart';
import '../../favorites/views/favorites_screen.dart';
import '../../profile/views/profile_screen.dart';
import '../../../shared/widgets/estar_floating_nav_dock.dart';
import 'tenant_dashboard_screen.dart';
import 'tenant_inquiries_screen.dart';

class TenantMainScreen extends StatefulWidget {
  const TenantMainScreen({super.key});

  @override
  State<TenantMainScreen> createState() => _TenantMainScreenState();
}

class _TenantMainScreenState extends State<TenantMainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    TenantDashboardScreen(),
    FavoritesScreen(),
    TenantInquiriesScreen(),
    ProfileScreen(),
  ];

  static const List<EstarDockItem> _dockItems = [
    EstarDockItem(
      icon: Icons.explore_outlined,
      activeIcon: Icons.explore_rounded,
      label: 'Discover',
    ),
    EstarDockItem(
      icon: Icons.favorite_border_rounded,
      activeIcon: Icons.favorite_rounded,
      label: 'Saved',
    ),
    EstarDockItem(
      icon: Icons.chat_bubble_outline_rounded,
      activeIcon: Icons.chat_bubble_rounded,
      label: 'Inquiries',
    ),
    EstarDockItem(
      icon: Icons.person_outline_rounded,
      activeIcon: Icons.person_rounded,
      label: 'Profile',
    ),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initFavorites();
    });
  }

  void _initFavorites() {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userId = authProvider.currentUser?.uid ??
          FirebaseAuth.instance.currentUser?.uid ??
          '';
      if (userId.isNotEmpty) {
        Provider.of<FavoriteProvider>(context, listen: false).initForUser(userId);
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      extendBody: true,
      body: Stack(
        children: [
          // Content screens extend all the way behind the floating nav dock
          Positioned.fill(
            child: IndexedStack(
              index: _selectedIndex,
              children: _screens,
            ),
          ),

          // Floating iOS-Style Navigation Dock
          Positioned(
            left: 0,
            right: 0,
            bottom: bottomPadding > 0 ? bottomPadding + 6.0 : 18.0,
            child: EstarFloatingNavDock(
              currentIndex: _selectedIndex,
              onTap: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              items: _dockItems,
            ),
          ),
        ],
      ),
    );
  }
}

