import 'dart:convert';
import 'package:flutter/services.dart';
import 'merchant_config.dart';

// Interface
abstract class ConfigLoader {
  Future<MerchantConfig> load();
}

// 1. Production Loader (Reads from CI/CD Injected Flags) used to inject secrets via pipeline
class EnvironmentConfigLoader implements ConfigLoader {
  @override
  Future<MerchantConfig> load() async {
    // These consts are injected via --dart-define during CI/CD build
    const merchantId = String.fromEnvironment('MERCHANT_ID');
    const shopDomain = String.fromEnvironment('SHOP_DOMAIN');
    const token = String.fromEnvironment('STOREFRONT_TOKEN');

    if (merchantId.isEmpty) {
      throw Exception('Critical: No Merchant ID found in Environment');
    }

    // In prod, specific feature flags might come from a remote API
    // using the merchantId, but for now we construct the base:
    return MerchantConfig(
      merchantId: merchantId,
      shopDomain: shopDomain,
      storefrontToken: token,
      appName: const String.fromEnvironment('APP_NAME', defaultValue: 'Store'),
      theme: const MerchantTheme(
        primaryColor: String.fromEnvironment('PRIMARY_COLOR', defaultValue: '#000000'),
        secondaryColor: '#FFFFFF',
        fontFamily: 'Roboto',
        logoUrl: '',
      ),
      features: const FeatureFlags(),
      integrationKeys: {},
    );
  }
}

// 2. Mock Loader (Reads from Local JSON for Dev)
class MockConfigLoader implements ConfigLoader {
  @override
  Future<MerchantConfig> load() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    final jsonString = await rootBundle.loadString('assets/mock_merchant.json');
    final jsonMap = json.decode(jsonString);

    return MerchantConfig.fromJson(jsonMap);
  }
}