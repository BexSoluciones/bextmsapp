import 'package:flutter/material.dart';
import 'package:map_launcher/map_launcher.dart';

//domain
import '../../../../../domain/models/arguments.dart';

//utils
import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/constants/nums.dart';

//widget
import '../../../../widgets/default_button_widget.dart';

class SummaryNavigationView extends StatefulWidget {
  const SummaryNavigationView({Key? key, required this.arguments})
      : super(key: key);

  final SummaryNavigationArgument arguments;

  @override
  State<SummaryNavigationView> createState() => _SummaryNavigationViewState();
}

class _SummaryNavigationViewState extends State<SummaryNavigationView> {
  DirectionsMode directionsMode = DirectionsMode.driving;

  bool isLoading = false;

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void initState() {
    super.initState();
  }

  Widget item(mode) {
    switch (mode) {
      case 0:
        return const TextField(
            enabled: false,
            decoration: InputDecoration(
                label: Text('Conducción',
                    textAlign: TextAlign.center,
                    // textScaleFactor: textScaleFactor(context),
                    style: TextStyle(fontSize: 30)),
                icon: Icon(Icons.directions_car)));
      case 1:
        return const TextField(
            enabled: false,
            decoration: InputDecoration(
                label: Text('Caminando',
                    textAlign: TextAlign.center,
                    // textScaleFactor: textScaleFactor(context),
                    style: TextStyle(fontSize: 30)),
                icon: Icon(Icons.directions_walk)));
      case 2:
        return const TextField(
            enabled: false,
            decoration: InputDecoration(
              label: Text('Tren',
                  // textScaleFactor: textScaleFactor(context),
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 30)),
              icon: Icon(
                Icons.directions_transit,
              ),
            ));
      default:
        return const TextField(
            enabled: false,
            decoration: InputDecoration(
                label: Text(
                  'Bicicleta',
                  textAlign: TextAlign.center,
                  // textScaleFactor: textScaleFactor(context),
                  style: TextStyle(fontSize: 30),
                ),
                icon: Icon(Icons.directions_bike)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Container(
            height: size.height,
            width: size.width,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Padding(
                    padding: const EdgeInsets.symmetric(horizontal: kDefaultPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const FormTitle('Destino', Colors.white),
                        const SizedBox(height: 10),
                        Text(widget.arguments.work.customer!,
                            // textScaleFactor: textScaleFactor(context),
                            style: const TextStyle(fontSize: 20)),
                        Text('Dir: ${widget.arguments.work.address}',
                            // textScaleFactor: textScaleFactor(context),
                            style: const TextStyle(fontSize: 20)),
                        const SizedBox(height: 10),
                        Text('Latitud ${widget.arguments.work.latitude}',
                            // textScaleFactor: textScaleFactor(context),
                            style: const TextStyle(fontSize: 20)),
                        Text('Longitud ${widget.arguments.work.longitude}',
                            // textScaleFactor: textScaleFactor(context),
                            style: const TextStyle(fontSize: 20))
                      ],
                    )),
                const SizedBox(height: 60),
                Expanded(
                  flex: 3,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        const FormTitle('Modo de Dirección', Colors.black),
                        const SizedBox(height: 10),
                        Container(
                          alignment: Alignment.centerLeft,
                          child: DecoratedBox(
                              decoration: BoxDecoration(
                                color:
                                    kPrimaryColor, //background color of dropdown buttonborder of dropdown button
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 30, right: 30),
                                  child: DropdownButton(
                                    value: directionsMode,
                                    items: DirectionsMode.values
                                        .map((directionsMode) {
                                      return DropdownMenuItem(
                                        value: directionsMode,
                                        child: item(directionsMode.index),
                                      );
                                    }).toList(),
                                    onChanged: (newValue) {
                                      setState(() {
                                        directionsMode =
                                            newValue as DirectionsMode;
                                      });
                                    },
                                    icon: const Padding(
                                        //Icon at tail, arrow bottom is default icon
                                        padding: EdgeInsets.only(left: 20),
                                        child: Icon(
                                            Icons.arrow_circle_down_sharp)),
                                    iconEnabledColor: Colors.white, //Icon color
                                    style: const TextStyle(
                                        //Font color
                                        fontSize:
                                            20 //font size on dropdown button
                                        ),
                                    dropdownColor:
                                        kPrimaryColor, //dropdown background color
                                    underline: Container(), //remove underline
                                    isExpanded:
                                        true, //make true to make width 100%
                                  ))),
                        ),
                        SizedBox(height: size.height / 2.9),
                        DefaultButton(
                            widget: const Text('Mostrar Mapas',
                                // textScaleFactor: textScaleFactor(context),
                                style: TextStyle(fontSize: 20)),
                            press: () {
                              // MapsSheet.show(
                              //   context: context,
                              //   onMapTap: (map) {
                              //     map.showDirections(
                              //       destination: Coords(
                              //         double.parse(
                              //             widget.arguments.work.latitude!),
                              //         double.parse(
                              //             widget.arguments.work.longitude!),
                              //       ),
                              //       destinationTitle:
                              //       widget.arguments.work.customer,
                              //       origin: Coords(_locationData.latitude!,
                              //           _locationData.longitude!),
                              //       originTitle: 'Origen',
                              //       directionsMode: directionsMode,
                              //     );
                              //   },
                              // );
                            })
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class FormTitle extends StatelessWidget {
  const FormTitle(this.title, this.color, {super.key, this.trailing});

  final String title;
  final Color color;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Row(
          children: [
            Text(
              title,
              // textScaleFactor: textScaleFactor(context),
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
            const Spacer(),
            if (trailing != null) trailing!,
          ],
        ),
      ],
    );
  }
}
