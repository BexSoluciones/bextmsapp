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

    var values = jsonDecode(processingQueue.body!);

    if (values is Map<String, dynamic>) {
      values.forEach((final String key, final value) {
        items.add(ListTile(
          title: Text(key),
          subtitle:
              value != null ? Text(value.toString()) : const Text('Sin data'),
        ));
      });
    } else if (values is List) {
      items.add(ListTile(
        title: const Text('localizaciones'),
        subtitle: Text(values.toString()),
      ));
    }

    return Scaffold(
      appBar: AppBar(),
      body: Center(child: ListView(children: items)),
    );
  }
}
