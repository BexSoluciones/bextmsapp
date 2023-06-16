import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';

//domain
import '../../src/domain/models/notification.dart';

//widgets
import '../presentation/widgets/custom_notification_badge.dart';

class NotificationService {

  static NotificationService? _instance;
  static FirebaseMessaging? _firebaseMessaging;

  static NotificationSettings? settings;

  static Future<NotificationService?> getInstance() async {
    _instance ??= NotificationService();
    _firebaseMessaging = FirebaseMessaging.instance;
    settings = await _firebaseMessaging?.requestPermission(
      alert: true,
      badge: true,
      provisional: false,
      sound: true,
    );
    return _instance;
  }


  // FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  void sendNotification() async {
      if (settings?.authorizationStatus == AuthorizationStatus.authorized) {

        // For handling the received notifications
        FirebaseMessaging.onMessage.listen((RemoteMessage message) {
          // Parse the message received
          PushNotification notification = PushNotification(
            title: message.notification?.title,
            body: message.notification?.body,
            dataTitle: message.data['title'],
            dataBody: message.data['body'],
          );

          showSimpleNotification(
            Text(notification.title!),
            leading: const NotificationBadge(totalNotifications: 0),
            subtitle: Text(notification.body!),
            background: Colors.cyan.shade700,
            duration: const Duration(seconds: 2),
          );
        });
      } else {
        print('User declined or has not accepted permission');
      }
  }






}
