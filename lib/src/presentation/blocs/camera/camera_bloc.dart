import 'dart:async';
import 'dart:io';

import 'package:bexdeliveries/core/helpers/index.dart';
import 'package:bloc/bloc.dart';
import 'package:camera/camera.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;

//domain
import '../../../domain/models/photo.dart';
import '../../../domain/repositories/database_repository.dart';

//utils
import '../../../utils/resources/camera.dart';
import '../../../utils/constants/strings.dart';

//services
import '../../../services/navigation.dart';

part 'camera_event.dart';
part 'camera_state.dart';

class CameraBloc extends Bloc<CameraEvent, CameraState> {
  final CameraUtils cameraUtils;
  final DatabaseRepository databaseRepository;
  final ResolutionPreset resolutionPreset;
  final CameraLensDirection cameraLensDirection;
  final NavigationService navigationService;

  CameraController? _controller;

  final helperFunctions = HelperFunctions();

  CameraBloc({
    required this.cameraUtils,
    required this.databaseRepository,
    required this.navigationService,
    this.resolutionPreset = ResolutionPreset.medium,
    this.cameraLensDirection = CameraLensDirection.back,
  }) : super(CameraInitial()) {
    on<CameraInitialized>(_mapCameraInitializedToState);
    on<CameraCaptured>(_mapCameraCapturedToState);
    on<CameraGallery>(_mapCameraGalleryToState);
    on<CameraStopped>(_mapCameraStoppedToState);
    on<CameraFolder>(_mapCameraFolderToState);
    on<CameraChange>(_mapCameraChangeToState);
  }

  CameraController? getController() => _controller;

  bool? isInitialized() => _controller?.value.isInitialized;

  _mapCameraInitializedToState(CameraInitialized event, emit) async {
    try {
      _controller = await cameraUtils.getCameraController(
          resolutionPreset, cameraLensDirection);
      await _controller!.initialize();
      emit(CameraReady());
    } on CameraException catch (error) {
      _controller!.dispose();
      emit(CameraFailure(error: error.description!));
    } catch (error,stackTrace) {
      emit(CameraFailure(error: error.toString()));
      await FirebaseCrashlytics.instance.recordError(error, stackTrace);
    }
  }


  _mapCameraCapturedToState(CameraCaptured event, emit) async {
    if (_controller != null && _controller!.value.isInitialized) {
      emit(CameraCaptureInProgress());
      try {
        final path = await cameraUtils.getPath();
        final imageCount = await countImagesInCache();
        if (imageCount >= 3) {
          emit(CameraCaptureFailure(error: 'Solo se permiten 3 fotos'));
        } else {
          //BLOC CAMERA TO TAKE PICTURE FAST [https://github.com/flutter/flutter/issues/84957]
          await _controller?.setFocusMode(FocusMode.locked);
          await _controller?.setExposureMode(ExposureMode.locked);

          final picture = await _controller?.takePicture();
          // REVERT CAMERA CONFIGURATION [https://github.com/flutter/flutter/issues/84957]
          await _controller?.setFocusMode(FocusMode.auto);
          await _controller?.setExposureMode(ExposureMode.auto);

          var photo = Photo(name: picture!.name, path: picture.path);

          // Imprimir el tamaño de la imagen original
          final originalImageSize = File(picture.path).lengthSync();

          final compressedImageSize = await compressAndSaveImage(photo.path);
          await databaseRepository.insertPhoto(photo);
          emit(CameraCaptureSuccess(path));
        }
      } on CameraException catch (error) {
        emit(CameraCaptureFailure(error: error.description!));
      } catch (error, stackTrace) {
        emit(CameraFailure(error: error.toString()));
        await FirebaseCrashlytics.instance.recordError(error, stackTrace);
      }
    } else {
      emit(const CameraFailure(error: 'Camera is not ready'));
    }
  }

  _mapCameraGalleryToState(CameraGallery event, emit) async {
    if (_controller != null && _controller!.value.isInitialized) {
      emit(CameraCaptureInProgress());
      try {
        final picker = ImagePicker();
        final pickedImage = await picker.pickImage(source: ImageSource.gallery);

        if (pickedImage != null) {
          final cacheDirectory = await getTemporaryDirectory();
          final imageCount = await countImagesInCache();
          if (imageCount >= 3) {
            ScaffoldMessenger.of(navigationService.navigatorKey.currentState!.context).showSnackBar(const SnackBar(
              duration: Duration(seconds: 1),
              content: Text("Solo se permiten 3 fotos"),
            ));
          } else {
            final imageFile = File(pickedImage.path);
            final fileFormat = imageFile.path.split('.').last.toLowerCase();

            if (fileFormat == 'jpg' || fileFormat == 'png') {
              final uniqueFileName = '${DateTime.now().millisecondsSinceEpoch}.$fileFormat';
              final filePathInCache = '${cacheDirectory.path}/$uniqueFileName';
              final originalImageSize = imageFile.lengthSync();

              await imageFile.copy(filePathInCache);
              final compressedImageSize = await compressAndSaveImage(filePathInCache);

              var photo = Photo(name: uniqueFileName, path: filePathInCache);
              await databaseRepository.insertPhoto(photo);
              emit(CameraCaptureSuccess(filePathInCache));
            } else {
              emit(CameraCaptureFailure(
                  error: 'El formato de archivo no es compatible'));
            }
          }
        } else {
          emit(const CameraFailure(error: 'Selección de imagen cancelada'));
        }
      } catch (error, stackTrace) {
        emit(CameraCaptureFailure(error: error.toString()));
        await FirebaseCrashlytics.instance.recordError(error, stackTrace);
      }
    } else {
      emit(const CameraFailure(error: 'Camera is not ready'));
    }
  }

  Future<int?> compressAndSaveImage(String imagePath) async {
    try {
      final File originalImage = File(imagePath);
      img.Image image = img.decodeImage(originalImage.readAsBytesSync())!;
      if (image.width > image.height) {
        image = await rotateImage(image);
      }
      final File compressedImage = File(imagePath)
        ..writeAsBytesSync(img.encodeJpg(image, quality:60));
      return compressedImage.lengthSync();
    } catch (error, stackTrace) {
      helperFunctions.handleException(error, stackTrace);
      return null;
    }
  }


  Future<img.Image> rotateImage(img.Image image) async {
    return await Future.microtask(() {
      return img.copyRotate(image, angle: 90);
    });
  }

  Future<int> countImagesInCache() async {
    try {
      final cacheDirectory = await getTemporaryDirectory();
      final files = cacheDirectory.listSync();

      int imageCount = 0;
      for (final file in files) {
        if (file is File) {
          final extension = file.path.split('.').last.toLowerCase();
          if (extension == 'jpg' || extension == 'png') {
            imageCount++;
          }
        }
      }
      return imageCount;
    } catch (error) {
      return -1;
    }
  }

  _mapCameraFolderToState(CameraFolder event, emit) {
    navigationService.goTo(AppRoutes.photo);
    emit(CameraReady());
  }

  _mapCameraChangeToState(CameraChange event, emit) {
    emit(const CameraChangeLen("front"));
  }

  _mapCameraStoppedToState(CameraStopped event, emit) {
    _controller?.dispose();
    emit(CameraInitial());
  }

  @override
  Future<void> close() {
    _controller?.dispose();
    return super.close();
  }
}
