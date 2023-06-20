import 'package:bexdeliveries/src/services/notifications.dart';
import 'package:bexdeliveries/src/utils/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';

//domain
import '../../../../domain/models/notification.dart';

//services
import '../../../../locator.dart';
import '../../../../services/navigation.dart';

//widgets
import '../../../widgets/custom_notification_badge.dart';

final NavigationService _navigationService = locator<NavigationService>();
final NotificationService _notificationService = locator<NotificationService>();

class NotificationsView extends StatefulWidget {
  const NotificationsView({super.key});

  @override
  State<NotificationsView> createState() => _NotificationsViewState();
}

class _NotificationsViewState extends State<NotificationsView> {
  late int _totalNotifications;
  PushNotification? _notificationInfo;

  @override
  void initState() {
    _totalNotifications = 0;
    super.initState();
  }

  void show() {
    showSimpleNotification(
      const Text('Hola'),
      leading: const Icon(Icons.notification_important_outlined),
      subtitle: const Text('este es un mensage'),
      background: kPrimaryColor,
      duration: const Duration(seconds: 2),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new),
            onPressed: () => _navigationService.goBack(),
          ),
          title: const Text('Notificaciones')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'App for capturing Firebase Push Notifications',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.black,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 16.0),
          NotificationBadge(totalNotifications: _totalNotifications),
          const SizedBox(height: 16.0),
          _notificationInfo != null
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TITLE: ${_notificationInfo!.dataTitle ?? _notificationInfo!.title}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      'BODY: ${_notificationInfo!.dataBody ?? _notificationInfo!.body}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0,
                      ),
                    ),
                  ],
                )
              : Container(),
          TextButton(onPressed: () => show(), child: const Text('mostrar'))
        ],
      ),
    );
  }
}
