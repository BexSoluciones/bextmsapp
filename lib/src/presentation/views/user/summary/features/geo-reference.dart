import 'package:bexdeliveries/src/domain/models/arguments.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';

//cubit
import '../../../../cubits/georeference/georeference_cubit.dart';

//domain
import '../../../../../domain/models/work.dart';
import '../../../../../domain/models/client.dart';

//utils
import '../../../../../utils/constants/nums.dart';

//services
import '../../../../../locator.dart';
import '../../../../../services/navigation.dart';

//widgets

import '../../../../widgets/default_button_widget.dart';

final NavigationService _navigationService = locator<NavigationService>();

class SummaryGeoReferenceView extends StatefulWidget {
  const SummaryGeoReferenceView({Key? key, required this.argument})
      : super(key: key);

  final SummaryArgument argument;

  @override
  State<SummaryGeoReferenceView> createState() =>
      SummaryGeoReferenceViewState();
}

class SummaryGeoReferenceViewState extends State<SummaryGeoReferenceView> {
  late GeoReferenceCubit geoReferenceCubit;

  @override
  void initState() {
    geoReferenceCubit = BlocProvider.of<GeoReferenceCubit>(context);
    geoReferenceCubit.init();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new),
            onPressed: () {
              _navigationService.goBack();
              setState(() {});
            },
          ),
        ),
        body: BlocBuilder<GeoReferenceCubit, GeoReferenceState>(
            builder: (context, state) {
          switch (state.runtimeType) {
            case GeoReferenceLoading:
              return const Center(child: CupertinoActivityIndicator());
            case GeoReferenceSuccess:
              return _buildGeoReference(context, state, size, widget.argument);
            default:
              return const SizedBox();
          }
        }));
  }
}

Widget _buildGeoReference(context, state, size, SummaryArgument argument) {
  return Center(
    child: Padding(
      padding: const EdgeInsets.all(kDefaultPadding),
      child: Container(
        width: size.width,
        height: size.height,
        padding: const EdgeInsets.all(kDefaultPadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Lottie.asset('assets/animations/18199-location-pin-on-a-map.json'),
            const Text('¿Deseas georeferenciar este cliente?',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600)),
            const SizedBox(height: 20),
            const Text(
                'Cuando georeferencies a un cliente asegurate de estar lo más cercano posible a él.',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400)),
            const Spacer(),
            DefaultButton(
                widget: Text(
                    argument.work.latitude != null && argument.work.longitude != null
                        ? 'Actualizar'
                        : 'Guardar',
                    style: const TextStyle(fontSize: 20, color: Colors.white)),
                press: () async {
                  var client = Client(
                      id: argument.work.id,
                      nit: argument.work.numberCustomer,
                      operativeCenter: argument.work.codePlace,
                      action: argument.work.latitude != null && argument.work.longitude != null
                          ? 'update'
                          : 'save',
                      userId: null);

                  BlocProvider.of<GeoReferenceCubit>(context)
                      .sendTransactionClient(argument, client);
                }),
            const SizedBox(height: 30),
            DefaultButton(
                color: Colors.grey,
                widget: const Text('Cancelar',
                    // textScaleFactor: textScaleFactor(context),
                    style: TextStyle(fontSize: 20, color: Colors.white)),
                press: () => _navigationService.goBack())
          ],
        ),
      ),
    ),
  );
}
