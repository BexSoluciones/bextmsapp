import 'dart:convert';

import 'package:flutter/material.dart';

//models
import '../../../../../domain/models/processing_queue.dart';

class ProcessingQueueCardDetail extends StatelessWidget {
  final ProcessingQueue processingQueue;

  const ProcessingQueueCardDetail({super.key, required this.processingQueue});

  @override
  Widget build(BuildContext context) {

    var items = <Widget>[];

    jsonDecode(processingQueue.body).forEach((final String key, final value) {
      items.add(ListTile(
        title: Text(key),
        subtitle: value != null ? Text(value.toString()) : const Text('Sin data'),
      ));
    });

    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: ListView(
          children: items
        )
      ),
    );
  }
}
