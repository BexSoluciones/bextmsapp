import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';

//domain
import '../../src/domain/models/notification.dart';

//widgets
import '../presentation/widgets/custom_notification_badge.dart';

Future _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Got a message whilst in the background!');
  if (message.notification != null) {
    print('Notification Title: ${message.notification!.title}');
    print('Notification Body: ${message.notification!.body}');
  }
}

class NotificationService {
  static NotificationService? _instance;
  static FirebaseMessaging? _firebaseMessaging;

  static NotificationSettings? settings;

  static Future<NotificationService?> getInstance() async {
    _instance ??= NotificationService();
    _firebaseMessaging = FirebaseMessaging.instance;
    return _instance;
  }

  bool _initialized = false;

  Future init() async {
    if (!_initialized) {
      settings = await _firebaseMessaging?.requestPermission(
        alert: true,
        badge: true,
        provisional: false,
        sound: true,
      );
      String? token = await _firebaseMessaging?.getToken();
      _initialized = true;
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
      await setupInteractedMessage();
    }
  }


  Future<void> setupInteractedMessage() async {
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {
      _handleMessage(initialMessage);
    }

    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
  }

  void _handleMessage(RemoteMessage message) {
    print('Got a message whilst in the foreground!');
    print('Message data: ${message.data}');
    print(message.notification);

    if (message.notification != null) {
      print('Message also contained a notification: ${message.notification}');

      PushNotification notification = PushNotification(
        title: message.notification?.title,
        body: message.notification?.body,
        // dataTitle: message.data['title'],
        // dataBody: message.data['body'],
      );


    }
  }
}
