import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../config/deeplink/merchant_context_service.dart';


class DeepLinkService {
  DeepLinkService(this._router, this._merchantContext);

  final GoRouter _router;
  final MerchantContextService _merchantContext;

  final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri>? _sub;

  Future<void> init() async {
    try {
      final initial = await _appLinks.getInitialLink();
      if (initial != null) {
        debugPrint('🔗 initial link: $initial');
        await _handleUri(initial);
      }
    } catch (e) {
      debugPrint('⚠️ getInitialLink error: $e');
    }

    _sub = _appLinks.uriLinkStream.listen(
          (uri) async {
        debugPrint('🔗 uri stream: $uri');
        await _handleUri(uri);
      },
      onError: (e) => debugPrint('⚠️ uriLinkStream error: $e'),
    );
  }

  void dispose() {
    _sub?.cancel();
    _sub = null;
  }

  void openFromString(String? value) {
    if (value == null || value.trim().isEmpty) return;
    final uri = Uri.tryParse(value.trim());
    if (uri == null) {
      debugPrint('⚠️ Invalid deeplink string: $value');
      return;
    }
    _handleUri(uri);
  }

  Future<void> _handleUri(Uri uri) async {
    final parsed = _parse(uri);
    if (parsed == null) return;

    if (parsed.merchantId != null && parsed.merchantId!.isNotEmpty) {
      try {
        await _merchantContext.switchTo(parsed.merchantId!);
      } catch (e) {
        debugPrint('❌ merchant switch failed: $e');
        return;
      }
    }

    debugPrint('🧭 deeplink normalized → ${parsed.path}');

    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        _router.go(parsed.path);
      } catch (e) {
        debugPrint('❌ router.go failed for "${parsed.path}": $e');
      }
    });
  }

  _ParsedLink? _parse(Uri uri) {
    // Universal links
    if (uri.scheme == 'http' || uri.scheme == 'https') {
      return _fromPath(uri.path, uri.queryParameters);
    }

    // Custom scheme: shopifyme://...
    if (uri.scheme == 'shopifyme') {
      final combined = '/${uri.host}${uri.path}'; // host is first segment
      return _fromPath(combined, uri.queryParameters);
    }

    return null;
  }

  _ParsedLink? _fromPath(String path, Map<String, String> qp) {
    final segments = Uri.parse(path).pathSegments;
    if (segments.isEmpty) return const _ParsedLink(path: '/');

    // ✅ Demo schema: /m/<merchantId>/<route...>
    if (segments.length >= 2 && segments.first == 'm') {
      final merchantId = segments[1];
      final rest = segments.skip(2).join('/');
      final routePath = rest.isEmpty ? '/' : '/$rest';
      return _ParsedLink(
        merchantId: merchantId,
        path: _applyQuery(routePath, qp),
      );
    }

    // Dedicated schema: /product/123 etc.
    return _ParsedLink(path: _applyQuery('/${segments.join('/')}', qp));
  }

  String _applyQuery(String path, Map<String, String> qp) {
    if (qp.isEmpty) return path;
    return Uri(path: path, queryParameters: qp).toString();
  }
}

class _ParsedLink {
  const _ParsedLink({required this.path, this.merchantId});
  final String path;
  final String? merchantId;
}
