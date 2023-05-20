import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

//domain
import '../../../../../domain/models/photo.dart';

//blocs
import '../../../../blocs/photo/photo_bloc.dart';

class DetailPhotoView extends StatelessWidget {
  const DetailPhotoView({super.key, required this.photo });

  final Photo photo;

  @override
  Widget build(BuildContext context) {

    deletePhoto() {
      BlocProvider.of<PhotosBloc>(context).add(PhotosDeleted(photo: photo));
      Navigator.of(context).pop();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(photo.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => deletePhoto(),
          )
        ],
      ),
      body: Center(
          child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                  width: double.infinity,
                  child: Image.file(File(photo.path), fit: BoxFit.cover)))),
    );
  }
}
