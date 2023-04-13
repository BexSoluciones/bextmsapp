import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

//domain
import '../../../../domain/models/processing_queue.dart';

//bloc
import '../../../blocs/processing_queue/processing_queue_bloc.dart';

//features
import 'features/item.dart';

//services
import '../../../../locator.dart';
import '../../../../services/navigation.dart';

final NavigationService _navigationService = locator<NavigationService>();

class ProcessingQueueView extends StatelessWidget {
  const ProcessingQueueView({super.key});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<ProcessingQueueBloc>();
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => _navigationService.goBack(),
        ),
        actions: [
          IconButton(
              onPressed: () => context
                  .read<ProcessingQueueBloc>()
                  .add(ProcessingQueueObserve()),
              icon: const Icon(Icons.refresh))
        ],
      ),
      body: StreamBuilder<List<ProcessingQueue>>(
        stream: bloc.todos,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView.builder(
            itemCount: snapshot.data.length,
            itemBuilder: (BuildContext context, int index) {
              return ProcessingQueueCard(
                processingQueue: snapshot.data[index],
              );
            },
          );
        },
      ),
    );
  }
}
