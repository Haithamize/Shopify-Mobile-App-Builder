import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import 'core/config/deeplink/merchant_context_service.dart';
import 'core/config/merchant_config.dart';
import 'core/di/injection_container.dart';
import 'core/notifications/push_notifications_service.dart';
import 'core/router/app_router.dart';
import 'core/router/deeplink_service.dart';
import 'main.dart' show RootApp;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize with MOCK flag = true
  await initDependencies(isMock: true, flavor: AppFlavor.demo);

  // Firebase uses the per-merchant swapped config files at build time
  await Firebase.initializeApp();

  final ctx = sl<MerchantContextService>();

  // Router + deeplinks (same as real main)
  final appRouter = AppRouter();
  final deepLinks = DeepLinkService(appRouter.router, ctx);
  await deepLinks.init();

  final config = ctx.current;

  if (config != null && config.features.enablePushNotifications) {
    final service = PushNotificationsService(FirebaseMessaging.instance);

    await service.init(
      merchantId: config.merchantId,
      onToken: (token) async {
        debugPrint("✅ FCM TOKEN for ${config.merchantId}: $token");
      },
      onNotificationTap: (message) {
        final deeplink = message.data['deeplink']?.toString();
        final url = message.data['url']?.toString();
        deepLinks.openFromString(deeplink ?? url);
      },
    );
  } else {
    debugPrint("ℹ️ Push disabled by feature flag for merchant ${config?.merchantId}");
  }

  runApp(RootApp(router: appRouter.router));
}
