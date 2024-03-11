import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

//config
import '../../../../../config/size.dart';

//domain
import '../../../../../domain/models/summary.dart';
import '../../../../../domain/models/arguments.dart';
import '../../../../../domain/abstracts/format_abstract.dart';

class ItemSummary extends StatelessWidget with FormatNumber {
  ItemSummary(
      {super.key,
      required this.arguments,
      required this.summary,
      required this.isArrived,
      required this.onTap});

  final SummaryArgument arguments;
  final Summary summary;
  final bool isArrived;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    final calculatedTextScaleFactor = textScaleFactor(context);
    return Material(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        child: Ink(
          decoration: BoxDecoration(
            color:
                Theme.of(context).colorScheme.primaryContainer.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: ListTile(
            enabled: summary.hasTransaction == 0,
            onTap: onTap,
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
                      '${summary.type} - ${summary.orderNumber}',
                      textScaler: TextScaler.linear(calculatedTextScaleFactor),
                      style: const TextStyle(fontSize: 16),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (summary.expedition != null)
                      Text(
                        'Expedición: ${summary.expedition}',
                        textScaler:
                            TextScaler.linear(calculatedTextScaleFactor),
                        style: TextStyle(
                            fontSize: 16,
                            color: Theme.of(context).colorScheme.scrim),
                      ),
                  ],
                ),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Items: ${summary.expedition != null ? (summary.totalSummary ?? 0) : summary.count.toString()}',
                        textScaler:
                            TextScaler.linear(calculatedTextScaleFactor),
                        style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context).colorScheme.scrim),
                      ),
                    ]),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total:  ${formatter.format(summary.grandTotalCopy)}',
                      textScaler: TextScaler.linear(calculatedTextScaleFactor),
                      style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).colorScheme.scrim),
                    ),
                    Text(
                      'Tipo: ${summary.typeOfCharge}',
                      textScaler: TextScaler.linear(calculatedTextScaleFactor),
                      style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).colorScheme.scrim),
                    ),
                  ],
                )
              ],
            ),
            trailing: summary.loading!
                ? const CupertinoActivityIndicator()
                : summary.typeTransaction == 'entrega'
                    ? Icon(Icons.local_shipping,
                        color: Theme.of(context).colorScheme.scrim)
                    : Icon(Icons.hail,
                        color: Theme.of(context).colorScheme.scrim),
          ),
        ),
      ),
    );
  }
}
