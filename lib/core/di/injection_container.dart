import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:shopify_flutter/shopify/src/shopify_store.dart';

import '../../features/catalogue/bloc/products_bloc.dart';
import '../../features/catalogue/domain/repositories/products_repository.dart';
import '../config/config_loader.dart';
import '../config/deeplink/merchant_context_service.dart';
import '../data/db/app_database.dart';
import '../network/network_info.dart';
import '../shopify/shopify_facade.dart';
import '../shopify/shopify_flutter_facade.dart';

final sl = GetIt.instance;

enum AppFlavor { demo, dedicated }

Future<void> initDependencies({
  required AppFlavor flavor,
  bool isMock = false,
}) async {
  // 0) Clean previous registrations (useful in hot restart / tests)
  if (sl.isRegistered<MerchantContextService>()) {
    // ignore: avoid_print
    print('ℹ️ DI already initialized. Skipping re-init.');
    return;
  }

  // 1) Config Loader
  sl.registerLazySingleton<ConfigLoader>(
        () => isMock ? MockConfigLoader() : EnvironmentConfigLoader(),
  );

  // 2) Merchant context service
  const envMerchantId = String.fromEnvironment('MERCHANT_ID');
  final fixedMerchantId =
  (flavor == AppFlavor.dedicated && envMerchantId.isNotEmpty) ? envMerchantId : null;

  sl.registerLazySingleton<MerchantContextService>(() => MerchantContextService(
    fetchConfig: (merchantId) => sl<ConfigLoader>().loadByMerchantId(merchantId),
    fixedMerchantId: fixedMerchantId,
  ));

  // 3) Boot merchant context
  final ctx = sl<MerchantContextService>();
  final restored = await ctx.restore();

  // Demo app fallback if nothing saved yet
  if (flavor == AppFlavor.demo && restored == null) {
    // default demo merchant. later this will come from QR/login
    await ctx.switchTo('mock_001');
  }

  // 4) Common singletons
  sl.registerLazySingleton<AppDatabase>(() => AppDatabase());
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfo(Connectivity()));
  sl.registerLazySingleton<ShopifyFacade>(() => ShopifyFlutterFacade());

  // ✅ QUICK LOG-ONLY VERIFICATION (no screen)
  try {
    final health = await sl<ShopifyFacade>().healthCheck();
    final shop = await ShopifyStore.instance.getShop();
    final products = await ShopifyStore.instance.getNProducts(5);

    debugPrint(
      '🧪 Shopify health: ok=${health.ok} shop=${health.shopName} '
          'sample=${health.productCountSample} msg=${health.message}\n'
          '🧪 getShop()=${shop.name}\n'
          '🧪 getNProducts(5) count=${products?.length}',
    );
  } catch (e, st) {
    debugPrint('❌ Shopify healthCheck wrapper failed: $e');
    debugPrint('$st');
  }

  // 5) Repository/Bloc
  sl.registerFactory<ProductsRepository>(() => ProductsRepository(
    merchantId: sl<MerchantContextService>().merchantId ?? 'unknown',
    shopify: sl<ShopifyFacade>(),
    db: sl<AppDatabase>(),
    networkInfo: sl<NetworkInfo>(),
  ));

  sl.registerFactory<ProductsBloc>(() => ProductsBloc(sl<ProductsRepository>()));
}
