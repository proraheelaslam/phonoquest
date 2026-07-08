import 'dart:async';
import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../firebase_options.dart';
import '../../features/notifications/data/device_token_repository.dart';
import '../auth/auth_token_storage.dart';
import 'notification_local_display.dart';
import 'notification_navigation.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  WidgetsFlutterBinding.ensureInitialized();
  if (defaultTargetPlatform == TargetPlatform.iOS) return;

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  try {
    final plugin = FlutterLocalNotificationsPlugin();
    const androidInit =
        AndroidInitializationSettings(androidSmallNotificationIcon);
    await plugin.initialize(const InitializationSettings(android: androidInit));
    await ensureAndroidNotificationChannel(plugin);
    await showPhonoquestLocalNotification(plugin, message: message);
  } catch (e, st) {
    debugPrint('firebaseMessagingBackgroundHandler failed: $e\n$st');
  }
}

/// FCM initialization, token sync, and notification display.
class PushNotificationService {
  PushNotificationService._();

  static final PushNotificationService instance = PushNotificationService._();

  FirebaseMessaging? _messaging;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final DeviceTokenRepository _tokenRepository = DeviceTokenRepository();

  bool _initialized = false;
  bool _supported = false;
  String? _currentToken;
  StreamSubscription<String>? _tokenRefreshSub;
  StreamSubscription<RemoteMessage>? _foregroundMessageSub;
  Map<String, dynamic>? _pendingNotificationData;

  Future<void> initialize() async {
    if (_initialized) return;
    if (kIsWeb) {
      debugPrint('PushNotificationService: web platform — push notifications skipped');
      _initialized = true;
      return;
    }

    if (defaultTargetPlatform == TargetPlatform.iOS) {
      debugPrint('PushNotificationService: iOS Firebase Messaging disabled');
      _initialized = true;
      return;
    }

    if (!DefaultFirebaseOptions.isConfigured) {
      debugPrint('PushNotificationService: Firebase not configured — skipping FCM init');
      _initialized = true;
      return;
    }

    try {
      await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
      _messaging = FirebaseMessaging.instance;
    } catch (e, st) {
      debugPrint('PushNotificationService: Firebase init failed: $e\n$st');
      _initialized = true;
      return;
    }

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    const androidInit =
        AndroidInitializationSettings(androidSmallNotificationIcon);
    const iosInit = DarwinInitializationSettings();
    await _localNotifications.initialize(
      const InitializationSettings(android: androidInit, iOS: iosInit),
      onDidReceiveNotificationResponse: _onLocalNotificationTap,
    );

    await ensureAndroidNotificationChannel(_localNotifications);

    await _requestPermission();

    final messaging = _messaging;
    if (messaging == null) {
      _initialized = true;
      return;
    }

    _supported = true;
    _tokenRefreshSub = messaging.onTokenRefresh.listen(_onTokenRefresh);
    _foregroundMessageSub =
        FirebaseMessaging.onMessage.listen(_onForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_onMessageOpened);

    final initial = await messaging.getInitialMessage();
    if (initial != null && initial.data.isNotEmpty) {
      _pendingNotificationData = Map<String, dynamic>.from(initial.data);
    }

    _initialized = true;
    await syncTokenIfLoggedIn();
  }

  /// Call after the first screen is mounted (e.g. post-splash navigation).
  Future<void> consumePendingNotificationNavigation() async {
    final data = _pendingNotificationData;
    if (data == null || data.isEmpty) return;
    _pendingNotificationData = null;

    await Future<void>.delayed(const Duration(milliseconds: 300));
    navigateFromNotificationPayload(data);
  }

  Future<void> dispose() async {
    await _tokenRefreshSub?.cancel();
    await _foregroundMessageSub?.cancel();
    _tokenRefreshSub = null;
    _foregroundMessageSub = null;
  }

  Future<void> syncTokenIfLoggedIn() async {
    if (kIsWeb) return;

    if (!_initialized) {
      await initialize();
    }
    if (!_supported) {
      debugPrint('PushNotificationService: FCM not supported on this device — token not synced');
      return;
    }

    final accessToken = await AuthTokenStorage.instance.readAccessToken();
    if (accessToken == null || accessToken.isEmpty) {
      debugPrint('PushNotificationService: no access token — skip device token sync');
      return;
    }

    try {
      final fcmToken = await _messaging?.getToken();
      if (fcmToken == null || fcmToken.isEmpty) {
        debugPrint('PushNotificationService: FCM token empty — permission or Firebase issue');
        return;
      }
      _currentToken = fcmToken;
      await _tokenRepository.register(fcmToken: fcmToken);
      debugPrint('PushNotificationService: device token registered with backend');
    } catch (e, st) {
      debugPrint('PushNotificationService: token sync failed: $e\n$st');
    }
  }

  Future<void> unregisterCurrentToken() async {
    if (!_supported) return;
    try {
      final token = _currentToken ?? await _messaging?.getToken();
      if (token == null || token.isEmpty) return;
      await _tokenRepository.unregister(fcmToken: token);
    } catch (e, st) {
      debugPrint('PushNotificationService: unregister failed: $e\n$st');
    }
    _currentToken = null;
  }

  Future<void> _requestPermission() async {
    await _messaging?.requestPermission(alert: true, badge: true, sound: true);
  }

  Future<void> _onTokenRefresh(String token) async {
    _currentToken = token;
    final accessToken = await AuthTokenStorage.instance.readAccessToken();
    if (accessToken == null || accessToken.isEmpty) return;
    try {
      await _tokenRepository.register(fcmToken: token);
    } catch (e, st) {
      debugPrint('PushNotificationService: token refresh register failed: $e\n$st');
    }
  }

  Future<void> _onForegroundMessage(RemoteMessage message) async {
    await showPhonoquestLocalNotification(_localNotifications, message: message);
  }

  void _onMessageOpened(RemoteMessage message) {
    _handleOpenedMessage(message.data);
  }

  void _onLocalNotificationTap(NotificationResponse response) {
    final payload = response.payload;
    if (payload == null || payload.isEmpty) return;
    try {
      final decoded = jsonDecode(payload);
      if (decoded is Map<String, dynamic>) {
        navigateFromNotificationPayload(decoded);
      }
    } catch (_) {}
  }

  void _handleOpenedMessage(Map<String, dynamic> data) {
    if (data.isEmpty) return;
    navigateFromNotificationPayload(data);
  }
}
