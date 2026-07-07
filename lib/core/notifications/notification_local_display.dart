import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

const String androidNotificationChannelId = 'phonoquest_alerts';
const String androidNotificationChannelName = 'PhonoQuest Alerts';
/// Status-bar only (Android requires a monochrome small icon).
const String androidSmallNotificationIcon = '@drawable/ic_notification';
/// Full-color #DFF1FF avatar shown in the notification UI.
const String androidColorNotificationDrawable = 'ic_notification_large';

const _colorAvatar =
    DrawableResourceAndroidBitmap(androidColorNotificationDrawable);
const _colorPersonIcon =
    DrawableResourceAndroidIcon(androidColorNotificationDrawable);

Future<void> ensureAndroidNotificationChannel(
  FlutterLocalNotificationsPlugin plugin,
) async {
  await plugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(
        const AndroidNotificationChannel(
          androidNotificationChannelId,
          androidNotificationChannelName,
          description: 'Assignments, teacher messages, and learning updates',
          importance: Importance.high,
        ),
      );
}

(String title, String body) notificationText(RemoteMessage message) {
  final title = message.notification?.title ??
      message.data['title'] ??
      'PhonoQuest';
  final body = message.notification?.body ?? message.data['body'] ?? '';
  return (title.toString().trim(), body.toString().trim());
}

Person _phonoquestPerson() {
  return const Person(
    name: 'PhonoQuest',
    icon: _colorPersonIcon,
    important: true,
  );
}

/// Messaging style keeps the avatar full-color (no gray Android mask layer).
MessagingStyleInformation _messagingStyle(String title, String body) {
  return MessagingStyleInformation(
    const Person(name: ''),
    conversationTitle: title,
    groupConversation: false,
    messages: [
      Message(body, DateTime.now(), _phonoquestPerson()),
    ],
  );
}

Future<void> showPhonoquestLocalNotification(
  FlutterLocalNotificationsPlugin plugin, {
  required RemoteMessage message,
}) async {
  final (title, body) = notificationText(message);
  if (title.isEmpty && body.isEmpty) return;

  final payload = message.data.isNotEmpty ? jsonEncode(message.data) : null;

  try {
    await plugin.show(
      message.hashCode,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          androidNotificationChannelId,
          androidNotificationChannelName,
          channelDescription:
              'Assignments, teacher messages, and learning updates',
          importance: Importance.high,
          priority: Priority.high,
          icon: androidSmallNotificationIcon,
          colorized: false,
          styleInformation: _messagingStyle(title, body),
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      payload: payload,
    );
  } catch (e, st) {
    debugPrint('showPhonoquestLocalNotification failed: $e\n$st');
    await _showFallbackNotification(plugin, title: title, body: body, payload: payload);
  }
}

Future<void> _showFallbackNotification(
  FlutterLocalNotificationsPlugin plugin, {
  required String title,
  required String body,
  required String? payload,
}) async {
  await plugin.show(
    title.hashCode,
    title,
    body,
    NotificationDetails(
      android: AndroidNotificationDetails(
        androidNotificationChannelId,
        androidNotificationChannelName,
        importance: Importance.high,
        priority: Priority.high,
        icon: androidSmallNotificationIcon,
        largeIcon: _colorAvatar,
        styleInformation: BigTextStyleInformation(body),
      ),
      iOS: const DarwinNotificationDetails(),
    ),
    payload: payload,
  );
}
