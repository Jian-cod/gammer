import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart' as fln;
import 'package:flutter/scheduler.dart';

class FirebaseMessagingService {
  static final _firebaseMessaging = FirebaseMessaging.instance;
  static final _localNotificationsPlugin = fln.FlutterLocalNotificationsPlugin();

  static Future<void> initialize(BuildContext context) async {
    await _firebaseMessaging.requestPermission();

    final token = await _firebaseMessaging.getToken();
    debugPrint("FCM Token: $token");

    const androidSettings = fln.AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = fln.InitializationSettings(android: androidSettings);
    await _localNotificationsPlugin.initialize(initSettings);

    // Foreground message
    FirebaseMessaging.onMessage.listen((message) {
      final notification = message.notification;
      if (notification != null) {
        _showNotification(notification);
      }
    });

    // App launched from terminated
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      final notification = message?.notification;
      if (notification != null) {
        SchedulerBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) {
            _showDialog(context, notification.title ?? '', notification.body ?? '');
          }
        });
      }
    });

    // App resumed from background
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      final notification = message.notification;
      if (notification != null) {
        SchedulerBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) {
            _showDialog(context, notification.title ?? '', notification.body ?? '');
          }
        });
      }
    });
  }

  static Future<void> _showNotification(RemoteNotification notification) async {
    const androidDetails = fln.AndroidNotificationDetails(
      'channel_id',
      'GAMMER Notifications',
      importance: fln.Importance.max,
      priority: fln.Priority.high,
    );

    const details = fln.NotificationDetails(android: androidDetails);

    await _localNotificationsPlugin.show(
      notification.hashCode,
      notification.title,
      notification.body,
      details,
    );
  }

  static void _showDialog(BuildContext context, String title, String body) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
