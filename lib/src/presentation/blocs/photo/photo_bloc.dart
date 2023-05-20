import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

//domain
import '../../../domain/models/photo.dart';

//providers
import '../../providers/photo_provider.dart';

part 'photo_event.dart';
part 'photo_state.dart';

class PhotosBloc extends Bloc<PhotosEvent, PhotosState> {
  final PhotoProvider photoProvider;

  PhotosBloc({required this.photoProvider}) : super(PhotosInitial()) {
    on<PhotosLoaded>(_mapPhotosLoadedToState);
    on<PhotosAdded>(_mapPhotosAddedToState);
    on<PhotosDeleted>(_mapPhotosDeletedToState);
  }

  _mapPhotosLoadedToState(PhotosLoaded event, emit) async {
    emit(PhotosLoadInProgress());
    try {
      final photos = await photoProvider.loadPhotos();
      print(photos.length);
      emit(PhotosLoadSuccess(photos: photos));
    } on Exception catch (error) {
      emit(PhotosLoadFailure(error: error.toString()));
    }
  }

  _mapPhotosAddedToState(PhotosAdded event, emit) async {
    if (state is PhotosLoadSuccess) {
      final photos = List<Photo>.from((state as PhotosLoadSuccess).photos)
        ..add(event.photo);
      emit(PhotosLoadInProgress());
      try {
        await photoProvider.addPhoto(event.photo);
        emit(PhotosLoadSuccess(photos: photos));
      } on Exception catch (error) {
        emit(PhotosLoadFailure(error: error.toString()));
      }
    }
  }

  _mapPhotosDeletedToState(PhotosDeleted event, emit) async {
    if (state is PhotosLoadSuccess) {
      final photos = List<Photo>.from((state as PhotosLoadSuccess).photos)
        ..remove(event.photo);

      emit(PhotosLoadInProgress());
      try {
        await photoProvider.deletePhoto(event.photo);
        emit(PhotosLoadSuccess(photos: photos));
      } on Exception catch (error) {
        emit(PhotosLoadFailure(error: error.toString()));
      }
    }
  }
}
