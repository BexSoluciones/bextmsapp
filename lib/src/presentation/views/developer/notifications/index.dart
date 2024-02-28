import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

//domain
import '../../../../domain/models/notification.dart';

//cubit
import '../../../../presentation/cubits/notification/notification_cubit.dart';

//widgets
import '../../../../presentation/widgets/notification_page.dart';

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
