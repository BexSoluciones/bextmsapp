import 'package:flutter/material.dart';

//domain
import '../../domain/models/different.dart';

class DifferentItem extends StatelessWidget {
  const DifferentItem(
      {super.key, required this.differentItem, required this.index});

  final Different differentItem;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Material(
        borderRadius: BorderRadius.circular(8.0),
        color: Colors.blue.withOpacity(0.1),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.blue,
                    child: Text('${index + 1}'),
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          differentItem.customer,
                          style: const TextStyle(fontSize: 16),
                          //   style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '${differentItem.address}',
                          style: const TextStyle(fontSize: 13),
                        ),
                        //Text('orden: ${differentItem.order}')
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
