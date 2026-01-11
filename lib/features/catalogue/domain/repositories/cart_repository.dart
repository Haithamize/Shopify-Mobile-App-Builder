import 'package:flutter/foundation.dart';
import 'package:shopify_flutter/models/src/cart/inputs/attribute_input/attribute_input.dart';
import 'package:shopify_flutter/shopify_flutter.dart' as sf;

import '../../../../core/data/cart/cart_storage.dart';

class CartRepository {
  CartRepository({required this.merchantId, required this.storage});

  final String merchantId;
  final CartStorage storage;

  final sf.ShopifyCart _cartApi = sf.ShopifyCart.instance;

  Future<String?> _readCartId() async {
    final id = await storage.readCartId(merchantId);
    debugPrint("📦 Read cartId=$id for merchantId=$merchantId");
    return id;
  }

  Future<void> _writeCartId(String id) => storage.writeCartId(merchantId, id);

  Future<void> _clearCartId() async {
    debugPrint("🧹 Clearing cartId for merchantId=$merchantId");
    await storage.clearCartId(merchantId);
  }

  /// Create an empty cart (no lines) using CartInput.
  Future<sf.Cart> _createEmptyCart() async {
    final input = sf.CartInput(
      attributes: [
        AttributeInput(key: 'source', value: 'Haitham Store'),
        AttributeInput(key: 'platform', value: 'Android 15'),
        AttributeInput(key: 'app_version', value: '1.0.0'),
      ],
    );

    final created = await _cartApi.createCart(input);
    await _writeCartId(created.id);
    return created;
  }

  Future<sf.Cart> getOrCreateCart() async {
    final existingId = await _readCartId();

    if (existingId != null) {
      try {
        final cart = await _cartApi.getCartById(existingId);
        if (cart != null) return cart;

        // Shopify returned null -> cart not found/expired
        await _clearCartId();
      } catch (e) {
        debugPrint('⚠️ getCartById failed ($existingId), recreate: $e');
        await _clearCartId();
      }
    }

    return _createEmptyCart();
  }

  Future<sf.Cart> refresh() async {
    final cart = await getOrCreateCart();
    final fresh = await _cartApi.getCartById(cart.id);
    if (fresh != null) return fresh;

    // If Shopify says cart missing, recreate
    await _clearCartId();
    return _createEmptyCart();
  }

  Future<sf.Cart> addVariant({
    required String merchandiseId, // Variant ID (gid)
    required int quantity,
  }) async {
    final cart = await getOrCreateCart();

    final inputs = <sf.CartLineUpdateInput>[
      sf.CartLineUpdateInput(merchandiseId: merchandiseId, quantity: quantity),
    ];

    final updated = await _cartApi.addLineItemsToCart(
      cartId: cart.id,
      cartLineInputs: inputs,
    );

    return updated;
  }

  /// Update quantity for an existing line.
  ///
  /// IMPORTANT: your SDK requires merchandiseId in CartLineUpdateInput, even for updates.
  /// So we must pass BOTH lineId + merchandiseId + quantity.
  Future<sf.Cart> updateLineQty({
    required String lineId,
    required String merchandiseId,
    required int quantity,
  }) async {
    final cart = await getOrCreateCart();

    final inputs = <sf.CartLineUpdateInput>[
      sf.CartLineUpdateInput(
        id: lineId,
        merchandiseId: merchandiseId,
        quantity: quantity,
      ),
    ];

    final updated = await _cartApi.updateLineItemsInCart(
      cartId: cart.id,
      cartLineInputs: inputs,
    );

    return updated;
  }

  Future<sf.Cart> removeLine({required String lineId}) async {
    final cart = await getOrCreateCart();

    final updated = await _cartApi.removeLineItemsFromCart(
      cartId: cart.id,
      lineIds: [lineId],
    );

    return updated;
  }

  Future<String> getCheckoutUrl() async {
    final cart = await refresh();
    final url = cart.checkoutUrl;
    if (url == null || url.isEmpty) {
      throw Exception('Cart checkoutUrl is missing.');
    }
    return url;
  }

  Future<sf.Cart> clearAfterCheckout() async {
    await _clearCartId();

    // Create new empty cart (writes new id)
    final created = await _createEmptyCart();

    // IMPORTANT: re-fetch it to get a clean snapshot (and avoid stale/cached fields)
    final fresh = await _cartApi.getCartById(created.id);
    return fresh ?? created;
  }
}
