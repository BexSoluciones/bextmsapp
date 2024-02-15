import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

//config
import '../../../../../config/size.dart';

//blocs
import '../../../../blocs/history_order/history_order_bloc.dart';

//models
import '../../../../../domain/models/work.dart';
import '../../../../../domain/models/arguments.dart';
import '../../../../../domain/models/history_order.dart';
import '../../../../../domain/models/processing_queue.dart';
import '../../../../../domain/repositories/database_repository.dart';
import '../../../../../domain/abstracts/format_abstract.dart';

//utils
import '../../../../../utils/constants/strings.dart';
import '../../../../../utils/constants/colors.dart';

//services
import '../../../../../locator.dart';
import '../../../../../services/pushnotification.dart';
import '../../../../../services/navigation.dart';
import '../../../../../services/storage.dart';

//widget
import '../../../../../presentation/widgets/confirm_dialog.dart';
import '../../../../../presentation/widgets/custom_dialog.dart';

final NavigationService _navigationService = locator<NavigationService>();
final LocalStorageService _storageService = locator<LocalStorageService>();
final DatabaseRepository _databaseRepository = locator<DatabaseRepository>();

class ItemWork extends StatefulWidget {
  const ItemWork({super.key, required this.work});

  final Work work;

  @override
  State<ItemWork> createState() => _ItemWorkState();
}

class _ItemWorkState extends State<ItemWork> with FormatDate {
  late HistoryOrderBloc historyOrderBloc;
  static final FirebaseMessaging _firebaseMessaging =
      FirebaseMessaging.instance;
  bool isLoading = true;
  bool success = false;
  var connectivity = Connectivity();
  bool loading = false;

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void initState() {
    historyOrderBloc = BlocProvider.of<HistoryOrderBloc>(context);
    final pushNotificationService = PushNotificationService(_firebaseMessaging);
    pushNotificationService.initialise();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final calculatedFon = getProportionateScreenHeight(14);

    return Material(
      child: BlocConsumer<HistoryOrderBloc, HistoryOrderState>(
        listener: (context, state) {
          // TODO: implement listener
        },
        builder: (context, state) {
          return Slidable(
            key: const ValueKey(0),
            endActionPane: _storageService.getBool('can_make_history') == true
                ? ActionPane(motion: const ScrollMotion(), children: [
                    SlidableAction(
                      borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(15),
                          bottomRight: Radius.circular(15)),
                      onPressed: (_) {
                        if (widget.work.count! == widget.work.left!) {
                          showDialog(
                              context: context,
                              builder: (context) => CustomConfirmDialog(
                                  title: 'Guardar historico',
                                  message:
                                      '¿Está seguro que desea guardar el historico?',
                                  cancelButton: false,
                                  buttonText: 'Aceptar',
                                  onConfirm: () =>
                                      _handleNavigation(widget.work, context)));
                        } else {
                          showDialog(
                              context: context,
                              builder: (context) => CustomDialog(
                                    title: 'Clientes pendientes por visitar',
                                    message:
                                        'Cantidad :${widget.work.count! - widget.work.left!}',
                                    elevatedButton1: Colors.red,
                                    elevatedButton2: Colors.green,
                                    cancelarButtonText: '',
                                    completarButtonText: 'Aceptar',
                                    icon: Icons.warning,
                                    colorIcon: kPrimaryColor,
                                  ));
                        }
                      },
                      backgroundColor: kPrimaryColor,
                      foregroundColor: Colors.white,
                      icon: Icons.save,
                      label: 'Guardar historico',
                    ),
                  ])
                : null,
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .primaryContainer
                    .withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: ListTile(
                      onTap: () => _onTap(context, widget.work),
                      title: Text(
                        'Servicio: ${widget.work.workcode}',
                        style: TextStyle(
                            fontSize: calculatedFon,
                            fontWeight: FontWeight.w500),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Clientes: ${widget.work.count}',
                            style: TextStyle(
                                fontWeight: FontWeight.normal,
                                fontSize: calculatedFon,
                                color: Theme.of(context).colorScheme.scrim),
                          ),
                          Wrap(
                            spacing: 10,
                            children: [
                              Text(
                                'Atendidos: ${widget.work.left}',
                                style: TextStyle(
                                    fontSize: calculatedFon,
                                    fontWeight: FontWeight.normal,
                                    color: Theme.of(context).colorScheme.scrim),
                              ),
                              Text(
                                'Pendientes: ${widget.work.count! - widget.work.left!}',
                                style: TextStyle(
                                    fontSize: calculatedFon,
                                    fontWeight: FontWeight.normal,
                                    color: Theme.of(context).colorScheme.scrim),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  _storageService.getBool('can_make_history') == true
                      ? const Center(
                          child: Padding(
                          padding: EdgeInsets.all(20.0),
                          child: Icon(
                              size: 25,
                              color: Colors.deepOrange,
                              Icons.swipe_left_outlined),
                        ))
                      : const SizedBox(),
                  const SizedBox(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _handleNavigation(Work work, BuildContext context) async {
    try {
      var processingQueue = ProcessingQueue(
          body: jsonEncode({'work_id': work.id}),
          task: 'incomplete',
          code: 'store_history_order',
          createdAt: now(),
          updatedAt: now());

      _databaseRepository.insertProcessingQueue(processingQueue);

      setState(() {
        success = true;
      });
    } catch (e, stackTrace) {
      setState(() {
        success = false;
      });
      //await helperFunctions.handleException(e, stackTrace);
    }

    if (success) {
      // Show success message to user
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Historico guardado.',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Algo inesperado sucedió',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _onTap(BuildContext context, Work work) {
    showDialog(
      context: context,
      builder: (BuildContext context) => const Center(
        child: CupertinoActivityIndicator(),
      ),
    );

    var used = _storageService.getBool('${work.workcode}-used');
    var uploaded = _storageService.getBool('${work.workcode}-uploaded');

    if (used != null && uploaded != null && !uploaded) {
      historyOrderBloc.add(ChangeCurrentWork(work: work));
      _storageService.setBool('${work.workcode}-uploaded', true);
    } else {
      historyOrderBloc.add(HistoryOrderInitialRequest(
        work: work,
        context: context,
      ));
    }

    BlocListener<HistoryOrderBloc, HistoryOrderState>(
        listener: (context, state) {
      Navigator.pop(context);

      if (state is HistoryOrderShow) {
        final showAgain =
            _storageService.getBool('${widget.work.workcode}-showAgain') ??
                true;

        if (state.historyOrder != null && showAgain == false) {
          _navigationService.goTo(AppRoutes.history,
              arguments: HistoryArgument(
                  work: work,
                  likelihood: state.historyOrder!.likelihood!,
                  differents: state.historyOrder!.different));
        } else {
          _navigationService.goTo(AppRoutes.work,
              arguments: WorkArgument(work: widget.work));
        }
      }
    });
  }
}
