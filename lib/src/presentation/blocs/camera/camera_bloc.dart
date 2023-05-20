import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:camera/camera.dart';
import 'package:equatable/equatable.dart';


//utils
import '../../../utils/resources/camera.dart';

part 'camera_event.dart';
part 'camera_state.dart';

class CameraBloc extends Bloc<CameraEvent, CameraState> {
  final CameraUtils cameraUtils;
  final ResolutionPreset resolutionPreset;
  final CameraLensDirection cameraLensDirection;

  late CameraController _controller;

  CameraBloc({
    required this.cameraUtils,
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
      print(error);
      emit(CameraFailure(error: error.toString()));
    }
  }

  _mapCameraCapturedToState(CameraCaptured event, emit) async {
    if(state is CameraReady){
      emit(CameraCaptureInProgress());
      try {
        final path = await cameraUtils.getPath();
        await _controller.takePicture();
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