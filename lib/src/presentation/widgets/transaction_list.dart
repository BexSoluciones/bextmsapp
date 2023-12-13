import 'package:bexdeliveries/src/domain/abstracts/format_abstract.dart';
import 'package:flutter/material.dart';

class TransactionList extends StatelessWidget with FormatNumber {
  final List<dynamic> selectedAccounts;
  final Function(double) onTotalChange;
  final Function(List<dynamic>) onDataRemove;

  TransactionList({
    super.key,
    required this.selectedAccounts,
    required this.onTotalChange,
    required this.onDataRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List<Widget>.generate(selectedAccounts.length, (index) {
        var currentValue = double.parse(selectedAccounts[index][0].toString());
        String bankName = selectedAccounts[index][1].toString();
        String date = selectedAccounts[index][2].toString();

        return Container(
          decoration: BoxDecoration(
            color:
                Theme.of(context).colorScheme.primaryContainer.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: ListTile(
            title: Text('Valor: ${formatter.format(currentValue)}'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [Text('Banco: $bankName'), Text('Fecha: $date')],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                onTotalChange(-currentValue);
                onDataRemove(selectedAccounts[index]);
              },
            ),
          ),
        );
      }),
    );
  }
}
