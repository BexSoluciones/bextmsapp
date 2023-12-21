import 'package:bexdeliveries/src/locator.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';

//domain
import '../../src/domain/models/notification.dart';

//widgets
import '../domain/repositories/database_repository.dart';
import '../utils/constants/colors.dart';

final DatabaseRepository _databaseRepository = locator<DatabaseRepository>();

Future _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (message.notification != null && kDebugMode) {
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
    if (message.notification != null) {
      print('Message also contained a notification: ${message.notification}');
    }
  }

  void _handleMessage(RemoteMessage message) {
    if (message.notification != null) {
      print('Message also contained a notification: ${message.notification}');

      _databaseRepository.insertNotification(PushNotification(
          id_from_server: message.data['notification_id'],
          title: message.notification?.title,
          body: message.notification?.body,
          with_click_action: message.notification?.android?.clickAction,
          date: message.data['date'],
          read_at: null));

      showSimpleNotification(
        Text(message.notification!.body!),
        leading: const Icon(Icons.notification_important_outlined),
        subtitle: Text(message.notification!.title!),
        background: kPrimaryColor,
        duration: const Duration(seconds: 2),
      );
    }
  }
}