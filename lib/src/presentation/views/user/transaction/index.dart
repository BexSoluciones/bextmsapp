import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';

//bloc
import '../../../../presentation/blocs/processing_queue/processing_queue_bloc.dart';

//domain
import '../../../../domain/models/processing_queue.dart';
import '../../../../domain/models/work.dart';
import '../../../../domain/abstracts/format_abstract.dart';

//widgets
import '../../../widgets/default_button_widget.dart';

class TransactionView extends StatefulWidget {
  const TransactionView({Key? key}) : super(key: key);

  @override
  State<TransactionView> createState() => _TransactionViewState();
}

class _TransactionViewState extends State<TransactionView> with FormatNumber {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  late ProcessingQueueBloc processingQueueBloc;

  late Stream stream;
  late StreamSubscription subscription;
  int computationCount = 0;

  var works = <Work>[];

  @override
  void initState() {
    processingQueueBloc = BlocProvider.of<ProcessingQueueBloc>(context);

    stream = Stream.periodic(const Duration(seconds: 1), (int count) async {
      return processingQueueBloc.countProcessingQueueIncompleteToTransactions();
    });

    subscription = stream.listen((event) async {
      var int = await event;
      setState(() {
        computationCount = int;
      });
    });

    super.initState();
  }

  @override
  void dispose() {
    subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
          toolbarHeight: 80,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Transacciones',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              Text(
                  DateTime.now()
                      .toIso8601String()
                      .split('.')[0]
                      .split('T')
                      .join(' '),
                  style: const TextStyle(fontSize: 14))
            ],
          ),
        ),
        body: BlocBuilder<ProcessingQueueBloc, ProcessingQueueState>(
          builder: (_, state) {
            switch (state.runtimeType) {
              case ProcessingQueueInitial:
                return const Center(child: CupertinoActivityIndicator());
              case ProcessingQueueSuccess:
                return _buildHome();
              case ProcessingQueueSending:
                return _buildSender();
              default:
                return const SizedBox();
            }
          },
        ));
  }

  Widget _buildHome() {
    return StreamBuilder<List<ProcessingQueue>>(
        stream: processingQueueBloc.todos,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            var queues = snapshot.data;
            return SafeArea(
                child: Padding(
                    padding: const EdgeInsets.only(
                      top: 20.0,
                      left: 16.0,
                      right: 16.0,
                      bottom: 20.0,
                    ),
                    child: ListView(
                      shrinkWrap: true,
                      children: [
                        item(
                            'Transacciones de inicio de planilla',
                            queues
                                .where((queue) =>
                                    queue.code == "store_transaction_start")
                                .length,
                            null),
                        const SizedBox(height: 16),
                        item(
                            'Transacciones de llegada de cliente',
                            queues
                                .where((queue) =>
                                    queue.code == "store_transaction_arrived")
                                .length,
                            null),
                        const SizedBox(height: 16),
                        item(
                            'Transacciones de facturas vistas',
                            queues
                                .where((queue) =>
                                    queue.code == "store_transaction_summary")
                                .length,
                            null),
                        const SizedBox(height: 16),
                        item(
                            'Transacciones pendientes',
                            queues
                                .where((queue) => queue.task == "pending" || queue.task == "incomplete")
                                .length,
                            Colors.orange),
                        const SizedBox(height: 16),
                        item(
                            'Transacciones con error',
                            queues
                                .where((queue) => queue.task == "error")
                                .length,
                            Colors.red),
                        const SizedBox(height: 20),
                        item('Total', queues.length, null),
                        const SizedBox(height: 20),
                        queues
                                .where((queue) =>
                                    queue.task == "pending" ||
                                    queue.task == "error" ||
                                    queue.task == "incomplete")
                                .isNotEmpty
                            ? DefaultButton(
                                widget: const Text('Enviar transacciones',
                                    style: TextStyle(
                                        fontSize: 16, color: Colors.white)),
                                press: () => context
                                    .read<ProcessingQueueBloc>()
                                    .add(ProcessingQueueSender()))
                            : Container()
                      ],
                    )));
          }

          return const Center(child: CupertinoActivityIndicator());
        });
  }

  Widget item(String title, int cant, Color? color) {
    return Material(
      child: Ink(
        decoration: BoxDecoration(
          color: color?.withOpacity(0.7) ??
              Theme.of(context).colorScheme.primaryContainer.withOpacity(0.7),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: ListTile(
          title: Text(title,
              style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.w600)),
          trailing: Text(cant.toString(),
              style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.w500)),
        ),
      ),
    );
  }

  Widget _buildSender() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          Lottie.asset(
              'assets/animations/111789-file-transfers-over-cloud.json'),
          Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text('Enviando', style: TextStyle(fontSize: 16)),
                Text('1 de $computationCount',
                    style: const TextStyle(fontSize: 16))
              ]),
          const Spacer(),
          DefaultButton(
              color: Colors.grey[600],
              widget: const Text('Cancelar',
                  style: TextStyle(color: Colors.white, fontSize: 14)),
              press: () {
                context
                    .read<ProcessingQueueBloc>()
                    .add(ProcessingQueueCancel());
                ScaffoldMessenger.of(_scaffoldKey.currentContext ?? context)
                    .showSnackBar(const SnackBar(
                        backgroundColor: Colors.green,
                        content: Text('Todo se esta enviando exitosamente')));
              })
        ],
      ),
    );
  }
}
