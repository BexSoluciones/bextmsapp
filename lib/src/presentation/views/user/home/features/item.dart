import 'package:bexdeliveries/src/config/size.dart';
import 'package:bexdeliveries/src/presentation/widgets/confirm_dialog.dart';
import 'package:bexdeliveries/src/presentation/widgets/custom_dialog.dart';
import 'package:bexdeliveries/src/utils/constants/colors.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

//blocs
import '../../../../blocs/history_order/history_order_bloc.dart';

//models
import '../../../../../domain/models/work.dart';
import '../../../../../domain/models/arguments.dart';
import '../../../../../domain/models/history_order.dart';

//utils
import '../../../../../utils/constants/strings.dart';

//services
import '../../../../../locator.dart';
import '../../../../../services/navigation.dart';
import '../../../../../services/storage.dart';

final NavigationService _navigationService = locator<NavigationService>();
final LocalStorageService _storageService = locator<LocalStorageService>();

class ItemWork extends StatefulWidget {
  const ItemWork({Key? key, required this.work}) : super(key: key);

  final Work work;

  @override
  State<ItemWork> createState() => _ItemWorkState();
}

class _ItemWorkState extends State<ItemWork> {
  late HistoryOrderBloc historyOrderBloc;
  int left = 0;
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
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final calculatedTextScaleFactor = textScaleFactor(context);
    final calculatedFon = getProportionateScreenHeight(14);

    return Material(
      child: BlocConsumer<HistoryOrderBloc, HistoryOrderState>(
        listener: (context, state) {
          // TODO: implement listener
        },
        builder: (context, state) {
          return Slidable(
            key: const ValueKey(0),
            startActionPane: ActionPane(
              motion: const ScrollMotion(),
              children: [
                SlidableAction(
                  onPressed: (_) async {
                    var network = await connectivity.checkConnectivity();
                    setState(() {
                      loading = true;
                    });

                    try {
                      if (network == ConnectivityResult.wifi ||
                          network == ConnectivityResult.mobile) {
                        if (widget.work.count! == left) {
                          /*var queues = await database
                      .findAllProcesingQueue(widget.work.workcode);
                  await helperFunctions.procesingQueue(queues);*/
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            backgroundColor: Colors.red,
                            content: Text('Termina toda las planilla'),
                          ));
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          backgroundColor: Colors.green,
                          content: Text('No esta conectado a internet'),
                        ));
                      }
                    } catch (e) {
                      print('Error marcar como completada:$e');
                    } finally {
                      setState(() {
                        loading = false;
                      });
                    }
                  },
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(15),
                    bottomLeft: Radius.circular(15),
                  ),
                  backgroundColor: kPrimaryColor,
                  foregroundColor: Colors.white,
                  icon: loading
                      ? const Icon(Icons.send).icon
                      : Icons.cloud_upload_rounded,
                  label: loading ? 'Enviando...' : 'Marcar como completa',
                )
              ],
            ),
            endActionPane: ActionPane(motion: const ScrollMotion(), children: [
              SlidableAction(
                borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(15),
                    bottomRight: Radius.circular(15)),
                onPressed: (_) {
                  if (widget.work.count! == left) {
                    showDialog(
                        context: context,
                        builder: (context) => ConfirmDialog(
                            title: 'Guardar historico',
                            message:
                            '¿Está seguro que desea guardar el historico?',
                            //onConfirm: () => _handleNavigation(widget.work, context)
                            onConfirm: () =>
                                _handleNavigation(widget.work, context)));
                  } else {
                    showDialog(
                        context: context,
                        builder: (context) => CustomDialog(
                          title: 'Clientes pendientes por visitar',
                          message: 'Cantidad :${widget.work.count! - left}',
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
            ]),
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
                  const Center(
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Icon(
                          Icons.arrow_back_ios,
                          color: Colors.deepOrange,
                          size: 15,
                        ),
                      )),
                  Expanded(
                    child: ListTile(
                      onTap: () => _onTap(context, widget.work),
                      title: Text(
                        'Servicio: ${widget.work.workcode}',
                       textScaleFactor: calculatedTextScaleFactor,
                        style:  TextStyle(
                            fontSize: calculatedFon, fontWeight: FontWeight.w500),
                      ),
                      subtitle: Row(
                        children: [
                          Text(
                            'Clientes: ${widget.work.count}',
                            textScaleFactor:  calculatedTextScaleFactor,
                            style:  TextStyle(
                                fontWeight: FontWeight.normal, fontSize: calculatedFon,color: Theme.of(context).colorScheme.scrim),
                          ),
                          Flexible(
                              child: Text(
                                ' Atendidos: ${widget.work.right ?? '0'} Pendientes: ${widget.work.left! - widget.work.right!}',
                                textScaleFactor:  calculatedTextScaleFactor,
                                style:  TextStyle(
                                    fontSize: calculatedFon, fontWeight: FontWeight.normal,color: Theme.of(context).colorScheme.scrim),
                                textAlign: TextAlign.center,
                              ))
                        ],
                      ),
                    ),
                  ),
                  //_storageService.getBool('can_make_history') == true
                  true
                      ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Icon(
                            size: 15,
                            color: Colors.deepOrange,
                            Icons.arrow_forward_ios_rounded),
                      ))
                      : Container(),
                  Container(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }


  Future<void> _handleNavigation(Work work, BuildContext context) async {
    /*final queueBloc = BlocProvider.of<QueueBloc>(context);
    try {
      /*    var currentLocation = await _locationService.getLocation(); */
      String baseURL;
      baseURL = 'https://';
      String apiURL;
      apiURL = '.bexdeliveries.com/api/v1/works/transactions/history-order';
      String url;
      url = "${baseURL + _storageService.getString('company')! + apiURL}";

      var processingQueue = ProcesingQueueService(
        url: url,
        body: jsonEncode({'work_id': work.id}),
        task: 'incomplete',
        code: 'AS65C41656',
        created_at: DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
        location:
        null /* '${currentLocation.latitude}-${currentLocation.longitude}' */,
      );

      //_procesingQueueBloc.inAddPq.add(processingQueue);
      queueBloc.add(AddTaskEvent(processingQueue));

      setState(() {
        success = true;
      });
    } catch (e, stackTrace) {
      setState(() {
        success = false;
      });
      await helperFunctions.handleException(e, stackTrace);
    }

    if (success) {
      // Show success message to user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
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
        SnackBar(
          content: Text(
            'Algo inesperado sucedió',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }*/
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
          _navigationService.goTo(
            historyRoute,
            arguments: HistoryOrder.fromJson(state.historyOrder!.toJson()),
          );
        } else {
          _navigationService.goTo(workRoute,
              arguments: WorkArgument(work: widget.work));
        }
      }
    });
  }
}
