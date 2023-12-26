import 'package:bexdeliveries/src/config/size.dart';
import 'package:bexdeliveries/src/presentation/cubits/inventory/inventory_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:showcaseview/showcaseview.dart';

//models
import '../../../../../domain/models/arguments.dart';

//utils
import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/constants/strings.dart';

//services
import '../../../../../locator.dart';
import '../../../../../services/navigation.dart';

final NavigationService _navigationService = locator<NavigationService>();

class BottomBarInventory extends StatefulWidget {
  const BottomBarInventory(
      {Key? key,
      required this.myContext,
      required this.arguments,
      required this.totalSummaries,
      required this.four,
      required this.isArrived,
      required this.isPartial,
      required this.isRejected})
      : super(key: key);

  final BuildContext myContext;
  final InventoryArgument arguments;
  final double? totalSummaries;
  final GlobalKey four;
  final bool isArrived;
  final bool isPartial;
  final bool isRejected;

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
    return BlocSelector<InventoryCubit, InventoryState, bool>(
        selector: (state) {
      return state is InventorySuccess && state.isArrived == true;
    }, builder: (c, x) {
      return x
          ? _buildBottomBarNavigation()
          : SizedBox(
              height: 0,
              width: MediaQuery.of(context).size.width,
            );
    });
  }

  Widget _buildBottomBarNavigation() {
    final calculatedTextScaleFactor = textScaleFactor(context);
    final calculatedFon = getProportionateScreenHeight(14);

    return BlocBuilder<InventoryCubit, InventoryState>(
        builder: (BuildContext context, InventoryState state) {
      if (widget.isRejected) {
        return SizedBox(
            height: 65,
            child: InkWell(
              onTap: () => _navigationService.goTo(AppRoutes.reject,
                  arguments: widget.arguments),
              child: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Column(
                  children: <Widget>[
                    const Icon(Icons.cancel_outlined, color: kPrimaryColor),
                    Text('Rechazado',
                        textScaleFactor: calculatedTextScaleFactor,
                        style: TextStyle(fontSize: calculatedFon)),
                  ],
                ),
              ),
            ));
      } else if (widget.isPartial) {
        return SizedBox(
          height: hasNavigationBar()
              ? MediaQuery.of(context).size.height * 0.1
              : MediaQuery.of(context).size.height * 0.06,
          child: InkWell(
            onTap: () => _navigationService.goTo(AppRoutes.partial,
                arguments: widget.arguments),
            child: Padding(
              padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.01),
              child: Column(
                children: <Widget>[
                  const Icon(Icons.all_inbox_outlined, color: kPrimaryColor),
                  Text(
                    'Parcial',
                    textScaleFactor: calculatedTextScaleFactor,
                    style: const TextStyle(fontSize: 14),
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
                      _navigationService.goTo(AppRoutes.collection,
                          arguments: widget.arguments);
                      break;
                    case 1:
                      _navigationService.goTo(AppRoutes.reject,
                          arguments: widget.arguments);
                      break;
                    case 2:
                      _navigationService.goTo(AppRoutes.respawn,
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
