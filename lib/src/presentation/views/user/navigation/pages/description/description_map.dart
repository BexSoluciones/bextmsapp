import 'package:flutter/material.dart';

//domain
import '../../../../../../domain/models/summary_report.dart';

class ItemDescription extends StatefulWidget {
  const ItemDescription({
    super.key,
    required this.summary,
    required this.onTap,
    required this.workcode,
    required this.workId,
    required this.orderNumber,
  });

  final SummaryReport summary;
  final VoidCallback? onTap;
  final String workcode;
  final String orderNumber;
  final int workId;

  @override
  State<ItemDescription> createState() => _ItemDescriptionState();
}

class _ItemDescriptionState extends State<ItemDescription> {
  @override
  Widget build(BuildContext context) {
    final difference =
        double.parse(widget.summary.amount) - widget.summary.cant;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 5),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          elevation: 8,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0),
              boxShadow: const [
                BoxShadow(
                  color: Colors.white,
                  spreadRadius: 2,
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: DataTable(
                columnSpacing: 20.0,
                dataRowMinHeight: 60.0,
                headingRowHeight: 30.0,
                columns: const [
                  DataColumn(
                    label: Text(
                      'Codigo',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Nombre',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Empaque',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Bodega/Lote',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Precio Unit',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Total',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Cant. Original',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Cant. Devuelta',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Motivo',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
                rows: [
                  DataRow(
                    color: MaterialStateProperty.resolveWith<Color?>(
                      (Set<MaterialState> states) {
                        if (states.contains(MaterialState.selected)) {
                          return Colors.green;
                        }
                        if (difference >= 1) {
                          return Colors.green;
                        } else {
                          return Colors.green;
                        }
                      },
                    ),
                    cells: [
                      DataCell(Text(widget.summary.coditem)),
                      DataCell(Text(widget.summary.nameItem)),
                      DataCell(Text(widget.summary.nameOfMeasurement!)),
                      DataCell(Text(widget.summary.codeWarehouse!)),
                      DataCell(Text('${widget.summary.price}')),
                      DataCell(Text('${widget.summary.grandTotalCopy}')),
                      DataCell(Text(widget.summary.amount)),
                      DataCell(Text('$difference')),
                      DataCell(Text('${widget.summary.reason}')),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
