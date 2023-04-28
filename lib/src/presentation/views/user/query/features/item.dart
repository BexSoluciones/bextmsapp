import 'package:flutter/material.dart';

//domain
import '../../../../../domain/models/work.dart';

class ItemQuery extends StatelessWidget {
  const ItemQuery({Key? key, required this.work }) : super(key: key);

  final Work work;

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Ink(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.7),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: ListTile(
          title: Text(
            'Servicio: ${work.workcode}',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          // subtitle: Row(
          //   children: [
          //     FutureBuilder<WorkTypes?>(
          //         future: database.getWorkTypesFromWorkcode(work.workcode),
          //         builder:
          //             (BuildContext context, AsyncSnapshot snapshot) {
          //           if (snapshot.hasData) {
          //             return Flexible(
          //                 child: Column(
          //                   crossAxisAlignment: CrossAxisAlignment.start,
          //                   children: [
          //                     Text(
          //                       ' Entregas: ${snapshot.data.delivery} Parciales: ${snapshot.data.partial}',
          //                       textScaleFactor: textScaleFactor(context),
          //                       style: TextStyle(
          //                           fontSize: getProportionateScreenHeight(14),
          //                           fontWeight: FontWeight.normal),
          //                     ),
          //                     Text(
          //                       ' Redespachos: ${snapshot.data.respawn} Devoluciones total: ${snapshot.data.rejects}',
          //                       textScaleFactor: textScaleFactor(context),
          //                       style: TextStyle(
          //                           fontSize: getProportionateScreenHeight(14),
          //                           fontWeight: FontWeight.normal),
          //                     ),
          //                   ],
          //                 ));
          //           } else {
          //             return Flexible(
          //                 child: Column(
          //                   crossAxisAlignment: CrossAxisAlignment.start,
          //                   children: [
          //                     Text(
          //                       ' Entregas: 0 Parciales: 0',
          //                       textScaleFactor: textScaleFactor(context),
          //                       style: TextStyle(
          //                           fontSize: getProportionateScreenHeight(14),
          //                           fontWeight: FontWeight.normal),
          //                     ),
          //                     Text(
          //                       ' Redespachos: 0 Devoluciones total: 0',
          //                       textScaleFactor: textScaleFactor(context),
          //                       style: TextStyle(
          //                           fontSize: getProportionateScreenHeight(14),
          //                           fontWeight: FontWeight.normal),
          //                     ),
          //                   ],
          //                 ));
          //           }
          //         })
          //   ],
          // ),
        ),
      ),
    );
  }
}
