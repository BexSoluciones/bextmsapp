import 'package:bexdeliveries/src/config/size.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vibration/vibration.dart';

//utils
import '../../../../../utils/constants/colors.dart';

//cubit

import '../../../../cubits/inventory/inventory_cubit.dart';

//domain
import '../../../../../domain/models/summary.dart';
import '../../../../../domain/models/arguments.dart';
import '../../../../../domain/abstracts/format_abstract.dart';
import '../../../../../domain/models/enterprise_config.dart';

class ItemInventory extends StatefulWidget {
  const ItemInventory(
      {super.key,
      this.enterpriseConfig,
      required this.summaries,
      required this.summary,
      required this.isArrived,
      required this.arguments});

  final EnterpriseConfig? enterpriseConfig;
  final List<Summary> summaries;
  final Summary summary;
  final bool isArrived;
  final InventoryArgument arguments;

  @override
  ItemInventoryState createState() => ItemInventoryState();
}

class ItemInventoryState extends State<ItemInventory> with FormatNumber {
  late InventoryCubit inventoryCubit;

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void initState() {
    inventoryCubit = BlocProvider.of<InventoryCubit>(context);
    super.initState();
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

  Future<void> minus() async => inventoryCubit.minus(
      widget.summary,
      widget.arguments.summary.validate!,
      widget.arguments.work.id!,
      widget.arguments.summary.orderNumber);

  Future<void> longMinus() async => inventoryCubit.longMinus(
      widget.summary,
      widget.arguments.summary.validate!,
      widget.arguments.work.id!,
      widget.arguments.summary.orderNumber);

  Future<void> increment() async => inventoryCubit.increment(
      widget.summary,
      widget.arguments.summary.validate!,
      widget.arguments.work.id!,
      widget.arguments.summary.orderNumber);

  Future<void> longIncrement() async => inventoryCubit.longIncrement(
      widget.summary,
      widget.arguments.summary.validate!,
      widget.arguments.work.id!,
      widget.arguments.summary.orderNumber);

  changeCant() {
    return BlocBuilder<InventoryCubit, InventoryState>(
        builder: (context, state) {
      return AlertDialog(
        title: const Text('Cambiar la cantidad'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Form(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextFormField(
                    initialValue: state.quantity?.toString(),
                    decoration: const InputDecoration(
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey, width: 2.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: kPrimaryColor, width: 2.0),
                      ),
                    ),
                    onChanged: (value) =>
                        inventoryCubit.onChangeQuantity(value),
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.digitsOnly
                    ], // Only numbers can be entered
                  )
                ],
              ),
            ),
          )
        ]),
        actions: [
          TextButton(
              child: const Text('Cancelar'),
              onPressed: () async {
                Navigator.of(context).pop();
              }),
          TextButton(
              child: const Text('Aceptar'),
              onPressed: () async {
                inventoryCubit.changeQuantity(
                    widget.summary,
                    widget.arguments.summary.validate!,
                    widget.arguments.work.id!,
                    widget.arguments.summary.orderNumber);
                Navigator.of(context).pop();
              })
        ],
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final calculatedFon = getProportionateScreenHeight(12);
    return Material(
        child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .primaryContainer
                      .withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: ListTile(
                  onTap: () {
                    if (widget.summary.idPacking != null &&
                        widget.summary.packing != null) {
                      var arguments = PackageArgument(
                          work: widget.arguments.work,
                          summary: widget.arguments.summary);
                      inventoryCubit.goToPackage(arguments);
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
                                      Icon(Icons.info, color: Colors.grey[500]),
                                      Text('(${widget.summary.count ?? 1})')
                                    ],
                                  )
                                : const SizedBox(),
                          ],
                        ),
                        widget.summary.idPacking != null &&
                                widget.summary.packing != null
                            ? const SizedBox()
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
                                                    icon: Icon(
                                                        Icons.exposure_minus_1,
                                                        color:
                                                            Colors.grey[500])))
                                            : const SizedBox(),
                                        GestureDetector(
                                            onTap: () {
                                              if (widget.isArrived &&
                                                  widget.enterpriseConfig
                                                          ?.blockPartial ==
                                                      false) {
                                                inventoryCubit.onChangeQuantity(
                                                    widget.summary.cant
                                                        .toString());
                                                showDialog(
                                                    context: context,
                                                    builder: (BuildContext
                                                            context) =>
                                                        changeCant());
                                              }
                                            },
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
                                                    icon: Icon(
                                                        Icons.exposure_plus_1,
                                                        color:
                                                            Colors.grey[500])))
                                            : const SizedBox()
                                      ])),
                              Text(
                                'TOTAL: \$${formatter.format(widget.summary.grandTotal)}',
                                style: TextStyle(
                                    fontSize: calculatedFon,
                                    fontWeight: FontWeight.bold),
                              )
                            ]),
                      ],
                    ),
                  ),
                ))));
  }
}
