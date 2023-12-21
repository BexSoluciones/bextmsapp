import 'package:flutter/widgets.dart';
import 'dart:io';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class SingleImage extends StatelessWidget {
  final String qr;
  const SingleImage({super.key, required this.qr});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw Center(
        child: FutureBuilder<File>(
            future: DefaultCacheManager().getSingleFile(qr),
            builder: (context, snapshot) {
              return (snapshot.hasData)
                  ? Image.file(snapshot.data!)
                  : const Text('Imagen no disponible');
            }));
  }
}
