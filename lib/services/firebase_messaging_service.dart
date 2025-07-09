import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart' as fln;
import 'package:flutter/scheduler.dart';

class FirebaseMessagingService {
  static final _firebaseMessaging = FirebaseMessaging.instance;
  static final _localNotificationsPlugin = fln.FlutterLocalNotificationsPlugin();

  static Future<void> initialize(BuildContext context) async {
    // 🔒 Request permission (iOS)
    await _firebaseMessaging.requestPermission();

    final token = await _firebaseMessaging.getToken();
    debugPrint("🔐 FCM Token: $token");

    // ✅ Initialize local notifications (Android)
    const androidSettings = fln.AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = fln.InitializationSettings(android: androidSettings);
    await _localNotificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (response) {
        debugPrint("🔔 Notification tapped (local)");
        // TODO: Handle direct navigation if needed
      },
    );

    // ✅ Foreground messages
    FirebaseMessaging.onMessage.listen((message) {
      final notification = message.notification;
      final data = message.data;

      if (data['type'] == 'chat' && data['senderName'] != null) {
        _showNotification(RemoteNotification(
          title: data['senderName'],
          body: 'New message',
        ));
      } else if (data['type'] == 'like' && data['senderName'] != null) {
        _showNotification(RemoteNotification(
          title: data['senderName'],
          body: 'liked your post',
        ));
      } else if (notification != null) {
        _showNotification(notification);
      }
    });

    // ✅ App opened from background
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      final notification = message.notification;
      final data = message.data;

      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          if (data['type'] == 'chat' && data['senderName'] != null) {
            _showDialog(context, data['senderName'], 'New message');
          } else if (notification != null) {
            _showDialog(context, notification.title ?? '', notification.body ?? '');
          }
        }
      });
    });

    // ✅ App launched from terminated state
    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      final notification = initialMessage.notification;
      final data = initialMessage.data;

      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          if (data['type'] == 'chat' && data['senderName'] != null) {
            _showDialog(context, data['senderName'], 'New message');
          } else if (notification != null) {
            _showDialog(context, notification.title ?? '', notification.body ?? '');
          }
        }
      });
    }
  }

  static Future<void> _showNotification(RemoteNotification notification) async {
    const androidDetails = fln.AndroidNotificationDetails(
      'channel_id',
      'GAMMER Notifications',
      channelDescription: 'This channel is used for GAMMER push notifications',
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
