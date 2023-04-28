import 'package:flutter/material.dart';

//domain
import '../../../../../domain/models/summary.dart';
import '../../../../../domain/abstracts/format_abstract.dart';

class ItemProduct extends StatefulWidget {
  const ItemProduct({Key? key, required this.summary}) : super(key: key);

  final Summary summary;

  @override
  ItemProductState createState() => ItemProductState();
}

class ItemProductState extends State<ItemProduct> with FormatNumber {
  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
        child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            child: Container(
                // height: getProportionateScreenHeight(120),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  title: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${widget.summary.coditem} - ${widget.summary.nameItem}',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'U.M. ${double.parse(widget.summary.unitOfMeasurement).toStringAsFixed(2)} - N.M ${widget.summary.nameOfMeasurement}',
                            style: TextStyle(color: Colors.grey[500]),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                    width: 132,
                                    decoration: const BoxDecoration(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(20)),
                                    ),
                                    child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            widget.summary.cant
                                                .toStringAsFixed(0),
                                          )
                                        ])),
                                Text(
                                  'TOTAL: \$${formatter.format(widget.summary.grandTotal)}',
                                  style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold),
                                )
                              ]),
                        ],
                      ),
                    ),
                  ),
                ))));
  }
}
