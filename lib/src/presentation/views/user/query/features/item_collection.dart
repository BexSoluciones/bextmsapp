import 'package:flutter/material.dart';

//domain
import '../../../../../domain/models/work.dart';
import '../../../../../domain/abstracts/format_abstract.dart';

class ItemCollection extends StatelessWidget with FormatNumber {
  ItemCollection({Key? key, required this.data }) : super(key: key);

  final WorkAdditional data;

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Ink(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.7),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: ListTile(
          title: Text(
            'Cliente: ${data.work.customer}',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          // subtitle: Column(
          //   crossAxisAlignment: CrossAxisAlignment.start,
          //   children: [
          //     Text(
          //       'Estado: ${data.status == 'partial' ? 'Parcial' : 'Entrega'}',
          //       textScaleFactor: textScaleFactor(context),
          //       style: TextStyle(
          //           fontSize: getProportionateScreenHeight(14), fontWeight: FontWeight.normal),
          //     ),
          //     Text(
          //       'Factura: ${data.orderNumber}',
          //       textScaleFactor: textScaleFactor(context),
          //       style: TextStyle(
          //           fontSize: getProportionateScreenHeight(14), fontWeight: FontWeight.normal),
          //     ),
          //     SizedBox(
          //       height: getProportionateScreenHeight(3),
          //     ),
          //     Text(
          //       'Valor Factura: ${formatter.format(data.totalSummary)}',
          //       textScaleFactor: textScaleFactor(context),
          //       style: TextStyle(
          //           fontSize: getProportionateScreenHeight(14), fontWeight: FontWeight.normal),
          //     ),
          //     SizedBox(
          //       height: getProportionateScreenHeight(3),
          //     ),
          //     Text(
          //       'Recaudado: ${formatter.format(data.totalPayment)}',
          //       textScaleFactor: textScaleFactor(context),
          //       style: TextStyle(
          //           fontSize: getProportionateScreenHeight(14), fontWeight: FontWeight.normal),
          //     ),
          //
          //   ],
          // ),
        ),
      ),
    );
  }
}
