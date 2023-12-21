import 'package:bexdeliveries/src/utils/constants/gaps.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

//domain
import '../../../../domain/models/processing_queue.dart';

//bloc
import '../../../../utils/constants/colors.dart';
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

    processingQueueBloc.add(ProcessingQueueAll());

    processingQueueBloc.dropdownFilterValue =
        processingQueueBloc.itemsFilter.first['key'];
    processingQueueBloc.dropdownStateValue =
        processingQueueBloc.itemsState.first['key'];

    // TODO: implement initState
    super.initState();
  }

  void changeFilterValue(String? value) {
    processingQueueBloc.add(ProcessingQueueSearchFilter(value: value));
  }

  void changeStateValue(String? value) {
    processingQueueBloc.add(ProcessingQueueSearchState(value: value));
  }

  @override
  Widget build(BuildContext context) {
    var dropdownFilterValue =
        context.watch<ProcessingQueueBloc>().dropdownFilterValue;
    var dropdownStateValue =
        context.watch<ProcessingQueueBloc>().dropdownStateValue;
    var processingQueues =
        context.watch<ProcessingQueueBloc>().processingQueues;

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
                const Size.fromHeight(120.0), // here the desired height
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.grey, width: 2.0),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: kPrimaryColor, width: 2.0),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: kPrimaryColor, width: 2.0),
                        ),
                        hintStyle: TextStyle(
                          color: Colors.orange,
                        ),
                      ),
                      style: const TextStyle(
                        color: kPrimaryColor,
                      ),
                      value: dropdownFilterValue,
                      items: processingQueueBloc.itemsFilter.map((item) {
                        return DropdownMenuItem(
                          value: item['key'],
                          child: Text(item['value']!),
                        );
                      }).toList(),
                      onChanged: changeFilterValue),
                  gapH12,
                  DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.grey, width: 2.0),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: kPrimaryColor, width: 2.0),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: kPrimaryColor, width: 2.0),
                        ),
                        hintStyle: TextStyle(
                          color: Colors.orange,
                        ),
                      ),
                      style: const TextStyle(
                        color: kPrimaryColor,
                      ),
                      value: dropdownStateValue,
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
        ),
      ],
      // The content of the scroll view
      body: BlocConsumer<ProcessingQueueBloc, ProcessingQueueState>(
        // listenWhen: (current, previous) => current != previous,
        listener: (context, state) {},
        builder: (BuildContext context, ProcessingQueueState state) {
          return ListView.builder(
            itemCount: processingQueues.length,
            itemBuilder: (BuildContext context, int index) {
              return ProcessingQueueCard(
                processingQueue: processingQueueBloc.processingQueues[index],
              );
            },
          );
        },
      ),
    ));
  }
}
