import 'package:bexdeliveries/src/domain/models/notification.dart';
import 'package:bexdeliveries/src/domain/repositories/database_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../base/base_cubit.dart';

part 'notification_state.dart';

class NotificationCubit extends BaseCubit<NotificationState, List<PushNotification>?> {
  final DatabaseRepository databaseRepository;

  NotificationCubit(this.databaseRepository) : super(const NotificationCubitLoading(),[]);

  Future<void> getNotificationCubit() async {
    if (isBusy) return;

    await run(() async {
      try {
        final notificationCubit = await databaseRepository.getNotifications();
        emit(NotificationCubitSuccess(notification: notificationCubit));
      } catch (error) {
        emit(NotificationCubitFailed(error: error.toString()));
      }
    });

  }
}