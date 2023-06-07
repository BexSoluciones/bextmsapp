import 'dart:async';

import 'package:bexdeliveries/src/domain/models/photo.dart';
import 'package:bexdeliveries/src/domain/repositories/database_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:camera/camera.dart';
import 'package:equatable/equatable.dart';


//utils
import '../../../utils/resources/camera.dart';

part 'camera_event.dart';
part 'camera_state.dart';

class CameraBloc extends Bloc<CameraEvent, CameraState> {
  final CameraUtils cameraUtils;
  final DatabaseRepository databaseRepository;
  final ResolutionPreset resolutionPreset;
  final CameraLensDirection cameraLensDirection;

  late CameraController _controller;

  CameraBloc({
    required this.cameraUtils,
    required this.databaseRepository,
    this.resolutionPreset = ResolutionPreset.medium,
    this.cameraLensDirection = CameraLensDirection.back,
  }) : super(CameraInitial()) {
    on<CameraInitialized>(_mapCameraInitializedToState);
    on<CameraCaptured>(_mapCameraCapturedToState);
    on<CameraStopped>(_mapCameraStoppedToState);
  }

  CameraController getController() => _controller;

  bool isInitialized() => _controller.value.isInitialized;

   _mapCameraInitializedToState(CameraInitialized event, emit) async {
    try {
      _controller = await cameraUtils.getCameraController(resolutionPreset, cameraLensDirection);
      await _controller.initialize();
      emit(CameraReady());
    } on CameraException catch (error) {
      _controller.dispose();
      emit(CameraFailure(error: error.description!));
    } catch (error) {
      emit(CameraFailure(error: error.toString()));
    }
  }

  _mapCameraCapturedToState(CameraCaptured event, emit) async {
    if(state is CameraReady){
      emit(CameraCaptureInProgress());
      try {
        final path = await cameraUtils.getPath();
        var picture = await _controller.takePicture();
        var photo = Photo(name: picture.name, path: picture.path);
        await databaseRepository.insertPhoto(photo);
        emit(CameraCaptureSuccess(path));
      } on CameraException catch (error) {
        emit(CameraCaptureFailure(error: error.description!));
      } catch (error) {
        emit(CameraFailure(error: error.toString()));
      }
    } else {
      emit(const CameraFailure(error: 'Camera is not ready'));
    }
  }

  _mapCameraStoppedToState(CameraStopped event, emit) {
    _controller.dispose();
    emit(CameraInitial());
  }

  @override
  Future<void> close() {
    _controller.dispose();
    return super.close();
  }
}