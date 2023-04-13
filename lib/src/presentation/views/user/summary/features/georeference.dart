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

class SummaryGeoreferenceView extends StatefulWidget {
  const SummaryGeoreferenceView({Key? key, required this.work})
      : super(key: key);

  final Work work;

  @override
  State<SummaryGeoreferenceView> createState() =>
      SummaryGeoreferenceViewState();
}

class SummaryGeoreferenceViewState extends State<SummaryGeoreferenceView> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new),
            onPressed: () => _navigationService.goBack(),
          ),
        ),
        body: BlocBuilder<GeoreferenceCubit, GeoreferenceState>(
            builder: (context, state) {
          switch (state.runtimeType) {
            case GeoreferenceLoading:
              return const Center(child: CupertinoActivityIndicator());
            case GeoreferenceSuccess:
              return _buildGeoreference(context, state, widget, size);
            default:
              return const SizedBox();
          }
        }));
  }
}

Widget _buildGeoreference(context, state, widget, Size size) {
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
                // textScaleFactor: textScaleFactor(context),
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600)),
            const SizedBox(height: 20),
            const Text(
                'Cuando georeferencies a un cliente asegurate de estar lo más cercano posible a él.',
                // textScaleFactor: textScaleFactor(context),
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400)),
            const Spacer(),
            DefaultButton(
                widget: Text(
                    widget.work.latitude != null &&
                            widget.work.longitude != null
                        ? 'Actualizar'
                        : 'Guardar',
                    style: const TextStyle(fontSize: 20)),
                press: () async {
                  var client = Client(
                      nit: widget.nit,
                      operativeCenter: widget.codePlace,
                      latitude: null,
                      longitude: null,
                      action: widget.work.latitude != null &&
                              widget.work.longitude != null
                          ? 'update'
                          : 'save',
                      userId: null);

                  BlocProvider.of<GeoreferenceCubit>(context).sendTransactionClient(client);
                }),
            const SizedBox(height: 30),
            DefaultButton(
                color: Colors.grey,
                widget: const Text('Cancelar',
                    // textScaleFactor: textScaleFactor(context),
                    style: TextStyle(fontSize: 20)),
                press: () => _navigationService.goBack())
          ],
        ),
      ),
    ),
  );
}
