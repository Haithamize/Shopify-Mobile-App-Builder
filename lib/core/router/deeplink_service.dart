import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

class DeepLinkService {
  DeepLinkService(this._router);

  final GoRouter _router;
  final AppLinks _appLinks = AppLinks();

  StreamSubscription<Uri>? _sub;

  Future<void> init() async {
    // 1) Initial link (cold start)
    try {
      final initial = await _appLinks.getInitialLink();
      if (initial != null) {
        debugPrint('🔗 initial link: $initial');
        _handleUri(initial);
      }
    } catch (e) {
      debugPrint('⚠️ getInitialLink error: $e');
    }

    // 2) Stream (app running / resumed)
    _sub = _appLinks.uriLinkStream.listen(
          (uri) {
        debugPrint('🔗 uri stream: $uri');
        _handleUri(uri);
      },
      onError: (e) => debugPrint('⚠️ uriLinkStream error: $e'),
    );
  }

  void dispose() {
    _sub?.cancel();
    _sub = null;
  }

  /// Called from push notifications: data['deeplink'] or data['url']
  void openFromString(String? value) {
    if (value == null || value.trim().isEmpty) return;

    final uri = Uri.tryParse(value.trim());
    if (uri == null) {
      debugPrint('⚠️ Invalid deeplink string: $value');
      return;
    }

    _handleUri(uri);
  }

  void _handleUri(Uri uri) {
    final path = _normalizeToRouterPath(uri);
    if (path == null || path.isEmpty) return;

    debugPrint('🧭 deeplink normalized → $path');

    // ✅ critical: ensure router navigation happens AFTER first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        _router.go(path);
      } catch (e) {
        debugPrint('❌ router.go failed for "$path": $e');
      }
    });
  }

  /// Converts:
  /// - shopifyme://orders/123  -> /orders/123
  /// - shopifyme://product/9   -> /product/9
  /// - https://x.com/orders/1  -> /orders/1
  String? _normalizeToRouterPath(Uri uri) {
    // If this is a universal link like https://domain.com/orders/123
    if (uri.scheme == 'http' || uri.scheme == 'https') {
      return uri.path.isEmpty ? '/' : uri.path;
    }

    // Custom scheme: shopifyme://orders/123
    // Important: in custom scheme URIs, the "host" is the first segment.
    // Example: scheme=shopifyme host=orders path=/123
    final host = uri.host; // "orders"
    final path = uri.path; // "/123"
    if (host.isEmpty) return null;

    final combined = '/$host$path';
    return combined == '/' ? '/' : combined;
  }
}
