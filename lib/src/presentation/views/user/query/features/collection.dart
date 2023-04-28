import 'package:flutter/material.dart';

//domain
import '../../../../../domain/abstracts/format_abstract.dart';

//widgets
import 'item_collection.dart';
import 'package:lottie/lottie.dart';

class CollectionQueryView extends StatefulWidget {
  const CollectionQueryView({Key? key, required this.workcode})
      : super(key: key);

  final String workcode;

  @override
  State<CollectionQueryView> createState() => _CollectionQueryViewState();
}

class _CollectionQueryViewState extends State<CollectionQueryView> with FormatNumber {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            'Recaudos ${widget.workcode}',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(
              top: 20.0,
              left: 16.0,
              right: 16.0,
              bottom: 20.0,
            ),
            child: Container(),
            // child: FutureBuilder(
            //   future: database.getClientsCollection(widget.workcode),
            //   builder: (BuildContext context, AsyncSnapshot snapshot) {
            //     print(snapshot.hasData);
            //     if (snapshot.hasData) {
            //       if (snapshot.data.length > 0) {
            //         return Column(
            //           children: [
            //             Expanded(
            //                 flex: 11,
            //                 child: ListView.separated(
            //                   itemCount: snapshot.data.length,
            //                   separatorBuilder: (context, index) =>
            //                       SizedBox(height: 16.0),
            //                   itemBuilder: (context, index) {
            //                     return ItemCollection(data: snapshot.data[index]);
            //                   },
            //                 )),
            //             Spacer(),
            //             StreamBuilder<double>(
            //               stream: database.countTotalCollectionWorksByWorkcode(
            //                   widget.workcode),
            //               builder:
            //                   (BuildContext context, AsyncSnapshot snapshot) {
            //                 if (snapshot.connectionState ==
            //                     ConnectionState.waiting) {
            //                   return LinearProgressIndicator(
            //                     valueColor: AlwaysStoppedAnimation<Color>(
            //                         kPrimaryColor),
            //                   );
            //                 } else {
            //                   return Container(
            //                     width: double.infinity,
            //                     decoration: BoxDecoration(
            //                         borderRadius: BorderRadius.circular(20),
            //                         color: kPrimaryColor),
            //                     height: 60,
            //                     child: Center(
            //                       child: Text(
            //                           'Total recaudado: ${formatter.format(snapshot.data)}',
            //                           textScaleFactor: textScaleFactor(context),
            //                           style: TextStyle(
            //                               color: Colors.white, fontSize: getProportionateScreenHeight(18))),
            //                     ),
            //                   );
            //                 }
            //               },
            //             ),
            //           ],
            //         );
            //       } else {
            //         return Center(
            //           child: Column(
            //             mainAxisSize: MainAxisSize.min,
            //             children: [
            //               Lottie.asset('lib/assets/animations/36499-page-not-found.json',
            //                   height: 250, width: 250),
            //               Text('Sin recaudos.', textScaleFactor: textScaleFactor(context), style: TextStyle(fontSize: getProportionateScreenHeight(20)))
            //             ],
            //           ),
            //         );
            //       }
            //     } else {
            //       return Center(
            //         child: CircularProgressIndicator(
            //           valueColor: AlwaysStoppedAnimation<Color>(kPrimaryColor),
            //         ),
            //       );
            //     }
            //   },
            // ),
          ),
        ));
  }
}
