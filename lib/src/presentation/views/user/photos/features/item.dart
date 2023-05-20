import 'dart:io';
import 'package:flutter/material.dart';

//domain
import '../../../../../domain/models/photo.dart';

//utils
import '../../../../../utils/constants/keys.dart';
import '../../../../../utils/constants/strings.dart';

//features
import 'detail.dart';

class PhotoCard extends StatelessWidget {
  final Photo photo;

  const PhotoCard({Key key = MyPhotosKeys.photoCard, required this.photo})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () =>
          Navigator.pushNamed(context, detailPhotoRoute, arguments: photo),
      child: Card(
        elevation: 5.0,
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.file(
                File(photo.path),
                fit: BoxFit.cover,
              ),
            ),
            Positioned(
              bottom: 10,
              left: 10,
              child: Container(
                alignment: Alignment.center,
                child: Text(
                  photo.name,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
