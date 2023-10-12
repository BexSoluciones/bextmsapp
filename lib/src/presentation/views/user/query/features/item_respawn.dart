import 'package:flutter/material.dart';

//domain
import '../../../../../domain/models/work.dart';
import '../../../../../domain/abstracts/format_abstract.dart';

class ItemRespawn extends StatelessWidget with FormatNumber {
  ItemRespawn({Key? key, required this.data, required this.reason }) : super(key: key);

  final WorkAdditional data;
  final String reason;

  @override
  @override
  Widget build(BuildContext context) {
    return Material(
      child: Ink(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: ListTile(
          title: Text(
            'Cliente: ${data.work.customer}',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Estado: $reason',
                style: TextStyle(
                    fontSize: 14, fontWeight: FontWeight.normal,color: Theme.of(context).colorScheme.scrim),
              ),
              Text(
                'Factura: ${data.orderNumber}',
                style:  TextStyle(
                    fontSize: 14, fontWeight: FontWeight.normal,color: Theme.of(context).colorScheme.scrim),
              ),
              const SizedBox(
                height: 3,
              ),
              Text(
                'Valor Factura: ${formatter.format(data.totalSummary)}',
                style:  TextStyle(
                    fontSize: 14, fontWeight: FontWeight.normal,color: Theme.of(context).colorScheme.scrim),
              ),
              const SizedBox(
                height: 3,
              ),
              Text(
                'Recaudado: ${formatter.format(data.totalPayment)}',
                style:  TextStyle(
                    fontSize: 14, fontWeight: FontWeight.normal,color: Theme.of(context).colorScheme.scrim),
              ),

            ],
          ),
        ),
      ),
    );
  }
}
