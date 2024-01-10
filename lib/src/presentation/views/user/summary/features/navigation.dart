import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:map_launcher/map_launcher.dart';

//cubit
import '../../../../cubits/summary/summary_cubit.dart';

//domain
import '../../../../../domain/models/arguments.dart';

//utils
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
                label: Text('Conducción', textAlign: TextAlign.center),
                icon: Icon(Icons.directions_car)));
      case 1:
        return const TextField(
            enabled: false,
            decoration: InputDecoration(
                label: Text('Caminando', textAlign: TextAlign.center),
                icon: Icon(Icons.directions_walk)));
      case 2:
        return const TextField(
            enabled: false,
            decoration: InputDecoration(
              label: Text('Tren', textAlign: TextAlign.center),
              icon: Icon(
                Icons.directions_transit,
              ),
            ));
      default:
        return const TextField(
            enabled: false,
            decoration: InputDecoration(
                label: Text('Bicicleta', textAlign: TextAlign.center),
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
          child: SizedBox(
            height: size.height,
            width: size.width,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: kDefaultPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const FormTitle('Destino', Colors.black),
                        const SizedBox(height: 10),
                        Text(widget.arguments.work.customer!),
                        Text('Dirección: ${widget.arguments.work.address}'),
                        const SizedBox(height: 10),
                        Text('Latitud ${widget.arguments.work.latitude}'),
                        Text('Longitud ${widget.arguments.work.longitude}')
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
                                    underline: Container(), //remove underline
                                    isExpanded:
                                        true, //make true to make width 100%
                                  ))),
                        ),
                        SizedBox(height: size.height / 3.0),
                        BlocBuilder<SummaryCubit, SummaryState>(
                            builder: (context, state) {
                          if (state.runtimeType == SummaryLoadingMap) {
                            return const Center(
                                child: CupertinoActivityIndicator());
                          } else {
                            return DefaultButton(
                                widget: const Text('Mostrar Mapas',
                                    style: TextStyle(color: Colors.white)),
                                press: () => context
                                    .read<SummaryCubit>()
                                    .showMaps(context, widget.arguments,
                                        directionsMode));
                          }
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
              style: TextStyle(
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
