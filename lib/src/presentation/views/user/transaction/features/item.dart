import 'package:flutter/material.dart';

//domain
import '../../../../../domain/models/work.dart';

class ItemQuery extends StatelessWidget {
  const ItemQuery({Key? key, required this.work}) : super(key: key);

  final Work work;

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Ink(
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: ListTile(
          title: Text(
            'Servicio: ${work.workcode}',
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500),
          ),
        ),
      ),
    );
  }
}
