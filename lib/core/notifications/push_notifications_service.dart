import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Must be a top-level function for background handling.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Firebase must be initialized in background isolate too.
  await Firebase.initializeApp();

  // Keep background work minimal. No UI work here.
  debugPrint('🌙 [BG] messageId=${message.messageId} data=${message.data}');
}

class PushNotificationsService {
  PushNotificationsService(this._messaging);

  final FirebaseMessaging _messaging;

  final FlutterLocalNotificationsPlugin _localNotifications =
  FlutterLocalNotificationsPlugin();

  // Keep channel constants in one place
  static const String _channelId = 'fcm_default_channel_1';
  static const String _channelName = 'Notifications';
  static const String _channelDescription = 'Merchant notifications';

  Future<void> init({
    required String merchantId,
    required Future<void> Function(String token) onToken,
    required void Function(RemoteMessage message) onNotificationTap,
  }) async {
    // 0) Register background handler EARLY
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // 1) Permissions (iOS + Android 13+)
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    debugPrint('🔔 Push permission: ${settings.authorizationStatus}');

    // If user denied, stop early.
    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      debugPrint('⛔ Push permission denied. Not initializing push.');
      return;
    }

    // 2) iOS foreground presentation (so you can show banner while app open)
    if (Platform.isIOS) {
      await _messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    }

    // 3) Local notifications init (for foreground messages)
    const androidInit =
    AndroidInitializationSettings('@drawable/ic_stat_notification');
    const iosInit = DarwinInitializationSettings();
    const initSettings =
    InitializationSettings(android: androidInit, iOS: iosInit);

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (resp) {
        debugPrint('🟦 Local notif tapped. payload=${resp.payload}');

        final payload = resp.payload;
        if (payload == null || payload.isEmpty) return;

        // ✅ Build a message-like object properly
        final msg = RemoteMessage.fromMap({
          'data': {'deeplink': payload}
        });

        onNotificationTap(msg);
      },
    );

    // 4) Create Android notification channel (Android 8+)
    await _createAndroidChannelIfNeeded();

    // 5) Get token + send to backend
    final token = await _messaging.getToken();
    debugPrint('✅ FCM token ($merchantId): $token');

    if (token != null) {
      await onToken(token);
    }

    // Refresh token
    _messaging.onTokenRefresh.listen((t) async {
      debugPrint('🔄 FCM token refreshed ($merchantId): $t');
      await onToken(t);
    });

    // 6) Foreground message handling → show local notif
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      debugPrint('📩 onMessage (foreground) id=${message.messageId}');
      debugPrint('📩 data=${message.data}');
      debugPrint(
          '📩 notif=${message.notification?.title} / ${message.notification?.body}');

      final title =
          message.notification?.title ?? message.data['title']?.toString();
      final body =
          message.notification?.body ?? message.data['body']?.toString();

      if ((title == null || title.isEmpty) && (body == null || body.isEmpty)) {
        debugPrint('⚠️ No title/body found. Not showing local notification.');
        return;
      }

      // ✅ payload should be the deeplink string so tapping local notif routes.
      final deeplink =
          message.data['deeplink']?.toString() ?? message.data['url']?.toString();

      await _showLocalNotification(
        id: message.hashCode,
        title: title ?? '',
        body: body ?? '',
        payload: deeplink,
      );
    });

    // 7) App opened from notification (background)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('👆 onMessageOpenedApp id=${message.messageId}');
      debugPrint('👆 data=${message.data}');
      onNotificationTap(message);
    });

    // 8) If app was terminated and opened by notif:
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      debugPrint('🚀 getInitialMessage id=${initialMessage.messageId}');
      debugPrint('🚀 data=${initialMessage.data}');
      onNotificationTap(initialMessage);
    }

    debugPrint('✅ PushNotificationsService initialized for $merchantId');
  }

  Future<void> _createAndroidChannelIfNeeded() async {
    final androidPlugin = _localNotifications
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin == null) return;

    // NOTE:
    // - Channel settings "stick" on device/emulator. If you change sound/vibration,
    //   you must uninstall app (or wipe emulator data) OR change channelId.
    const channel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDescription,
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
      showBadge: true,
      sound: RawResourceAndroidNotificationSound('notification'),
    );

    await androidPlugin.createNotificationChannel(channel);
  }

  Future<void> _showLocalNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,

      // ✅ small icon MUST be white silhouette
      // pass resource NAME only (no @drawable/)
      icon: 'ic_stat_notification',

      // ✅ optional colored large icon (must exist in drawable)
      // If you don't have it yet, you can remove this line.
      largeIcon: DrawableResourceAndroidBitmap('notification_large'),
    );

    const iosDetails = DarwinNotificationDetails();

    await _localNotifications.show(
      id,
      title,
      body,
      const NotificationDetails(android: androidDetails, iOS: iosDetails),
      payload: payload,
    );
  }
}
