import 'package:flutter/material.dart';
//utils
import '../../../../../utils/constants/nums.dart';
//domain
import '../../../../../domain/abstracts/format_abstract.dart';

class HeaderCollection extends StatelessWidget with FormatNumber {
  final String type;
  final double total;

  HeaderCollection({super.key, required this.type, required this.total});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      color: Theme.of(context).colorScheme.primary,
      child: SizedBox(
        child: Padding(
          padding: const EdgeInsets.only(
              left: kDefaultPadding, right: kDefaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Text('TOTAL A RECAUDAR: \$${formatter.format(total)}',
                  textAlign: TextAlign.start,
                  style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.secondaryContainer)),
              const SizedBox(height: 3),
              Text(type,
                  textAlign: TextAlign.start,
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.secondaryContainer))
            ],
          ),
        ),
      ),
    );
  }
}
