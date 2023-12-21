import 'dart:async';
import 'dart:io';

import 'package:bexdeliveries/src/domain/models/photo.dart';
import 'package:bexdeliveries/src/domain/repositories/database_repository.dart';

import 'package:bloc/bloc.dart';
import 'package:camera/camera.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;

//utils
import '../../../utils/resources/camera.dart';
import '../../../utils/constants/strings.dart';

//services
import '../../../locator.dart';
import '../../../services/navigation.dart';

part 'camera_event.dart';
part 'camera_state.dart';

final NavigationService _navigationService = locator<NavigationService>();

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
    on<CameraGallery>(_mapCameraGalleryToState);
    on<CameraStopped>(_mapCameraStoppedToState);
    on<CameraFolder>(_mapCameraFolderToState);
    on<CameraChange>(_mapCameraChangeToState);
  }

  CameraController getController() => _controller;

  bool isInitialized() => _controller.value.isInitialized;

  _mapCameraInitializedToState(CameraInitialized event, emit) async {
    try {
      _controller = await cameraUtils.getCameraController(
          resolutionPreset, cameraLensDirection);
      await _controller.initialize();
      emit(CameraReady());
    } on CameraException catch (error) {
      _controller.dispose();
      emit(CameraFailure(error: error.description!));
    } catch (error,stackTrace) {
      emit(CameraFailure(error: error.toString()));
      await FirebaseCrashlytics.instance.recordError(error, stackTrace);
    }
  }

  _mapCameraCapturedToState(CameraCaptured event, emit) async {
    if (state is CameraReady) {
      emit(CameraCaptureInProgress());
      try {
        final path = await cameraUtils.getPath();
        final imageCount = await  countImagesInCache();
        if (imageCount >= 3) {
          emit(CameraCaptureFailure(error: 'Solo se permiten 3 fotos'));
        } else {
          var picture = await _controller.takePicture();
          var photo = Photo(name: picture.name, path: picture.path);
          await compressAndSaveImage(photo.path);
          await databaseRepository.insertPhoto(photo);
          emit(CameraCaptureSuccess(path));
        }
      } on CameraException catch (error) {
        emit(CameraCaptureFailure(error: error.description!));
      } catch (error,stackTrace) {
        emit(CameraFailure(error: error.toString()));
        await FirebaseCrashlytics.instance.recordError(error, stackTrace);
      }
    } else {
      emit(const CameraFailure(error: 'Camera is not ready'));
    }
  }


  _mapCameraGalleryToState(CameraGallery event, emit) async {
    if (state is! CameraReady) {
      emit(const CameraFailure(error: 'Camera is not ready'));
      return;
    }
    try {
      final picker = ImagePicker();
      final pickedImage = await picker.pickImage(source: ImageSource.gallery);
      if (pickedImage != null) {
        final cacheDirectory = await getTemporaryDirectory();
        final imageCount = await countImagesInCache();
        if (imageCount >= 3) {
          emit(CameraCaptureFailure(error: 'Solo se permiten 3 fotos'));
        } else {
          final imageFile = File(pickedImage.path);
          final fileFormat = imageFile.path.split('.').last.toLowerCase();

          if (fileFormat == 'jpg' || fileFormat == 'png') {


            final fileName = imageFile.uri.pathSegments.last;
            final filePathInCache = '${cacheDirectory.path}/$fileName';
            await compressAndSaveImage(filePathInCache);

            await imageFile.copy(filePathInCache);

            var photo = Photo(name: fileName, path: filePathInCache);
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
  }

  Future<void> compressAndSaveImage(String imagePath) async {
    try {
      final File originalImage = File(imagePath);
      img.Image image = img.decodeImage(originalImage.readAsBytesSync())!;
      if (image.width > image.height) {
        image = await rotateImage(image);
      }
      final File compressedImage = File(imagePath)
        ..writeAsBytesSync(img.encodeJpg(image, quality: 80));
    } catch (error) {

      print('Error al comprimir la imagen: $error');
    }
  }

  Future<img.Image> rotateImage(img.Image image) async {
    return await Future.microtask(() {
      return img.copyRotate(image, 90);
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
    _navigationService.goTo(AppRoutes.photo, arguments: event.path);
    emit(CameraReady());
  }

  _mapCameraChangeToState(CameraChange event, emit) {
    emit(const CameraChangeLen("front"));
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
