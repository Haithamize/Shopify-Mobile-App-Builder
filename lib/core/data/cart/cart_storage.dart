import 'package:shared_preferences/shared_preferences.dart';

/// cart storage per merchant
class CartStorage {
  static String _key(String merchantId) => 'cart_id_$merchantId';

  Future<String?> readCartId(String merchantId) async {
    final sp = await SharedPreferences.getInstance();
    final v = sp.getString(_key(merchantId));
    return (v == null || v.isEmpty) ? null : v;
  }

  Future<void> writeCartId(String merchantId, String cartId) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_key(merchantId), cartId);
  }

  Future<void> clearCartId(String merchantId) async {
    final sp = await SharedPreferences.getInstance();
    await sp.remove(_key(merchantId));
  }
}
