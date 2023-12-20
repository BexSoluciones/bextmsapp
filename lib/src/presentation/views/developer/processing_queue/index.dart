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

class ProcessingQueueView extends StatefulWidget {
  const ProcessingQueueView({super.key});

  @override
  State<ProcessingQueueView> createState() => _ProcessingQueueViewState();
}

class _ProcessingQueueViewState extends State<ProcessingQueueView> {
  late ProcessingQueueBloc processingQueueBloc;

  @override
  void initState() {
    processingQueueBloc = context.read<ProcessingQueueBloc>();
    processingQueueBloc.dropdownFilterValue =
        processingQueueBloc.itemsFilter.first['key'];
    processingQueueBloc.dropdownStateValue =
        processingQueueBloc.itemsState.first['key'];

    // TODO: implement initState
    super.initState();
  }

  void changeFilterValue(String? value) {
    processingQueueBloc.dropdownFilterValue = value;
  }

  void changeStateValue(String? value) {
    processingQueueBloc.dropdownStateValue = value;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) => [
        SliverAppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new),
            onPressed: () => _navigationService.goBack(),
          ),
          expandedHeight: 100,
          pinned: true,
          forceElevated: innerBoxIsScrolled,
          actions: [
            IconButton(
                onPressed: () =>
                    processingQueueBloc.add(ProcessingQueueObserve()),
                icon: const Icon(Icons.refresh))
          ],
          bottom: PreferredSize(
            preferredSize:
                const Size.fromHeight(80.0), // here the desired height
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropdownButton<String>(
                    value: processingQueueBloc.dropdownFilterValue,
                    items: processingQueueBloc.itemsFilter.map((item) {
                      return DropdownMenuItem(
                        value: item['key'],
                        child: Text(item['value']!),
                      );
                    }).toList(),
                    onChanged: changeFilterValue),
                DropdownButton<String>(
                    value: processingQueueBloc.dropdownStateValue,
                    items: processingQueueBloc.itemsState.map((item) {
                      return DropdownMenuItem(
                        value: item['key'],
                        child: Text(item['value']!),
                      );
                    }).toList(),
                    onChanged: changeStateValue),
              ],
            ),
          ),
        ),
      ],
      // The content of the scroll view
      body: StreamBuilder<List<ProcessingQueue>>(
        stream: processingQueueBloc.todosFilter,
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
    ));
  }
}
