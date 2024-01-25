import 'package:flutter/material.dart';

//domain
import '../../../../../config/size.dart';
import '../../../../../domain/models/work.dart';
import '../../../../../domain/abstracts/format_abstract.dart';

class ItemCollection extends StatelessWidget with FormatNumber {
  ItemCollection({Key? key, required this.data}) : super(key: key);

  final WorkAdditional data;

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Ink(
        decoration: BoxDecoration(
          color:
              Theme.of(context).colorScheme.primaryContainer.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: ListTile(
          title: Text(
            'Cliente: ${data.work.customer}',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Estado: ${data.status == 'partial' ? 'Parcial' : 'Entrega'}',
                style: TextStyle(
                    fontSize: getProportionateScreenHeight(14),
                    color: Theme.of(context).colorScheme.scrim,
                    fontWeight: FontWeight.normal),
              ),
              Text(
                'Factura: ${data.orderNumber}',
                style: TextStyle(
                    fontSize: getProportionateScreenHeight(14),
                    color: Theme.of(context).colorScheme.scrim,
                    fontWeight: FontWeight.normal),
              ),
              SizedBox(
                height: getProportionateScreenHeight(3),
              ),
              Text(
                'Valor Factura: ${formatter.format(data.totalSummary)}',
                style: TextStyle(
                    fontSize: getProportionateScreenHeight(14),
                    color: Theme.of(context).colorScheme.scrim,
                    fontWeight: FontWeight.normal),
              ),
              SizedBox(
                height: getProportionateScreenHeight(3),
              ),
              Text(
                'Recaudado: ${formatter.format(data.totalPayment)}',
                style: TextStyle(
                    fontSize: getProportionateScreenHeight(14),
                    color: Theme.of(context).colorScheme.scrim,
                    fontWeight: FontWeight.normal),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
