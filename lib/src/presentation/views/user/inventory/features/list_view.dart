import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:showcaseview/showcaseview.dart';

//cubit
import '../../../../cubits/inventory/inventory_cubit.dart';

//models
import '../../../../../domain/models/arguments.dart';

//features
import 'item_inventory.dart';

class ListViewInventory extends StatefulWidget {
  const ListViewInventory(
      {super.key,
        required this.arguments,
        required this.three,
        required this.isArrived});

  final InventoryArgument arguments;
  final GlobalKey three;
  final bool isArrived;

  @override
  ListViewInventoryState createState() => ListViewInventoryState();
}

class ListViewInventoryState extends State<ListViewInventory> {

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {

    final size = MediaQuery.of(context).size;

    return BlocBuilder<InventoryCubit, InventoryState>(builder: (context, state) {
      switch (state.status) {
        case InventoryStatus.loading:
          return const SliverToBoxAdapter(child: Center(child:CupertinoActivityIndicator()));
        case InventoryStatus.success:
          return _buildInventory(state, size);
        default:
          return const SliverToBoxAdapter();
      }
    });

  }

  Widget _buildInventory(state, Size size) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
            (BuildContext context, int index) {
          if (index == 0) {
            return Showcase(
                key: widget.three,
                disableMovingAnimation: true,
                description:
                'Estos son los productos que debes entregar recuerda que puedes modificar sus cantidades!',
                child: ItemInventory(
                  enterpriseConfig: state.enterpriseConfig,
                  summaries: state.summaries,
                  summary: state.summaries[index],
                  isArrived: widget.isArrived,
                  arguments: widget.arguments,
                ));
          } else {
            return ItemInventory(
              enterpriseConfig: state.enterpriseConfig,
              summaries: state.summaries,
              summary: state.summaries[index],
              isArrived: widget.isArrived,
              arguments: widget.arguments,
            );
          }
        },
        childCount: state.summaries.length,
      ),
    );
  }
}
