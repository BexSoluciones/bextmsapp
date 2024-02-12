import 'package:flutter/material.dart';
//utils
import '../../../../../utils/constants/strings.dart';
//models
import '../../../../../domain/models/processing_queue.dart';
//services
import '../../../../../locator.dart';
import '../../../../../services/navigation.dart';

final NavigationService _navigationService = locator<NavigationService>();
class ProcessingQueueCard extends StatelessWidget {
  final ProcessingQueue processingQueue;

  const ProcessingQueueCard({super.key, required this.processingQueue});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: ListTile(
        onTap: () => _navigationService.goTo(AppRoutes.processingQueueDetail,
            arguments: processingQueue.id),
        title: Text(
          'CODIGO: ${processingQueue.code}',
          style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tarea: ${processingQueue.task}'),
            processingQueue.error != null
                ? Text('Error ${processingQueue.error}')
                : const SizedBox(),
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
