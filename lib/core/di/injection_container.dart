import 'package:get_it/get_it.dart';
import 'package:shopify_flutter/shopify_config.dart';

import '../config/config_loader.dart';
import '../config/merchant_config.dart';

final sl = GetIt.instance; // Service Locator

Future<void> initDependencies({bool isMock = false}) async {
  // 1. Config Loader
  sl.registerLazySingleton<ConfigLoader>(
        () => isMock ? MockConfigLoader() : EnvironmentConfigLoader(),
  );

  // 2. Load Config immediately
  final config = await sl<ConfigLoader>().load();
  sl.registerSingleton<MerchantConfig>(config);

  // 3. Initialize Shopify SDK Dynamically
  ShopifyConfig.setConfig(
    storefrontAccessToken: config.storefrontToken,
    storefrontApiVersion: '2024-04',
    storeUrl: config.shopDomain,
  );

  // 4. Register Logic blocs/repositories here...
}