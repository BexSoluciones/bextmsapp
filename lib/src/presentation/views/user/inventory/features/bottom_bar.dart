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
      required this.four,
      required this.isArrived,
      required this.isPartial,
      required this.isRejected})
      : super(key: key);

  final BuildContext myContext;
  final InventoryArgument arguments;
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

    WillPopScope confirmation(context, setState, r, type) => WillPopScope(
          onWillPop: () async => false,
          child: SafeArea(
            child: SizedBox(
              height: size.height,
              width: size.width,
              child: Center(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Container(
                        height: 250,
                        color: kPrimaryColor,
                        child: Column(
                          children: [
                            const SizedBox(height: 30),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                IconButton(
                                    icon: const Icon(Icons.close,
                                        color: Colors.white),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    })
                              ],
                            ),
                            const SizedBox(height: 30),
                            Text(
                                'Estar seguro de confirmar tu entrega como $type?',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.normal,
                                    color: Colors.white)),
                          ],
                        ),
                      ),
                      // Padding(
                      //     padding:
                      //     const EdgeInsets.symmetric(horizontal: kDefaultPadding),
                      //     child: ReasonsGlobal(
                      //       context: context, r: r, setState: setState,
                      //       type: type,
                      //       typeAheadController: _typeAheadController,
                      //       //context, type, r, setState
                      //     )),
                      // if (Provider.of<DataInventory>(context, listen: true)
                      //     .getShowObservartionIcon)
                      //   Padding(
                      //       padding: EdgeInsets.all(20),
                      //       child: TextField(
                      //         maxLines: 4,
                      //         controller: _observationController,
                      //         decoration: InputDecoration(
                      //           hintText: observationRequired
                      //               ? 'La observación es requerida'
                      //               : '',
                      //           labelText: 'Observación',
                      //           fillColor: Colors.black,
                      //           enabledBorder: OutlineInputBorder(
                      //             borderSide: const BorderSide(
                      //                 color: Colors.black, width: 1.0),
                      //             borderRadius: BorderRadius.circular(25.0),
                      //           ),
                      //           focusedBorder: OutlineInputBorder(
                      //             borderSide: const BorderSide(
                      //                 color: kPrimaryColor, width: 1.0),
                      //             borderRadius: BorderRadius.circular(25.0),
                      //           ),
                      //         ),
                      //       )),
                      // if (Provider.of<DataInventory>(context, listen: true)
                      //     .getShowFirmIcon)
                      //   Padding(
                      //       padding: EdgeInsets.all(20),
                      //       child: DefaultButton(
                      //           widget: firmRequired
                      //               ? Row(
                      //               mainAxisAlignment:
                      //               MainAxisAlignment.spaceEvenly,
                      //               children: [
                      //                 Text('La firma es requerida',
                      //                     textScaleFactor:
                      //                     textScaleFactor(context),
                      //                     style: TextStyle(
                      //                         fontSize:
                      //                         getProportionateScreenHeight(
                      //                             14),
                      //                         color: Colors.white)),
                      //                 Icon(Icons.edit,
                      //                     color: Colors.white)
                      //               ])
                      //               : Icon(Icons.edit, color: Colors.white),
                      //           press: () async {
                      //             await _navigationService.goTo(FirmRoute,
                      //                 arguments: widget.arguments.orderNumber);
                      //           })),
                      // if (Provider.of<DataInventory>(context, listen: true)
                      //     .getShowPhotoIcon)
                      //   Padding(
                      //       padding: EdgeInsets.all(20),
                      //       child: DefaultButton(
                      //           widget: photoRequired
                      //               ? Row(
                      //               mainAxisAlignment:
                      //               MainAxisAlignment.spaceEvenly,
                      //               children: [
                      //                 Text('La foto es requerida',
                      //                     textScaleFactor:
                      //                     textScaleFactor(context),
                      //                     style: TextStyle(
                      //                         fontSize:
                      //                         getProportionateScreenHeight(
                      //                             14),
                      //                         color: Colors.white)),
                      //                 Icon(Icons.camera_alt,
                      //                     color: Colors.white)
                      //               ])
                      //               : Icon(Icons.camera_alt,
                      //               color: Colors.white),
                      //           press: () async {
                      //             await Navigator.of(context).pushNamed(
                      //                 CameraRoute,
                      //                 arguments: widget.arguments.orderNumber);
                      //           })),
                      // if (isErrorReasons)
                      //   FormError(errors: [
                      //     'El motivo de rechazo no puede estar vacio'
                      //   ]),
                      Padding(
                          padding: const EdgeInsets.all(kDefaultPadding),
                          child: isLoading
                              ? const CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      kPrimaryColor),
                                )
                              : DefaultButton(
                                  widget: const Text('Confirmar',
                                      style: TextStyle(
                                        fontSize: 20,
                                      )),
                                  press: () async {
                                    // if (type == 'Rechazado' &&
                                    //     _typeAheadController.text.isEmpty) {
                                    //   setState(() {
                                    //     isErrorReasons = true;
                                    //   });
                                    // } else {
                                    //   await confirmateTransaction(
                                    //     context,
                                    //     type,
                                    //   );
                                    // }
                                  }))
                    ]),
              ),
            ),
          ),
        );

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
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Column(
                      children: const <Widget>[
                        Icon(Icons.cancel_outlined, color: kPrimaryColor),
                        Text('Rechazado',
                            // textScaleFactor: textScaleFactor(context),
                            style: TextStyle(fontSize: 14)),
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
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: const <Widget>[
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
