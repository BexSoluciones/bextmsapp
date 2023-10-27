import 'package:bexdeliveries/src/presentation/cubits/notification/notification_cubit.dart';
import 'package:bexdeliveries/src/presentation/widgets/notification_page.dart';
import 'package:bexdeliveries/src/services/notifications.dart';
import 'package:bexdeliveries/src/utils/constants/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
  late NotificationCubit notificationCubit;

  @override
  void initState() {
    notificationCubit = BlocProvider.of<NotificationCubit>(context);
    notificationCubit.getNotificationCubit();
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
        title: const Text('Notificaciones'),
      ),
      body: BlocBuilder<NotificationCubit, NotificationState>(
        builder: (_, state) {
          switch (state.runtimeType) {
            case NotificationCubitLoading:
              return const Center(child: CupertinoActivityIndicator());
            case NotificationCubitSuccess:
              return _buildHome(state.notification);
            case NotificationCubitFailed:
              return Center(
                child: Text(state.error!),
              );
            default:
              return const SizedBox();
          }
        },
      ),
    );
  }

  Widget _buildHome(List<PushNotification>? notification) {
    return Column(
      children: [
        Expanded(
            flex: 12,
            child: ListView.separated(
              itemCount: notification!.length,
              separatorBuilder: (context, index) =>
              const SizedBox(height: 16.0),
              itemBuilder: (context, index) {
                return BuildNotificationCard(notification: notification[index]);
              },
            )),
      ],
    );
  }
}
