import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

//cubit
import '../../cubits/politics/politics_cubit.dart';

//utils
import '../../../utils/constants/colors.dart';
import '../../../utils/constants/nums.dart';
import '../../../utils/constants/gaps.dart';

// animation
import 'package:lottie/lottie.dart';

//services
import '../../../locator.dart';
import '../../../services/navigation.dart';

//widgets
import '../../widgets/default_button_widget.dart';

final NavigationService _navigationService = locator<NavigationService>();

class PoliticsView extends StatefulWidget {
  const PoliticsView({super.key});

  @override
  PoliticsViewState createState() => PoliticsViewState();
}

class PoliticsViewState extends State<PoliticsView> {
  bool isLoading = false;
  late PoliticsCubit politicsCubit;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: BlocConsumer<PoliticsCubit, PoliticsState>(
        listener: (context, state) {
          if (state is PoliticsSuccess) {
            _navigationService.goTo(state.route!);
          }
        },
        builder: (context, state) => SingleChildScrollView(
          child: SafeArea(
            child: SizedBox(
                height: size.height,
                width: size.width,
                child: Padding(
                  padding: const EdgeInsets.all(kDefaultPadding),
                  child: ListView(children: [
                    gapH12,
                    Lottie.asset('assets/animations/47956-area-map.json',
                        height: 300, width: 300),
                    gapH12,
                    const Text(
                        'Tu ubicación actual se mostrará en el mapa y se usará para rutas, búsquedas de sitios y estimaciones del tiempo de entrega de tus pedidos.',
                        textAlign: TextAlign.justify,
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w300)),
                    gapH12,
                    const Text(
                        'Bex deliveries recopila datos de tu ubicación para habilitar el seguimiento continuo de los transportadores en la entrega de clientes y mejorar los tiempo de entrega incluso cuando la aplicación esta cerrada o no esta en uso.',
                        textAlign: TextAlign.justify,
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w300)),
                    gapH20,
                    InkWell(
                        onTap: () => _launchUrl(Uri.parse(
                            'https://bexdeliveries.com/politicas-de-datos-terminos-y-condiciones')),
                        child: const Text(
                            'Para ver nuestras politicas de privacidad haz click aquí',
                            textAlign: TextAlign.justify,
                            style: TextStyle(
                                color: kPrimaryColor,
                                fontSize: 15,
                                fontWeight: FontWeight.w300))),
                    gapH64,
                    DefaultButton(
                      widget: isLoading
                          ? const CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            )
                          : const Text('Aceptar y continuar',
                              softWrap: false,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16.0,
                              )),
                      press: () => _dispatchEvent(context),
                    )
                  ]),
                )),
          ),
        ),
      ),
    );
  }

  Future<void> _launchUrl(url) async {
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }

  void _dispatchEvent(BuildContext context) {
    BlocProvider.of<PoliticsCubit>(context).goTo();
  }
}
