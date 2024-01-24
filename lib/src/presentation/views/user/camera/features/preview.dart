import 'dart:io';
import 'package:flutter/material.dart';

class PreviewScreen extends StatelessWidget {
  const PreviewScreen({super.key,
    required this.imageFile,
    required this.fileList,
  });

  final File imageFile;
  final List<File> fileList;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      backgroundColor: Colors.black,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {
                        //TODO [Heider Zapa] fix
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.white,
                    ),
                    child: const Icon(Icons.folder),
                  ),
                  TextButton(
                    onPressed: () async {
                      await imageFile.delete();
                      fileList.remove(imageFile);
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: const Icon(Icons.delete),
                  ),
                ],
              )),
          Expanded(
            child: Image.file(imageFile),
          ),
        ],
      ),
    );
  }
}
