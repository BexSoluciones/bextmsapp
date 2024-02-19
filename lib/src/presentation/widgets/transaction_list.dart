import 'package:bexdeliveries/src/domain/abstracts/format_abstract.dart';
import 'package:bexdeliveries/src/domain/models/account.dart';
import 'package:flutter/material.dart';

class TransactionList extends StatelessWidget with FormatNumber {
  final List<AccountPayment> selectedAccounts;
  final Function(AccountPayment, double) onDataRemove;
  final Function(int index) onDataEdit;

  TransactionList(
      {super.key,
      required this.selectedAccounts,
      required this.onDataRemove,
      required this.onDataEdit});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: selectedAccounts.length,
      shrinkWrap: true,
      separatorBuilder: (BuildContext context, i) => const SizedBox(height: 10),
      itemBuilder: (BuildContext context, int index) {
        var currentValue =
            double.parse(selectedAccounts[index].paid.toString());
        String bankName = selectedAccounts[index].account!.name.toString();
        String date = selectedAccounts[index].date.toString();

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
            trailing: Wrap(
              spacing: 12,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => onDataEdit(index),
                ),
                IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () =>
                      onDataRemove(selectedAccounts[index], currentValue),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
