import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Keep your naming: WhiteLabelApp is in main.dart currently.
import '../../main.dart' show WhiteLabelApp;

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

class AppRouter {
  AppRouter();

  late final GoRouter router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const WhiteLabelApp(),
      ),

      // ✅ Example routes – keep these even if you don’t have screens yet.
      // You can later replace builders with real pages.
      GoRoute(
        path: '/orders/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return Scaffold(
            appBar: AppBar(title: Text('Order $id')),
            body: Center(child: Text('Order details for $id')),
          );
        },
      ),
      GoRoute(
        path: '/product/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return Scaffold(
            appBar: AppBar(title: Text('Product $id')),
            body: Center(child: Text('Product details for $id')),
          );
        },
      ),
    ],
  );
}
