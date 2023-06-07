import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

//blocs
import '../../../../blocs/historic_order/history_order_bloc.dart';

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
    return BlocListener<HistoryOrderBloc, HistoryOrderState>(
        listener: (context, state) {
          Navigator.pop(context);

          if (state is HistoryOrderShow) {
            final showAgain = _storageService.getBool('${widget.work.workcode}-showAgain') ?? true;

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
        },
        child: Material(
          child: Ink(
            decoration: BoxDecoration(
              color: Theme.of(context)
                  .colorScheme
                  .primaryContainer
                  .withOpacity(0.7),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: ListTile(
              onTap: () => _onTap(context, widget.work),
              title: Text(
                'Servicio: ${widget.work.workcode}',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              subtitle: Row(
                children: [
                  Text(
                    'Clientes: ${widget.work.count}',
                    style: const TextStyle(
                        fontWeight: FontWeight.normal, fontSize: 14),
                  ),
                  Flexible(
                      child: Text(
                    ' Atendidos: ${widget.work.right ?? '0'} Pendientes: ${widget.work.left! - widget.work.right!}',
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.normal),
                    textAlign: TextAlign.center,
                  ))
                ],
              ),
            ),
          ),
        ));
  }

  void _onTap(BuildContext context, Work work) {
    showDialog(
      context: context,
      builder: (BuildContext context) => const Center(
        child: CupertinoActivityIndicator(),
      ),
    );

    historyOrderBloc.add(HistoryOrderStart(work: work, context: context));
  }
}
