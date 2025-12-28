import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shopiney/ui/theme/app_theme.dart';

import 'core/di/injection_container.dart';
import 'core/config/merchant_config.dart';
import 'core/router/app_router.dart';
import 'core/router/deeplink_service.dart';
import 'l10n/app_localizations.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'core/notifications/push_notifications_service.dart';

// Standard Entry point (For CI/CD)
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initDependencies(isMock: false); // Use Real Environment

  // ✅ Firebase uses the per-merchant swapped config files at build time
  await Firebase.initializeApp();

  final config = sl<MerchantConfig>();

  // ✅ Router + Deep Links
  final appRouter = AppRouter();
  final deepLinks = DeepLinkService(appRouter.router);
  await deepLinks.init();

  debugPrint("🔎 Merchant: ${config.merchantId}");
  debugPrint("🔎 enablePushNotifications (runtime): ${config.features.enablePushNotifications}");
  debugPrint("🔎 features json-ish: ${config.features.toString()}");

  if (config.features.enablePushNotifications) {
    final service = PushNotificationsService(FirebaseMessaging.instance);

    await service.init(
      merchantId: config.merchantId,
      onToken: (token) async {
        debugPrint("✅ FCM TOKEN for ${config.merchantId}: $token");
        // TODO: POST to backend { merchantId, token, platform }
      },
      onNotificationTap: (message) {
        // ✅ push → deeplink → router
        final deeplink = message.data['deeplink']?.toString();
        final url = message.data['url']?.toString();
        deepLinks.openFromString(deeplink ?? url);
      },
    );
  } else {
    debugPrint("ℹ️ Push disabled by feature flag for merchant ${config.merchantId}");
  }

  runApp(RootApp(router: appRouter.router));
}

class RootApp extends StatelessWidget {
  const RootApp({super.key, required this.router});
  final GoRouter router;

  @override
  Widget build(BuildContext context) {
    final config = sl<MerchantConfig>();

    return MaterialApp.router(
      title: config.appName,
      debugShowCheckedModeBanner: false,
      routerConfig: router,

      /// ✅ White-label theme driven by MerchantConfig
      theme: AppTheme.fromMerchant(config),

      /// ✅ Localization setup
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: config.features.supportedLanguages
          .map((code) => Locale(code))
          .toList(),

      /// ✅ Enforces RTL/LTR consistently for all widgets
      builder: (context, child) {
        final locale = Localizations.localeOf(context);
        final isRtl = const ['ar', 'fa', 'ur', 'he'].contains(locale.languageCode);

        return Directionality(
          textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}

class WhiteLabelApp extends StatelessWidget {
  const WhiteLabelApp({super.key});

  @override
  Widget build(BuildContext context) {
    final config = sl<MerchantConfig>();
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.welcomeMessage(config.appName)),
        backgroundColor: _hexToColor(config.theme.primaryColor),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(l10n.welcomeMessage(config.appName)),
            if (config.features.useNativeCheckout)
              Chip(label: Text("Native Checkout Enabled ${l10n.checkout}")),
          ],
        ),
      ),
    );
  }
}

Color _hexToColor(String hex) {
  hex = hex.replaceAll('#', '');
  if (hex.length == 6) hex = 'FF$hex';
  return Color(int.parse(hex, radix: 16));
}
