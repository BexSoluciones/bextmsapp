part of 'photo_bloc.dart';

abstract class PhotosEvent extends Equatable {
  const PhotosEvent();


  @override
  List<Object> get props => [];
}

class PhotosLoaded extends PhotosEvent {}

class PhotosAdded extends PhotosEvent {
  final Photo photo;
  const PhotosAdded({required this.photo});
}

class PhotosDeleted extends PhotosEvent {
  final Photo photo;
  const PhotosDeleted({required this.photo});
}