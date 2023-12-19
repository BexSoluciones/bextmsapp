import 'package:flutter/material.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:lottie/lottie.dart';

//domain
import '../../../../../domain/models/summary.dart';
import '../../../../../domain/models/arguments.dart';

//feature
import 'item.dart';

class ListViewPackage extends StatefulWidget {
  const ListViewPackage({Key? key, required this.arguments, required this.two})
      : super(key: key);

  final PackageArgument arguments;
  final GlobalKey two;

  @override
  ListViewPackageState createState() => ListViewPackageState();
}

class ListViewPackageState extends State<ListViewPackage> {
  List<Summary> summaries = [];

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container();
    // return StreamBuilder<List<Summary>>(
    //     stream: database.watchAllInventoryConsultaItem(
    //         widget.arguments.packing!,
    //         widget.arguments.idPacking!,
    //         widget.arguments.orderNumber),
    //     builder: (BuildContext context, AsyncSnapshot snapshot) {
    //       if (snapshot.hasData == false) {
    //         return SliverToBoxAdapter(
    //             child: Center(
    //                 child: Lottie.asset(
    //                   'lib/assets/animations/36499-page-not-found.json',
    //                 )));
    //       } else {
    //         summaries = snapshot.data;
    //         return SliverList(
    //           delegate: SliverChildBuilderDelegate(
    //                 (BuildContext context, int index) {
    //               if (index == 0) {
    //                 return Showcase(
    //                     key: widget.two,
    //                     disableMovingAnimation: true,
    //                     description:
    //                     'Estos son los productos que contiene esta caja!',
    //                     child: ItemProduct(summary: summaries[index]));
    //               } else {
    //                 return ItemProduct(summary: summaries[index]);
    //               }
    //             },
    //             childCount: summaries.length,
    //           ),
    //         );
    //       }
    //     });
  }
}
