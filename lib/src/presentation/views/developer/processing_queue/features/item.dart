import 'package:flutter/material.dart';

//models
import '../../../../../domain/models/processing_queue.dart';

//feature
import 'detail.dart';

class ProcessingQueueCard extends StatelessWidget {
  final ProcessingQueue processingQueue;

  const ProcessingQueueCard({super.key, required this.processingQueue});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: ListTile(
        onTap: () => Navigator.of(context).push(MaterialPageRoute(
            builder: (context) =>
                ProcessingQueueCardDetail(processingQueue: processingQueue))),
        title: Text(
          'CODIGO: ${processingQueue.code}',
          style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tarea: ${processingQueue.task}'),
            processingQueue.error != null
                ? Text('Error ${processingQueue.error}')
                : Container(),
            Text('Fecha inicio ${processingQueue.createdAt}'),
            Text('Fecha fin      ${processingQueue.updatedAt}'),
          ],
        ),
        iconColor: processingQueue.task == "processing"
            ? Colors.orange
            : processingQueue.task == "error"
                ? Colors.red
                : processingQueue.task == "incomplete"
                    ? Colors.yellow
                    : Colors.green,
        leading: Icon(
          processingQueue.task == "processing"
              ? Icons.sync_problem_sharp
              : processingQueue.task == "error"
                  ? Icons.dangerous
                  : processingQueue.task == "incomplete"
                      ? Icons.task
                      : Icons.check_circle,
        ),
      ),
    );
  }
}
