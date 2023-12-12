import 'package:flutter/material.dart';

class TransactionList extends StatelessWidget {
   final List<dynamic> selectedAccounts;
  final Function(double) onTotalChange;
  final Function(List<dynamic>) onDataRemove;

  const TransactionList({super.key,
    required this.selectedAccounts,
    required this.onTotalChange,
    required this.onDataRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List<Widget>.generate(selectedAccounts.length, (index) {
        var currentValue = double.parse(selectedAccounts[index][0].toString());
        String bankName = selectedAccounts[index][2].toString().replaceAll(RegExp(r'[0-9()-]'), '');

        return Row(
          children: [
            const Text('Monto: '),
            Text(currentValue.toString()),
            const SizedBox(width: 20.0),
            const Text('Banco:'),
            Text(bankName),
            IconButton(
              onPressed: () {
                onTotalChange(-currentValue);
                onDataRemove(selectedAccounts[index]);
              },
              icon: const Icon(Icons.clear),
            ),
          ],
        );
      }),
    );
  }
}
