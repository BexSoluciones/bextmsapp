import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

//blocs
import 'package:bexdeliveries/src/presentation/blocs/processing_queue/processing_queue_bloc.dart';

class ProcessingQueueCardDetail extends StatefulWidget {
  final int id;

  const ProcessingQueueCardDetail({super.key, required this.id});

  @override
  State<ProcessingQueueCardDetail> createState() =>
      _ProcessingQueueCardDetailState();
}

class _ProcessingQueueCardDetailState extends State<ProcessingQueueCardDetail> {
  @override
  void initState() {
    BlocProvider.of<ProcessingQueueBloc>(context)
        .add(ProcessingQueueOne(id: widget.id));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: BlocBuilder<ProcessingQueueBloc, ProcessingQueueState>(
          buildWhen: (previous, current) =>
              previous != current && current.processingQueue != null,
          builder: (context, state) {
            if (state.status == ProcessingQueueStatus.success) {
              return buildBody(state);
            } else if (state.status == ProcessingQueueStatus.loading) {
              return const Center(child: CupertinoActivityIndicator());
            } else {
              return const SizedBox();
            }
          }),
    );
  }

  Widget buildBody(ProcessingQueueState state) {
    var items = <Widget>[];

    if (state.processingQueue != null) {
      var values = jsonDecode(state.processingQueue!.body!);

      if (values is Map<String, dynamic>) {
        values.removeWhere((key, value) => key == "images");
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
    }

    return Center(child: ListView(children: items));
  }
}
