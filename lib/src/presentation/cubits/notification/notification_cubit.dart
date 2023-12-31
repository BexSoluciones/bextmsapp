import 'package:bexdeliveries/src/domain/models/notification.dart';
import 'package:bexdeliveries/src/domain/repositories/database_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../base/base_cubit.dart';

part 'notification_state.dart';


class NotificationCubit extends BaseCubit<NotificationState, List<PushNotification>?> {
  final DatabaseRepository _databaseRepository;

  NotificationCubit(this._databaseRepository) : super(const NotificationCubitLoading(),[]);

  Future<void> getNotificationCubit() async {
    if (isBusy) return;

    await run(() async {
      try {
        final notificationCubit = await _databaseRepository.getNotifications();
        emit(NotificationCubitSuccess(notification: notificationCubit));
      } catch (error) {
        print('Error getWorkTypesFromWork data: $error');
        emit(NotificationCubitFailed(error: error.toString()));
      }
    });

  }
}