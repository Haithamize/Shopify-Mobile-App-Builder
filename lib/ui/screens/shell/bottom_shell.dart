import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// BottomShell is the "chrome" of the app:
/// - It hosts the bottom navigation bar
/// - It displays whichever tab stack is active (Home/Cart/etc.)
///
/// We use StatefulShellRoute (in router) so each tab keeps its own navigation stack.
class BottomShell extends StatelessWidget {
  const BottomShell({super.key, required this.navigationShell});

  /// Provided by GoRouter when using StatefulShellRoute
  final StatefulNavigationShell navigationShell;

  void _onTap(int index) {
    // Switch to another tab/branch.
    // GoRouter keeps the selected tab's stack.
    navigationShell.goBranch(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // This is the tab body (current branch navigator)
      body: navigationShell,

      // Material 3 NavigationBar
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: _onTap,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
              icon: Icon(Icons.grid_view_outlined),
              selectedIcon: Icon(Icons.grid_view),
              label: 'Categories'
          ),
          NavigationDestination(
              icon: Icon(Icons.collections_outlined),
              selectedIcon: Icon(Icons.collections),
              label: 'Collections'
          ),
          NavigationDestination(
            icon: Icon(Icons.shopping_bag_outlined),
            selectedIcon: Icon(Icons.shopping_bag),
            label: 'Cart',
          ),
        ],
      ),
    );
  }
}
