import 'package:bexdeliveries/src/config/size.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:showcaseview/showcaseview.dart';

//models
import '../../../../../domain/models/arguments.dart';

//cubit
import '../../../../cubits/inventory/inventory_cubit.dart';

//utils
import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/constants/strings.dart';

//services
import '../../../../../services/navigation.dart';

class BottomBarInventory extends StatefulWidget {
  const BottomBarInventory({
    super.key,
    required this.myContext,
    required this.arguments,
    required this.totalSummaries,
    required this.four,
  });

  final BuildContext myContext;
  final InventoryArgument arguments;
  final double? totalSummaries;
  final GlobalKey four;

  @override
  BottomBarInventoryState createState() => BottomBarInventoryState();
}

class BottomBarInventoryState extends State<BottomBarInventory> {
  int currentIndex = 0;
  bool isLoading = false;

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  void reload() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final navigationService = context.read<InventoryCubit>().navigationService;

    return BlocSelector<InventoryCubit, InventoryState, bool>(
        selector: (state) {
      return state.status == InventoryStatus.success && state.isArrived == true;
    }, builder: (c, x) {
      return x
          ? _buildBottomBarNavigation(navigationService)
          : SizedBox(
              height: 0,
              width: MediaQuery.of(context).size.width,
            );
    });
  }

  Widget _buildBottomBarNavigation(navigationService) {
    final calculatedFon = getProportionateScreenHeight(14);

    return BlocBuilder<InventoryCubit, InventoryState>(
        builder: (BuildContext context, InventoryState state) {
      print(state);

      if (state.isRejected == true) {
        return SizedBox(
            height: 65,
            child: InkWell(
              onTap: () => navigationService.goTo(AppRoutes.reject,
                  arguments: widget.arguments),
              child: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Column(
                  children: <Widget>[
                    const Icon(Icons.cancel_outlined, color: kPrimaryColor),
                    Text('Rechazado',
                        style: TextStyle(fontSize: calculatedFon)),
                  ],
                ),
              ),
            ));
      } else if (state.isPartial == true) {
        return SizedBox(
          height: hasNavigationBar()
              ? MediaQuery.of(context).size.height * 0.1
              : MediaQuery.of(context).size.height * 0.06,
          child: InkWell(
            onTap: () => navigationService.goTo(AppRoutes.partial,
                arguments: widget.arguments),
            child: Padding(
              padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.01),
              child: const Column(
                children: <Widget>[
                  Icon(Icons.all_inbox_outlined, color: kPrimaryColor),
                  Text(
                    'Parcial',
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
        );
      } else {
        return Showcase(
            key: widget.four,
            disableMovingAnimation: true,
            title: 'Zona transaccional',
            description: 'Aqui puedes elegir entre el tipo de entrega.',
            child: BottomNavigationBar(
                currentIndex: currentIndex,
                onTap: (int index) async {
                  setState(() {
                    currentIndex = index;
                  });

                  widget.arguments.total = widget.totalSummaries;

                  switch (currentIndex) {
                    case 0:
                      navigationService.goTo(AppRoutes.collection,
                          arguments: widget.arguments);
                      break;
                    case 1:
                      navigationService.goTo(AppRoutes.reject,
                          arguments: widget.arguments);
                      break;
                    case 2:
                      navigationService.goTo(AppRoutes.respawn,
                          arguments: widget.arguments);
                      break;
                  }
                },
                items: [
                  BottomNavigationBarItem(
                      label: 'Entrega',
                      icon: Icon(Icons.delivery_dining_outlined,
                          color: Theme.of(context).colorScheme.primary)),
                  if (state.enterpriseConfig != null &&
                      (state.enterpriseConfig!.blockReject == null ||
                          state.enterpriseConfig!.blockReject == false))
                    BottomNavigationBarItem(
                        label: 'Rechazado',
                        icon: Icon(Icons.cancel_outlined,
                            color: Theme.of(context).colorScheme.primary)),
                  BottomNavigationBarItem(
                      label: 'Redespacho',
                      icon: Icon(Icons.receipt_long,
                          color: Theme.of(context).colorScheme.primary))
                ]));
      }
    });
  }

  bool hasNavigationBar() {
    var window = WidgetsBinding.instance.window;
    var padding = window.viewPadding;
    return padding.bottom > 0;
  }
}
