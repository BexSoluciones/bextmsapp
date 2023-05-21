import 'package:flutter/material.dart';
import 'package:showcaseview/showcaseview.dart';

//models
import '../../../../../domain/models/arguments.dart';

//utils
import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/constants/strings.dart';

//services
import '../../../../../locator.dart';
import '../../../../../services/navigation.dart';
import '../../../../../services/storage.dart';
import '../../../../../utils/constants/nums.dart';
import '../../../../widgets/default_button_widget.dart';

final NavigationService _navigationService = locator<NavigationService>();
final LocalStorageService _storageService = locator<LocalStorageService>();

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
    final size = MediaQuery.of(context).size;

    return widget.isArrived == false
        ? SizedBox(
            height: 0,
            width: MediaQuery.of(context).size.width,
          )
        : (widget.isRejected
            ? SizedBox(
                height: 65,
                child: InkWell(
                  onTap: () => _navigationService.goTo(rejectRoute,
                      arguments: widget.arguments),
                  child: const Padding(
                    padding: EdgeInsets.only(top: 8.0),
                    child: Column(
                      children: <Widget>[
                        Icon(Icons.cancel_outlined, color: kPrimaryColor),
                        Text('Rechazado', style: TextStyle(fontSize: 14)),
                      ],
                    ),
                  ),
                ))
            : widget.isPartial
                ? SizedBox(
                    height: 65,
                    child: InkWell(
                      onTap: () => _navigationService.goTo(partialRoute,
                          arguments: widget.arguments),
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Column(
                          children: <Widget>[
                            Icon(Icons.all_inbox_outlined,
                                color: kPrimaryColor),
                            Text('Parcial', style: TextStyle(fontSize: 14)),
                          ],
                        ),
                      ),
                    ))
                : Showcase(
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
                              _navigationService.goTo(collectionRoute,
                                  arguments: widget.arguments);
                              break;
                            case 1:
                              _navigationService.goTo(rejectRoute,
                                  arguments: widget.arguments);
                              break;
                            case 2:
                              _navigationService.goTo(respawnRoute,
                                  arguments: widget.arguments);
                              break;
                          }
                        },
                        items: const [
                          BottomNavigationBarItem(
                              label: 'Entrega',
                              icon: Icon(Icons.delivery_dining_outlined)),
                          BottomNavigationBarItem(
                              label: 'Rechazado',
                              icon: Icon(Icons.cancel_outlined)),
                          BottomNavigationBarItem(
                              label: 'Redespacho',
                              icon: Icon(Icons.receipt_long))
                        ])));
  }
}
