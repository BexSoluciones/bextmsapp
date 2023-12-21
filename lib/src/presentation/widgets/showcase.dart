import 'package:bexdeliveries/src/domain/models/arguments.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:url_launcher/url_launcher.dart';

//utils
import '../../utils/constants/strings.dart';

//core
import '../../../core/helpers/index.dart';

//blocs
import '../blocs/issues/issues_bloc.dart';

//domain
import '../../domain/models/work.dart';

//services
import '../../locator.dart';
import '../../services/navigation.dart';

final helperFunctions = HelperFunctions();
final NavigationService _navigationService = locator<NavigationService>();

class BuildShowcaseIconButton extends StatefulWidget {
  const BuildShowcaseIconButton(
      {Key? key,
      required this.keys,
      this.description,
      required this.iconData,
      this.onPressed})
      : super(key: key);
  final GlobalKey keys;
  final String? description;
  final IconData iconData;
  final VoidCallback? onPressed;

  @override
  State<BuildShowcaseIconButton> createState() =>
      _BuildShowcaseIconButtonState();
}

late IssuesBloc issuesBloc;

class _BuildShowcaseIconButtonState extends State<BuildShowcaseIconButton> {
  @override
  void initState() {
    super.initState();
    issuesBloc = BlocProvider.of<IssuesBloc>(context);
  }

  @override
  Widget build(BuildContext context) {
    return Showcase(
      key: widget.keys,
      disableMovingAnimation: true,
      description: widget.description,
      child: IconButton(
        onPressed: widget.onPressed,
        icon: Icon(widget.iconData, size: 35,color: Theme.of(context).colorScheme.shadow),
      ),
    );
  }
}

// Crear el Showcase para llamar al teléfono del cliente
Widget buildPhoneShowcase(Work work, GlobalKey one) {
  return BuildShowcaseIconButton(
    keys: one,
    description: 'Llama al teléfono del cliente!',
    iconData: Icons.phone,
    onPressed: () {
      if (work.cellphone != null && work.cellphone != '0') {
        launchUrl(Uri.parse('tel://${work.cellphone}'));
      }
    },
  );
}

Widget buildMapShowcase(BuildContext context, Work work, GlobalKey three) {
  return Showcase(
    key: three,
    disableMovingAnimation: true,
    description:
        '¿Te perdiste? ¡Usa esta opción para ver al cliente en Google Maps!',
    child: IconButton(
      onPressed: () async {
        if (work.latitude != '0' && work.longitude != '0') {
          _navigationService.goTo(AppRoutes.summaryNavigation, arguments: SummaryNavigationArgument(work: work));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'No tiene geolocalización 🚨',
                style: TextStyle(fontSize: 16),
              ),
            ),
          );
        }
      },
      icon:  Icon(Icons.directions, size: 35,color: Theme.of(context).colorScheme.shadow),
    ),
  );
}

// Crear el Showcase para enviar un mensaje de WhatsApp al cliente
Widget buildWhatsAppShowcase(Work work, GlobalKey two) {
  return BuildShowcaseIconButton(
    keys: two,
    description: 'Deja un mensaje de WhatsApp!',
    iconData: FontAwesomeIcons.whatsapp,
    onPressed: () async {
      if (work.cellphone != null && work.cellphone != '0') {
        await helperFunctions.launchWhatsApp(
          '+57${work.cellphone}',
          'Hola!, ¿Cómo estás?',
        );
      }
    },
  );
}

// Crear el Showcase para la opción "Publicar"
Widget buildPublishShowcase(GlobalKey four, int summaryId) {
  return BuildShowcaseIconButton(
    keys: four,
    description: 'Reportar un problema',
    iconData: Icons.warning_rounded,
    onPressed: () {
      issuesBloc.add(GetIssuesList(
          currentStatus: 'summary', workId: null, summaryId: summaryId));
      _navigationService.goTo(AppRoutes.issue);
    },
  );
}
