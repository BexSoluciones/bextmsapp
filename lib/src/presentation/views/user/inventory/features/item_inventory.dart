import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vibration/vibration.dart';

//cubit
import '../../../../cubits/inventory/inventory_cubit.dart';

//domain
import '../../../../../domain/models/summary.dart';
import '../../../../../domain/models/arguments.dart';
import '../../../../../domain/abstracts/format_abstract.dart';
import '../../../../../domain/models/enterprise_config.dart';

class ItemInventory extends StatefulWidget {
  const ItemInventory(
      {Key? key,
      this.enterpriseConfig,
      required this.summaries,
      required this.summary,
      required this.isArrived,
      required this.arguments})
      : super(key: key);

  final EnterpriseConfig? enterpriseConfig;
  final List<Summary> summaries;
  final Summary summary;
  final bool isArrived;
  final InventoryArgument arguments;

  @override
  ItemInventoryState createState() => ItemInventoryState();
}

class ItemInventoryState extends State<ItemInventory> with FormatNumber {
  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> vibrate() async {
    var hasVibrate = await Vibration.hasVibrator();
    if (hasVibrate!) {
      await Vibration.vibrate(duration: 500);
    }
  }

  Future<void> minus() async {
    BlocProvider.of<InventoryCubit>(context).minus(widget.summary,
        widget.arguments.work.id!, widget.arguments.orderNumber);
  }

  Future<void> longMinus() async {
    BlocProvider.of<InventoryCubit>(context).longMinus(widget.summary,
        widget.arguments.work.id!, widget.arguments.orderNumber);
  }

  Future<void> increment() async {
    BlocProvider.of<InventoryCubit>(context).increment(widget.summary,
        widget.arguments.work.id!, widget.arguments.orderNumber);
  }

  Future<void> longIncrement() async {
    BlocProvider.of<InventoryCubit>(context).longIncrement(widget.summary,
        widget.arguments.work.id!, widget.arguments.orderNumber);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
        child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: ListTile(
                  onTap: () {
                    if (widget.summary.idPacking != null &&
                        widget.summary.packing != null) {
                      //navigate to package
                    }
                  },
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  title: Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                                child: widget.summary.idPacking != null &&
                                        widget.summary.packing != null
                                    ? Text(
                                        '${widget.summary.packing} - ${widget.summary.idPacking}',
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      )
                                    : Text(
                                        '${widget.summary.coditem} - ${widget.summary.nameItem}',
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      )),
                            widget.summary.packing != null &&
                                    widget.summary.idPacking != null
                                ? Row(
                                    children: [
                                      const Icon(Icons.info),
                                      Text('(${widget.summary.count})')
                                    ],
                                  )
                                : Container(),
                          ],
                        ),
                        widget.summary.idPacking != null &&
                                widget.summary.packing != null
                            ? Container()
                            : Text(
                                'U.M. ${double.parse(widget.summary.unitOfMeasurement).toStringAsFixed(2)} - N.M ${widget.summary.nameOfMeasurement}',
                                style: TextStyle(color: Colors.grey[500]),
                                overflow: TextOverflow.ellipsis,
                              ),
                        const SizedBox(height: 6),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SizedBox(
                                  width: 132,
                                  child: Row(
                                      mainAxisAlignment: widget.isArrived
                                          ? MainAxisAlignment.spaceBetween
                                          : MainAxisAlignment.center,
                                      children: [
                                        widget.isArrived == true &&
                                                widget.enterpriseConfig
                                                        ?.blockPartial ==
                                                    false
                                            ? InkWell(
                                                onLongPress: () async {
                                                  Future.wait(
                                                      [vibrate(), longMinus()]);
                                                },
                                                child: IconButton(
                                                    onPressed: () {
                                                      Future.wait(
                                                          [vibrate(), minus()]);
                                                    },
                                                    icon: const Icon(
                                                      Icons.exposure_minus_1,
                                                    )))
                                            : Container(),
                                        GestureDetector(
                                            onTap: () => widget.isArrived &&
                                                    widget.enterpriseConfig
                                                            ?.blockPartial ==
                                                        false
                                                ? showDialog(
                                                    context: context,
                                                    builder: (BuildContext
                                                            context) =>
                                                        Container())
                                                : null,
                                            child: Text(
                                              widget.summary.cant
                                                  .toStringAsFixed(0),
                                            )),
                                        widget.summary.minus != 0 &&
                                                widget.enterpriseConfig
                                                        ?.blockPartial ==
                                                    false
                                            ? InkWell(
                                                onLongPress: () async {
                                                  Future.wait([
                                                    vibrate(),
                                                    longIncrement()
                                                  ]);
                                                },
                                                child: IconButton(
                                                    onPressed: () async {
                                                      Future.wait([
                                                        vibrate(),
                                                        increment()
                                                      ]);
                                                    },
                                                    icon: const Icon(
                                                        Icons.exposure_plus_1)))
                                            : Container()
                                      ])),
                              Text(
                                'TOTAL: \$${formatter.format(widget.summary.grandTotal)}',
                                // textScaleFactor: textScaleFactor(context),
                                style: const TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.bold),
                              )
                            ]),
                      ],
                    ),
                  ),
                ))));
  }
}
