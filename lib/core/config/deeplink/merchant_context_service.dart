import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shopify_flutter/shopify_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../merchant_config.dart';

/// Demo app: can switch merchants at runtime.
/// Dedicated app: fixedMerchantId will lock it.
class MerchantContextService {
  MerchantContextService({
    required Future<MerchantConfig> Function(String merchantId) fetchConfig,
    required String? fixedMerchantId,
  })  : _fetchConfig = fetchConfig,
        _fixedMerchantId = fixedMerchantId;

  static const _prefsKey = 'active_merchant_id';

  final Future<MerchantConfig> Function(String merchantId) _fetchConfig;
  final String? _fixedMerchantId;

  MerchantConfig? _current;
  MerchantConfig? get current => _current;

  String? get merchantId => _current?.merchantId;
  bool get isDedicated => _fixedMerchantId != null;

  Future<MerchantConfig?> restore() async {
    if (_fixedMerchantId != null) {
      return switchTo(_fixedMerchantId!, persist: false);
    }

    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_prefsKey);
    if (saved == null || saved.isEmpty) return null;

    return switchTo(saved, persist: false);
  }

  Future<MerchantConfig> switchTo(
      String merchantId, {
        bool persist = true,
      }) async {
    if (_fixedMerchantId != null && merchantId != _fixedMerchantId) {
      debugPrint('⚠️ Dedicated app ignores merchant switch to $merchantId');
      return _current ?? await _loadAndApply(_fixedMerchantId!);
    }

    if (_current?.merchantId == merchantId) return _current!;

    final config = await _loadAndApply(merchantId);

    if (persist && _fixedMerchantId == null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefsKey, merchantId);
    }

    return config;
  }

  Future<MerchantConfig> _loadAndApply(String merchantId) async {
    final config = await _fetchConfig(merchantId);
    _current = config;

    ShopifyConfig.setConfig(
      // storefrontAccessToken: '3264de93052dc2fadcfea55cdeb9a5db',
      // storefrontApiVersion: '2026-01',
      // storeUrl: 'hamed-oco-development-store.myshopify.com',
      storefrontAccessToken: 'd9139b64e0a5d26c7f178d59699d04e2',
      storefrontApiVersion: '2026-01',
      storeUrl: 'haitham-8952.myshopify.com',
      language: config.features.defaultLanguage,
    );

    debugPrint('🏷️ Active merchant: ${config.merchantId} (${config.shopDomain})');
    return config;
  }
}
