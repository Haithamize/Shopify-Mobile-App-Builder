import 'package:flutter/cupertino.dart';
import 'package:shopify_flutter/enums/enums.dart';
import 'package:shopify_flutter/shopify_flutter.dart' as sf;
import 'shopify_facade.dart';

/// Simple Shopify facade using shopify_flutter 2.6.1 APIs.
/// Uses ShopifyStore.instance as required.
class ShopifyFlutterFacade implements ShopifyFacade {
  final sf.ShopifyStore _store = sf.ShopifyStore.instance;

  @override
  Future<ShopifyProductsPage> fetchProductsPage({
    required int limit,
    String? cursor, // ignored for now (keep interface future-proof)
  }) async {
    final all = await _store.getAllProducts();

    // Some versions may return nullable; handle defensively.
    final safe = (all ?? const <sf.Product>[]);
    final limited = safe.length <= limit ? safe : safe.take(limit).toList(growable: false);

    return ShopifyProductsPage(products: limited, nextCursor: null);
  }

  @override
  Future<ShopifyHealthResult> healthCheck() async {
    try {
      final shop = await sf.ShopifyStore.instance.getShop();

      final products = await sf.ShopifyStore.instance.getNProducts(
        5,
        sortKey: SortKeyProduct.TITLE,
      );

      return ShopifyHealthResult(
        ok: true,
        message: '✅ Shopify Storefront OK',
        shopName: shop.name,
        productCountSample: products?.length,
      );
    } catch (e, st) {
      debugPrint('❌ Shopify healthCheck failed (${e.runtimeType}): $e');
      debugPrint('$st');

      // best-effort extra fields (won’t crash)
      try {
        final dyn = e as dynamic;
        if (dyn.errors != null) debugPrint('❌ errors: ${dyn.errors}');
        if (dyn.message != null) debugPrint('❌ message: ${dyn.message}');
        if (dyn.statusCode != null) debugPrint('❌ statusCode: ${dyn.statusCode}');
        if (dyn.graphQLErrors != null) debugPrint('❌ graphQLErrors: ${dyn.graphQLErrors}');
      } catch (_) {}

      return ShopifyHealthResult(
        ok: false,
        message: '❌ Shopify failed: $e',
      );
    }
  }

  @override
  Future<sf.Product> fetchProductById(String productId) async {
    try {
      final all = await _store.getAllProducts();
      final list = all ?? const <sf.Product>[];

      final match = list.firstWhere(
            (p) => p.id.toString() == productId,
        orElse: () => throw Exception('Product not found: $productId'),
      );

      return match;
    } catch (e) {
      throw Exception('Failed to load product details: $e');
    }
  }
}
