import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../ui/screens/cart/cart_screen.dart';
import '../../ui/screens/categories/categories_screen.dart';
import '../../ui/screens/collections/collections_screen.dart';
import '../../ui/screens/home/home_screen.dart';
import '../../ui/screens/orders/order_details.dart';
import '../../ui/screens/product/all_products_screen.dart';
import '../../ui/screens/product/product_screen.dart';
import '../../ui/screens/shell/bottom_shell.dart';

/// Root navigator key:
/// - used for top-level navigation
/// - DeepLinkService can navigate with GoRouter
final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

/// AppRouter:
/// - owns the GoRouter instance
/// - defines all routes (tabs + deep link routes)
/// - deep links are already handled by your DeepLinkService:
///     it normalizes URIs to router paths (e.g. /product/9)
class AppRouter {
  AppRouter();

  late final GoRouter router = GoRouter(
    navigatorKey: rootNavigatorKey,

    // This is the first screen shown.
    // Using '/home' here because we now use a tab shell.
    initialLocation: '/home',

    routes: [
      /// Tab shell:
      /// - Home tab branch
      /// - Cart tab branch
      ///
      /// Each branch can have its own nested navigation stack.
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return BottomShell(navigationShell: navigationShell);
        },
        branches: [
          // 0) Home
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          // 1) Categories (TAB)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/categories',
                builder: (context, state) => const CategoriesScreen(),
              ),
            ],
          ),
          // 2) Collections
          StatefulShellBranch(routes: [
            GoRoute(path: '/collections', builder: (_, __) => const CollectionsScreen()),
          ]),
          // 3) Cart
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/cart',
                builder: (context, state) => const CartScreen(),
              ),
            ],
          ),
        ],
      ),

      /// Deep link routes:
      /// Your DeepLinkService normalizes:
      /// - shopifyme://product/9 -> /product/9
      /// - https://domain.com/product/9 -> /product/9
      GoRoute(
        path: '/product/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return ProductScreen(productId: id);
        },
      ),

      GoRoute(
        path: '/products',
        builder: (context, state) => const AllProductsScreen(),
      ),

      GoRoute(
        path: '/orders/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return OrderDetailsScreen(orderId: id);
        },
      ),
    ],
  );
}
