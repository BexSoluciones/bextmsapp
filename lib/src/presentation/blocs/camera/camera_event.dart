part of 'camera_bloc.dart';

abstract class CameraEvent extends Equatable {
  const CameraEvent();

  @override
  List<Object> get props => [];
}

class CameraInitialized extends CameraEvent{}

class CameraStopped extends CameraEvent{}

class CameraCaptured extends CameraEvent{}

class CameraChange extends CameraEvent {
  final String len;
  const CameraChange(this.len);
}

class CameraFolder extends CameraEvent {
  final String path;
  const CameraFolder({ required this.path });
}