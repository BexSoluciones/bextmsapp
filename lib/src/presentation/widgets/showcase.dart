import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:url_launcher/url_launcher.dart';

//utils
import '../../utils/constants/strings.dart';

//core
import '../../../core/helpers/index.dart';

//cubit
import '../cubits/summary/summary_cubit.dart';

//blocs
import '../blocs/issues/issues_bloc.dart';

//domain
import '../../domain/models/work.dart';
import '../../domain/models/arguments.dart';

//services
import '../../locator.dart';
import '../../services/navigation.dart';

class BuildShowcaseIconButton extends StatefulWidget {
  const BuildShowcaseIconButton(
      {super.key,
      required this.keys,
      this.description,
      required this.iconData,
      this.onPressed});
  final GlobalKey keys;
  final String? description;
  final IconData iconData;
  final VoidCallback? onPressed;

  @override
  State<BuildShowcaseIconButton> createState() =>
      _BuildShowcaseIconButtonState();
}

class _BuildShowcaseIconButtonState extends State<BuildShowcaseIconButton> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Showcase(
      key: widget.keys,
      disableMovingAnimation: true,
      description: widget.description,
      child: IconButton(
        onPressed: widget.onPressed,
        icon: Icon(widget.iconData,
            size: 35, color: Theme.of(context).colorScheme.shadow),
      ),
    );
  }
}

// Crear el Showcase para llamar al teléfono del cliente
Widget buildPhoneShowcase(Work work, GlobalKey one, BuildContext context) {
  return BuildShowcaseIconButton(
    keys: one,
    description: 'Llama al teléfono del cliente!',
    iconData: Icons.phone,
    onPressed: () {
      if (work.cellphone != null && work.cellphone != '0') {
        launchUrl(Uri.parse('tel://${work.cellphone}'));
      } else {
        //summaryCubit.error(work.id!, 'No tiene número de celular');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            duration: Duration(seconds: 1),
            backgroundColor: Colors.red,
            content: Text(
              'No tiene número de celular',
              style: TextStyle(color: Colors.white),
            ),
          ),
        );
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
        final NavigationService navigationService =
            locator<NavigationService>();
        final summaryCubit = BlocProvider.of<SummaryCubit>(context);

        if (work.latitude != '0' && work.longitude != '0') {
          navigationService.goTo(AppRoutes.summaryNavigation,
              arguments: SummaryNavigationArgument(work: work));
        } else {
          summaryCubit.error(work.id!, 'No tiene geolocalización 🚨');
        }
      },
      icon: Icon(Icons.directions,
          size: 35, color: Theme.of(context).colorScheme.shadow),
    ),
  );
}

// Crear el Showcase para enviar un mensaje de WhatsApp al cliente
Widget buildWhatsAppShowcase(Work work, GlobalKey two, BuildContext context) {
  return BuildShowcaseIconButton(
    keys: two,
    description: 'Deja un mensaje de WhatsApp!',
    iconData: FontAwesomeIcons.whatsapp,
    onPressed: () async {
      final helperFunctions = HelperFunctions();

      if (work.cellphone != null && work.cellphone != '0') {
        await helperFunctions.launchWhatsApp(
          '+57${work.cellphone}',
          'Hola!, ¿Cómo estás?',
        );
      } else {
        //summaryCubit.error(work.id!, 'No tiene número de celular');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            duration: Duration(seconds: 1),
            backgroundColor: Colors.red,
            content: Text(
              'No tiene número de celular',
              style: TextStyle(color: Colors.white),
            ),
          ),
        );
      }
    },
  );
}

// Crear el Showcase para la opción "Publicar"
Widget buildPublishShowcase(BuildContext context, GlobalKey four, int summaryId) {
  return BuildShowcaseIconButton(
    keys: four,
    description: 'Reportar un problema',
    iconData: Icons.warning_rounded,
    onPressed: () {
      final NavigationService navigationService = locator<NavigationService>();
      final issuesBloc = BlocProvider.of<IssuesBloc>(context);

      issuesBloc.add(GetIssuesList(
          currentStatus: 'summary', workId: null, summaryId: summaryId));
      navigationService.goTo(AppRoutes.issue);
    },
  );
}
