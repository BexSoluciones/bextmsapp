import 'package:flutter/material.dart';

//models
import '../../../../../domain/models/transaction.dart';


class TransactionCard extends StatelessWidget {
  final Transaction transaction;

  const TransactionCard({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: ListTile(
        title: Text(
          '#:${transaction.orderNumber}',
          style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Estado ${transaction.status}'),
            Text('Fecha Inicio ${transaction.start}'),
            Text('Fecha Final ${transaction.end}'),
          ],
        ),
      ),
    );
  }
}
