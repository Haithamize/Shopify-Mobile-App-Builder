import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shopify_flutter/models/src/product/product.dart' as sf;
import 'package:shopiney/ui/screens/product/product_details/product_details_screen.dart';

import '../../features/catalogue/bloc/cart/cart_bloc.dart';
import '../../features/catalogue/bloc/cart/cart_event.dart';
import '../../features/catalogue/bloc/product/products_bloc.dart';
import '../../features/catalogue/bloc/product/products_event.dart';
import '../../ui/screens/cart/cart_screen.dart';
import '../../ui/screens/categories/categories_screen.dart';
import '../../ui/screens/collections/collections_screen.dart';
import '../../ui/screens/home/home_screen.dart';
import '../../ui/screens/product/all_products_screen.dart';
import '../../ui/screens/shell/bottom_shell.dart';
import '../di/injection_container.dart';

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
          return MultiBlocProvider(
            providers: [
              /// And for screen-specific blocs (like your ProductsBloc for /products), keep doing what you do now: provide them at the route builder level.
              /// Rule of thumb:
              /// Global state that must persist across tabs → provide in Shell
              /// Feature screens that can be disposed per route → provide in that route
              BlocProvider.value(
                value: sl<CartBloc>()..add(const CartEnsureStarted()),
              ),
              // BlocProvider.value(value: sl<AuthBloc>()..add(const AuthStarted())),
              // etc...
            ],
            child: BottomShell(navigationShell: navigationShell),
          );
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
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/collections',
                builder: (_, __) => const CollectionsScreen(),
              ),
            ],
          ),
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
        path: '/products',
        builder: (context, state) {
          return BlocProvider(
            create: (_) =>
                sl<ProductsBloc>()..add(const LoadProducts(limit: 30)),
            child: const AllProductsScreen(),
          );
        },
      ),

      GoRoute(
        path: '/product/:id',
        pageBuilder: (context, state) {
          final id = Uri.decodeComponent(state.pathParameters['id']!);
          final product = state.extra as sf.Product?;

          return MaterialPage(
            key: state.pageKey, // ✅ key belongs to the Page (not the BlocProvider)
            child: BlocProvider.value(
              value: sl<CartBloc>(), // IMPORTANT: must be the SAME instance (singleton)
              child: ProductDetailsScreen(productId: id, product: product),
            ),
          );
        },
      ),
    ],
  );
}
