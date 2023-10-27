part of 'notification_cubit.dart';


@immutable
abstract class NotificationState  extends Equatable {

  final List<PushNotification>? notification;
  final String? error;


  const NotificationState({
    this.notification,
    this.error
  });

  @override
  List<Object?> get props => [
    notification,
    error
  ];

}

class  NotificationCubitLoading extends  NotificationState {
  const  NotificationCubitLoading();
}

class  NotificationCubitSuccess extends  NotificationState {
  const  NotificationCubitSuccess({List<PushNotification>? notification}):super(notification: notification);
}

class   NotificationCubitFailed extends  NotificationState{
  const  NotificationCubitFailed({String? error}) : super(error: error);
}
