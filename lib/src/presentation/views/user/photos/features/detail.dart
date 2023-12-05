import 'dart:io';
import 'package:bexdeliveries/src/domain/repositories/database_repository.dart';
import 'package:bexdeliveries/src/presentation/blocs/camera/camera_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:path_provider/path_provider.dart';

//domain
import '../../../../../domain/models/photo.dart';

//blocs
import '../../../../blocs/photo/photo_bloc.dart';

class DetailPhotoView extends StatefulWidget {
  const DetailPhotoView({super.key, required this.photo});

  final Photo photo;

  @override
  State<DetailPhotoView> createState() => _DetailPhotoViewState();
}

class _DetailPhotoViewState extends State<DetailPhotoView> {
  Photo? _currentPhoto;

  @override
  void initState() {
    super.initState();
    _currentPhoto = widget.photo;
  }

  @override
  Widget build(BuildContext context) {
    deletePhoto() {
      BlocProvider.of<PhotosBloc>(context)
          .add(PhotosDeleted(photo: _currentPhoto!));
      Navigator.of(context).pop();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_currentPhoto!.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => deletePhoto(),
          ),
          IconButton(
              icon: const Icon(Icons.crop),
              onPressed: () async {
                final updatedPhoto = await _cropImage();
                if (updatedPhoto != null) {
                  setState(() {
                    _currentPhoto = updatedPhoto;
                  });
                }
              }),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SizedBox(
            width: double.infinity,
            child: Image.file(File(_currentPhoto!.path), fit: BoxFit.cover),
          ),
        ),
      ),
    );
  }

  Future<Photo?> _cropImage() async {
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: _currentPhoto!.path,
      compressFormat: ImageCompressFormat.jpg,
      compressQuality: 100,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Recortar imagen',
          toolbarColor: Colors.deepOrange,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false,
        ),
        IOSUiSettings(
          title: 'Recortar imagen',
        ),
        WebUiSettings(
          context: context,
          presentStyle: CropperPresentStyle.dialog,
          boundary: const CroppieBoundary(
            width: 520,
            height: 520,
          ),
          viewPort:
              const CroppieViewPort(width: 480, height: 480, type: 'circle'),
          enableExif: true,
          enableZoom: true,
          showZoomer: true,
        ),
      ],
    );

    if (croppedFile != null) {
      final originalPhoto = _currentPhoto!;
      final updatedPhoto =
          Photo(name: originalPhoto.name, path: croppedFile.path);
      final fileToDelete = File(originalPhoto.path);
      if (fileToDelete.existsSync()) {
        fileToDelete.delete();
      }
      setState(() {
        _currentPhoto = updatedPhoto;
        BlocProvider.of<PhotosBloc>(context)
            .add(PhotosAdded(photo: updatedPhoto));
      });
    }
    return null;
  }
}
