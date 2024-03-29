import 'package:bexdeliveries/src/presentation/blocs/issues/issues_bloc.dart';
import 'package:bexdeliveries/src/presentation/widgets/drawe.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yaml/yaml.dart';

//model
import '../../domain/models/user.dart';

//utils
import '../../utils/constants/strings.dart';

//services
import '../../locator.dart';
import '../../services/navigation.dart';
import '../../services/storage.dart';
import '../blocs/theme/theme_bloc.dart';

final NavigationService _navigationService = locator<NavigationService>();
final LocalStorageService _storageService = locator<LocalStorageService>();

Drawer drawer(BuildContext context, User? user) {
  var issuesBloc = context.read<IssuesBloc>();

  return Drawer(
    child: ListView(
      padding: EdgeInsets.zero,
      children: <Widget>[
        UserAccountsDrawerHeader(
          accountName: Text(
            user != null ? '${user.name}' : 'No User',
          ),
          accountEmail: Text(
            user != null ? user.email! : 'no-repy@bexsoluciones.com',
            // textScaleFactor: textScaleFactor(context)
          ),
          otherAccountsPictures: [
            BlocBuilder<ThemeBloc, ThemeState>(
              builder: (context, state) {
                return IconButton(
                  icon: Icon(
                      state.isDarkTheme
                          ? Icons.wb_sunny
                          : Icons.nightlight_round,
                      color: Colors.white),
                  onPressed: () {
                    BlocProvider.of<ThemeBloc>(context).add(ChangeTheme());
                  },
                );
              },
            )
          ],
          currentAccountPicture: CircleAvatar(
            backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
            child: Text(
              user != null ? user.name![0] : 'S',
              style: const TextStyle(fontSize: 40.0),
            ),
          ),
        ),
        createDrawerItem(
            context: context,
            icon: Icons.business,
            text: _storageService.getString('company')?.toUpperCase() ?? '¡No existe!',
            onTap: null),
        createDrawerItem(
            context: context,
            icon: Icons.help_center,
            text: 'Ver tutorial.',
            onTap: () {
              _storageService.setBool('home-is-init', false);
              _storageService.setBool('work-is-init', false);
              _storageService.setBool('navigation-is-init', false);
              _storageService.setBool('summary-is-init', false);
              _storageService.setBool('inventory-is-init', false);
              _navigationService.goBack();
            }),
        createDrawerItem(
            context: context,
            icon: Icons.import_export,
            text: 'Exportar base de datos.',
            onTap: () => _navigationService.goTo(AppRoutes.database)),
        createDrawerItem(
            context: context,
            icon: Icons.query_builder,
            text: 'Consultas.',
            onTap: () => _navigationService.goTo(AppRoutes.query)),
        createDrawerItem(
            context: context,
            icon: Icons.transfer_within_a_station,
            text: 'Cierre de ruta.',
            onTap: () => _navigationService.goTo(AppRoutes.transaction)),
        createDrawerItem(
            context: context,
            icon: Icons.warning_rounded,
            text: 'Reportar un problema.',
            onTap: () async {
              issuesBloc.add(GetIssuesList(
                  currentStatus: 'general', summaryId: null, workId: null));
              await _navigationService.goTo(AppRoutes.issue);
            }),
        createDrawerItem(
            context: context,
            icon: Icons.queue,
            text: 'Cola de procesamiento.',
            onTap: () => _navigationService.goTo(AppRoutes.processingQueue)),
        if (kDebugMode) const Divider(),
        if (kDebugMode) ... [
          createDrawerItem(
              context: context,
              icon: Icons.location_history,
              text: 'Localizaciones.',
              onTap: () => _navigationService.goTo(AppRoutes.locations)),
          createDrawerItem(
              context: context,
              icon: Icons.photo,
              text: 'Fotos.',
              onTap: () => _navigationService.goTo(AppRoutes.photo)),
          createDrawerItem(
              context: context,
              icon: Icons.notifications,
              text: 'Notificaciones.',
              onTap: () => _navigationService.goTo(AppRoutes.notifications)),
          createDrawerItem(
              context: context,
              icon: Icons.list_alt,
              text: 'Transacciones.',
              onTap: () => _navigationService.goTo(AppRoutes.transactions)),
        ],
        const Divider(),
        FutureBuilder(
            future: rootBundle.loadString('pubspec.yaml'),
            builder: (context, snapshot) {
              var version = 'Unknown';
              if (snapshot.hasData) {
                var yaml = loadYaml(snapshot.data as String);
                version = yaml['version'];
              }

              return ListTile(
                title: Text(version),
                onTap: () {},
              );
            }),
      ],
    ),
  );
}

Widget _createDrawerItem(
    {required BuildContext context,
    required IconData icon,
    required String text,
    GestureTapCallback? onTap}) {
  return ListTile(
    title: Row(
      children: <Widget>[
        Icon(icon,color: Theme.of(context).colorScheme.outline,),
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Text(text),
        )
      ],
    ),
    onTap: onTap,
  );
}
