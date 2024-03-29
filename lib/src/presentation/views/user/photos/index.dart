import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

//blocs
import '../../../blocs/photo/photo_bloc.dart';

//utils
import '../../../../utils/constants/keys.dart';
import '../../../../utils/constants/strings.dart';

//widgets
import '../../../widgets/error.dart';

//features
import 'features/item.dart';

class PhotoView extends StatefulWidget {
  const PhotoView({super.key});

  @override
  PhotoViewState createState() => PhotoViewState();
}

class PhotoViewState extends State<PhotoView> {
  @override
  void initState() {
    BlocProvider.of<PhotosBloc>(context).add(PhotosLoaded());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mis Fotos"),
      ),
      body: BlocBuilder<PhotosBloc, PhotosState>(builder: (context, state) {
        if (state is PhotosLoadInProgress) {
          return const Center(
            child: CircularProgressIndicator(
              key: MyPhotosKeys.loadingScreen,
            ),
          );
        } else if (state is PhotosLoadSuccess) {
          return GridView.builder(
              key: MyPhotosKeys.photosGridScreen,
              itemCount: state.photos.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisSpacing: 10, mainAxisSpacing: 10, crossAxisCount: 2),
              itemBuilder: (_, index) {
                final photo = state.photos[index];
                final file = File(photo.path);
                if (file.existsSync()) {
                  return PhotoCard(photo: photo);
                } else {
                  return const SizedBox.shrink();
                }
              });
        } else if (state is PhotosLoadFailure) {
          return Error(key: MyPhotosKeys.errorScreen, message: state.error);
        } else {
          return Container(
            key: MyPhotosKeys.emptyContainerScreen,
          );
        }
      }),
    );
  }
}
