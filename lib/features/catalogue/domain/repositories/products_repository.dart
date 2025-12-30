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
    try {
      final page = await shopify.fetchProductsPage(limit: limit, cursor: null);
      await _writeCache(queryKey, page.products);
      return page.products;
    } catch (_) {
      // Shopify failed -> fallback to cache
      return (await _readCache(queryKey)) ?? <sf.Product>[];
    }
  }

  Future<List<sf.Product>?> _readCache(String queryKey) async {
    final jsonStr = await db.readCachedJson(
      merchantId: merchantId,
      queryKey: queryKey,
    );
    if (jsonStr == null || jsonStr.isEmpty) return null;

    final decoded = jsonDecode(jsonStr);
    if (decoded is! List) return null;

    return decoded
        .whereType<Map>()
        .map((m) => sf.Product.fromJson(Map<String, dynamic>.from(m)))
        .toList(growable: false);
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
