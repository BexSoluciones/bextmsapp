import 'package:bexdeliveries/src/config/size.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

//domain
import '../../../../../domain/models/summary.dart';
import '../../../../../domain/models/arguments.dart';
import '../../../../../domain/abstracts/format_abstract.dart';

class ItemSummary extends StatefulWidget {
  const ItemSummary(
      {Key? key,
      required this.arguments,
      required this.summary,
      required this.isArrived,
      required this.onTap})
      : super(key: key);

  final SummaryArgument arguments;
  final Summary summary;
  final bool isArrived;
  final void Function()? onTap;

  @override
  State<ItemSummary> createState() => _ItemSummaryState();
}

class _ItemSummaryState extends State<ItemSummary> with FormatNumber {

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final calculatedTextScaleFactor = textScaleFactor(context);
    return Material(
      child: Ink(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: ListTile(
          enabled: widget.summary.hasTransaction == 0,
          onTap: widget.onTap,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          title: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${widget.summary.type} - ${widget.summary.orderNumber} - ${widget.summary.id}',
                    textScaler: TextScaler.linear(calculatedTextScaleFactor),
                    style: const TextStyle(fontSize: 16),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (widget.summary.expedition != null)
                    Text(
                      'Expedición: ${widget.summary.expedition}',
                      textScaler: TextScaler.linear(calculatedTextScaleFactor),
                      style: TextStyle(fontSize: 16,color: Theme.of(context).colorScheme.scrim),
                    ),
                ],
              ),
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text(
                  'Items: ${widget.summary.count.toString()}',
                  textScaler: TextScaler.linear(calculatedTextScaleFactor),
                  style: TextStyle(fontSize: 14,color: Theme.of(context).colorScheme.scrim),
                ),
              ]),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total:  ${formatter.format(widget.summary.grandTotalCopy)}',
                    textScaler: TextScaler.linear(calculatedTextScaleFactor),
                    style:  TextStyle(fontSize: 14,color: Theme.of(context).colorScheme.scrim),
                  ),
                  Text(
                    'Tipo: ${widget.summary.typeOfCharge}',
                    textScaler: TextScaler.linear(calculatedTextScaleFactor),
                    style:  TextStyle(fontSize: 14,color: Theme.of(context).colorScheme.scrim),
                  ),
                ],
              )
            ],
          ),
          trailing: widget.summary.loading!
              ? const CupertinoActivityIndicator()
              : widget.summary.typeTransaction == 'entrega'
                  ?  Icon(Icons.local_shipping,color: Theme.of(context).colorScheme.scrim)
                  :  Icon(Icons.hail,color: Theme.of(context).colorScheme.scrim),
        ),
      ),
    );
  }
}
