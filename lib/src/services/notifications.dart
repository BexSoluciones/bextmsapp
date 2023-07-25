import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';

//domain
import '../../src/domain/models/notification.dart';

//widgets
import '../utils/constants/colors.dart';

Future _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Got a message whilst in the background!');
  if (message.notification != null) {
    print('Notification Title: ${message.notification!.title}');
    print('Notification Body: ${message.notification!.body}');
    print('Notification data: ${message.data}');
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
  String? token;

  Future init() async {
    if (!_initialized) {
      settings = await _firebaseMessaging?.requestPermission(
        alert: true,
        badge: true,
        provisional: false,
        sound: true,
      );
      token = await _firebaseMessaging?.getToken();
      print(token);
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

    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);
    FirebaseMessaging.onMessage.listen(_handleMessage);
  }

  void _handleMessageOpenedApp(RemoteMessage message) {
    print('Got a message whilst in the foreground!');
    print('Message data: ${message.data}');
    print(message.notification);

    if (message.notification != null) {
      print('Message also contained a notification: ${message.notification}');


    }
  }

  void _handleMessage(RemoteMessage message) {
    print('Got a message whilst in the foreground!');
    print('Message data: ${message.data}');
    print(message.notification);

    if (message.notification != null) {
      print('Message also contained a notification: ${message.notification}');

      showSimpleNotification(
        const Text('Hola'),
        leading: const Icon(Icons.notification_important_outlined),
        subtitle: Text(message.notification!.title!),
        background: kPrimaryColor,
        duration: const Duration(seconds: 2),
      );
    }
  }
}
