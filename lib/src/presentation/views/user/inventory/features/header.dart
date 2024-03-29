import 'package:bexdeliveries/src/config/size.dart';
import 'package:flutter/material.dart';
import 'package:showcaseview/showcaseview.dart';

//domain
import '../../../../../domain/models/arguments.dart';
import '../../../../../domain/abstracts/format_abstract.dart';

class HeaderInventory extends StatelessWidget with FormatNumber {
  HeaderInventory(
      {super.key,
      required this.arguments,
      required this.totalSummaries,
      required this.two});

  final InventoryArgument arguments;
  final double? totalSummaries;
  final GlobalKey two;

  @override
  Widget build(BuildContext context) {
    final calculatedFon = getProportionateScreenHeight(16);
    return SliverPersistentHeader(
        pinned: true,
        delegate: _SliverAppBarDelegate(
          child: PreferredSize(
              preferredSize: const Size.fromHeight(50.0),
              child: Container(
                color: Theme.of(context).colorScheme.background,
                child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 12.0, horizontal: 8.0),
                    child: Showcase(
                      key: two,
                      disableMovingAnimation: true,
                      description: 'Este es el total que debes recaudar 😁',
                      child: Center(
                        child: Text(
                            'TOTAL A RECAUDAR: \$${formatter.format(totalSummaries ?? 0.0)}',
                            textAlign: TextAlign.start,
                            style: TextStyle(
                                fontSize: calculatedFon,
                                fontWeight: FontWeight.bold)),
                      ),
                    )),
              )),
        ));
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate({required this.child});

  final PreferredSize child;

  @override
  double get minExtent => child.preferredSize.height;
  @override
  double get maxExtent => child.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  bool get maintainState => false;

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return true;
  }
}
