import 'dart:convert';
import 'package:shopify_flutter/shopify_flutter.dart' as sf;

import '../../../../core/data/db/app_database.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/shopify/shopify_facade.dart';

/// Single repository:
/// - Fetch from Shopify if online
/// - Save JSON cache per (merchantId + queryKey)
/// - If offline (or Shopify fails), return cache if present
class ProductsRepository {
  ProductsRepository({
    required this.merchantId,
    required this.shopify,
    required this.db,
    required this.networkInfo,
  });

  final String merchantId;
  final ShopifyFacade shopify;
  final AppDatabase db;
  final NetworkInfo networkInfo;

  /// Keep queryKey very stable (so it caches properly).
  /// Example: "products:limit=30"
  Future<List<sf.Product>> getProducts({
    required int limit,
    bool forceRefresh = false,
  }) async {
    final queryKey = 'products:limit=$limit';

    // If not forcing refresh, try cache first for instant UI
    if (!forceRefresh) {
      final cached = await _readCache(queryKey);
      if (cached != null && cached.isNotEmpty) {
        // In parallel, you can refresh in background later (optional).
        // Keeping it simple: just return cached immediately.
        return cached;
      }
    }

    // If offline -> return cache (if any)
    if (!await networkInfo.isOnline) {
      return (await _readCache(queryKey)) ?? <sf.Product>[];
    }

    // Online -> fetch
    // Online -> fetch
    try {
      final page = await shopify.fetchProductsPage(limit: limit, cursor: null);

      // ✅ LOG: tell us if Shopify returned 0 vs N
      // ignore: avoid_print
      print('🛒 Shopify fetchProductsPage(limit=$limit) -> ${page.products.length} products '
          '(merchantId=$merchantId, queryKey=$queryKey)');

      if (page.products.isNotEmpty) {
        // ignore: avoid_print
        print('🛒 First product: id=${page.products.first.id} title=${page.products.first.title}');
      }

      await _writeCache(queryKey, page.products);
      return page.products;
    } catch (e, st) {
      // ✅ LOG THE REAL ERROR (this is what you need right now)
      // ignore: avoid_print
      print('❌ Shopify fetchProductsPage FAILED (merchantId=$merchantId, queryKey=$queryKey): $e');
      // ignore: avoid_print
      print(st);

      // fallback to cache IF it exists
      final cached = await _readCache(queryKey);
      if (cached != null && cached.isNotEmpty) return cached;

      // ✅ If no cache, THROW so Bloc emits ProductsError and you SEE it
      throw Exception(_friendlyShopifyError(e));
    }
  }

  String _friendlyShopifyError(Object e) {
    final msg = e.toString();

    if (msg.contains('SocketException') || msg.contains('Failed host lookup')) {
      return 'No internet connection.';
    }
    if (msg.contains('401') || msg.contains('Unauthorized')) {
      return 'Storefront token is invalid / missing.';
    }
    if (msg.contains('403') || msg.contains('Forbidden')) {
      return 'Storefront access denied (check Storefront API permissions).';
    }
    return 'Failed to load products: $msg';
  }


  Future<List<sf.Product>?> _readCache(String queryKey) async {
    final jsonStr = await db.readCachedJson(
      merchantId: merchantId,
      queryKey: queryKey,
    );
    if (jsonStr == null || jsonStr.isEmpty) return null;

    try {
      final decoded = jsonDecode(jsonStr);
      if (decoded is! List) return null;

      final out = <sf.Product>[];
      for (final item in decoded) {
        if (item is Map) {
          try {
            out.add(sf.Product.fromJson(Map<String, dynamic>.from(item)));
          } catch (_) {
            // skip bad item (plugin model changed / null strict fields)
          }
        }
      }

      // If everything failed, treat cache as invalid
      if (out.isEmpty) {
        await db.writeCachedJson(
          merchantId: merchantId,
          queryKey: queryKey,
          json: '',
          updatedAt: DateTime.now().millisecondsSinceEpoch,
        );
        return null;
      }

      return out;
    } catch (_) {
      // Corrupted cache
      await db.writeCachedJson(
        merchantId: merchantId,
        queryKey: queryKey,
        json: '',
        updatedAt: DateTime.now().millisecondsSinceEpoch,
      );
      return null;
    }
  }

  Future<void> _writeCache(String queryKey, List<sf.Product> products) async {
    final list = products.map((p) => p.toJson()).toList(growable: false);
    await db.writeCachedJson(
      merchantId: merchantId,
      queryKey: queryKey,
      json: jsonEncode(list),
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );
  }
}
