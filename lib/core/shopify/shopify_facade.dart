import 'package:shopify_flutter/shopify_flutter.dart' as sf;

/// Your app talks ONLY to this interface.
/// Later you can add another SDK without changing your app/business logic.
abstract class ShopifyFacade {
  /// Fetch products (paged via cursor).
  /// Returns both products and nextCursor (if available).
  Future<ShopifyProductsPage> fetchProductsPage({
    required int limit,
    String? cursor,
  });
  Future<ShopifyHealthResult> healthCheck();
  Future<sf.Product> fetchProductById(String productId);
}

/// Small DTO returned by the facade.
class ShopifyProductsPage {
  final List<sf.Product> products;
  final String? nextCursor;
  const ShopifyProductsPage({required this.products, required this.nextCursor});
}

class ShopifyHealthResult {
  final bool ok;
  final String message;
  final String? shopName;
  final int? productCountSample;

  const ShopifyHealthResult({
    required this.ok,
    required this.message,
    this.shopName,
    this.productCountSample,
  });
}
