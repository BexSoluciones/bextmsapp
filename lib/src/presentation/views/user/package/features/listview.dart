import 'package:flutter/material.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:lottie/lottie.dart';

//domain
import '../../../../../domain/models/summary.dart';
import '../../../../../domain/models/arguments.dart';
import '../../../../../domain/repositories/database_repository.dart';

//feature
import 'item.dart';

//services
import '../../../../../locator.dart';

final DatabaseRepository databaseRepository = locator<DatabaseRepository>();

class ListViewPackage extends StatefulWidget {
  const ListViewPackage({Key? key, required this.arguments, required this.two})
      : super(key: key);

  final PackageArgument arguments;
  final GlobalKey two;

  @override
  ListViewPackageState createState() => ListViewPackageState();
}

class ListViewPackageState extends State<ListViewPackage> {
  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Summary>>(
        future: databaseRepository.watchAllItemsPackage(
            widget.arguments.summary.orderNumber,
            widget.arguments.summary.packing!,
            widget.arguments.summary.idPacking!),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData == false) {
            return SliverToBoxAdapter(
                child: Center(
                    child: Lottie.asset(
              'assets/animations/36499-page-not-found.json',
            )));
          } else {

            print(snapshot.data.length);

            return SliverList(
              delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
                  if (index == 0) {
                    return Showcase(
                        key: widget.two,
                        disableMovingAnimation: true,
                        description:
                            'Estos son los productos que contiene esta caja!',
                        child: ItemProduct(summary: snapshot.data[index]));
                  } else {
                    return ItemProduct(summary: snapshot.data[index]);
                  }
                },
                childCount: snapshot.data.length,
              ),
            );
          }
        });
  }
}
