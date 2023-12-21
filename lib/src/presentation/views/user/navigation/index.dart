import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide Badge;
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:lottie/lottie.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:badges/badges.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

//cubit
import '../../../blocs/network/network_bloc.dart';
import '../../../cubits/download/download_cubit.dart';

//domain
import '../../../../domain/models/enterprise_config.dart';

//pages
import 'pages/map/map_view.dart';
import 'pages/stores/stores.dart';
import 'pages/downloader/downloader.dart';
import 'pages/downloading/downloading.dart';
import 'pages/recovery/recovery.dart';
import 'pages/settingsAndAbout/settings_and_about.dart';

//services
import '../../../../locator.dart';
import '../../../../services/storage.dart';

final LocalStorageService _storageService = locator<LocalStorageService>();

class NavigationView extends StatefulWidget {
  const NavigationView({Key? key, required this.workcode}) : super(key: key);
  final String workcode;

  @override
  State<NavigationView> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationView> {
  final GlobalKey one = GlobalKey();
  final GlobalKey two = GlobalKey();

  late final PageController _pageController;
  int currentPageIndex = 0;
  bool extended = false;

  List<Widget> get _pages => [
        MapPage(
            one: one,
            workcode: widget.workcode,
            enterpriseConfig: _storageService.getObject('config') != null
                ? EnterpriseConfig.fromMap(_storageService.getObject('config')!)
                : null),
        const StoresPage(),
        BlocBuilder<DownloadCubit, DownloadState>(
          builder: (context, state) => state.downloadProgress == null
              ? DownloaderPage(
                  enterpriseConfig: _storageService.getObject('config') != null
                      ? EnterpriseConfig.fromMap(
                          _storageService.getObject('config')!)
                      : null)
              : const DownloadingPage(),
        ),
        RecoveryPage(moveToDownloadPage: () => _onDestinationSelected(2)),
        const SettingsAndAboutPage(),
        // if (Platform.isWindows || Platform.isAndroid) const UpdatePage(),
      ];

  List<NavigationDestination> get _destinations => [
        const NavigationDestination(
          icon: Icon(Icons.map),
          label: 'Mapa',
        ),
        const NavigationDestination(
          icon: Icon(Icons.folder),
          label: 'Carpetas',
        ),
        const NavigationDestination(
          icon: Icon(Icons.download),
          label: 'Descargar',
        ),
        NavigationDestination(
          icon: StreamBuilder(
            stream: FMTC.instance.rootDirectory.stats
                .watchChanges()
                .asBroadcastStream(),
            builder: (context, _) => FutureBuilder<List<RecoveredRegion>>(
              future: FMTC.instance.rootDirectory.recovery.failedRegions,
              builder: (context, snapshot) => Badge(
                position: BadgePosition.topEnd(top: -5, end: -6),
                badgeAnimation: const BadgeAnimation.size(
                  animationDuration: Duration(milliseconds: 100),
                ),
                showBadge: currentPageIndex != 3 &&
                    (snapshot.data?.isNotEmpty ?? false),
                child: const Icon(Icons.running_with_errors),
              ),
            ),
          ),
          label: 'Recuperar',
        ),
        const NavigationDestination(
          icon: Icon(Icons.settings),
          label: 'Configuraciones',
        ),
      ];

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  void _onDestinationSelected(int index) {
    setState(() => currentPageIndex = index);
    _pageController.animateToPage(
      currentPageIndex,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
    );
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: currentPageIndex);
    startNavigationScreen();
  }

  void startNavigationScreen() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _isFirstLaunch().then((result) {
        if (result == null || result == false) {
          ShowCaseWidget.of(context).startShowCase([one, two]);
        }
      });
    });
  }

  Future<bool?> _isFirstLaunch() async {
    var isFirstLaunch = _storageService.getBool('navigation-is-init');
    if (isFirstLaunch == null || isFirstLaunch == false) {
      _storageService.setBool('navigation-is-init', true);
    }
    return isFirstLaunch;
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void onMapEvent(MapEvent mapEvent) {
    if (mapEvent is! MapEventMove &&
        mapEvent is! MapEventRotate &&
        kDebugMode) {
      debugPrint(mapEvent.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
        //TODO:: [Heider Zapa uncomment y verify logic work]
        // bottomNavigationBar: size.width > 950
        //     ? null
        //     : NavigationBar(
        //         backgroundColor:
        //             Theme.of(context).navigationBarTheme.backgroundColor,
        //         onDestinationSelected: _onDestinationSelected,
        //         selectedIndex: currentPageIndex,
        //         destinations: _destinations,
        //         labelBehavior: MediaQuery.of(context).size.width > 450
        //             ? null
        //             : NavigationDestinationLabelBehavior.alwaysHide,
        //         height: 70,
        //       ),
        resizeToAvoidBottomInset: false,
        body: BlocBuilder<NetworkBloc, NetworkState>(
            builder: (context, networkState) {
          if (networkState is NetworkFailure) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Lottie.asset('assets/animations/1611-online-offline.json',
                      height: 180, width: 180),
                  const Text('No tienes conexión o tu conexión es lenta.'),
                  const Text(
                      'Actualmente los mapas no funcionan sin internet 😔.',
                      textAlign: TextAlign.center)
                ],
              ),
            );
          } else if (networkState is NetworkSuccess) {
            return _buildBody();
          } else {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Algo ocurrió mientras cargaba la información'),
                  IconButton(
                    icon: Icon(Icons.refresh),
                    onPressed: null,
                  )
                ],
              ),
            );
          }
        }));
  }

  Widget _buildBody() {
    return Row(
      children: [
        if (MediaQuery.of(context).size.width > 950)
          NavigationRail(
            onDestinationSelected: _onDestinationSelected,
            selectedIndex: currentPageIndex,
            groupAlignment: 0,
            extended: extended,
            destinations: _destinations
                .map(
                  (d) => NavigationRailDestination(
                    icon: d.icon,
                    label: Text(d.label),
                    padding: const EdgeInsets.all(10),
                  ),
                )
                .toList(),
            leading: Row(
              children: [
                AnimatedContainer(
                  width: extended ? 205 : 0,
                  duration: kThemeAnimationDuration,
                  curve: Curves.easeInOut,
                ),
                IconButton(
                  icon: AnimatedSwitcher(
                    duration: kThemeAnimationDuration,
                    switchInCurve: Curves.easeInOut,
                    switchOutCurve: Curves.easeInOut,
                    child: Icon(
                      extended ? Icons.menu_open : Icons.menu,
                      key: UniqueKey(),
                    ),
                  ),
                  onPressed: () => setState(() => extended = !extended),
                  tooltip: !extended ? 'Extend Menu' : 'Collapse Menu',
                ),
              ],
            ),
          ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: MediaQuery.of(context).size.width > 950
                  ? const Radius.circular(16)
                  : Radius.zero,
              bottomLeft: MediaQuery.of(context).size.width > 950
                  ? const Radius.circular(16)
                  : Radius.zero,
            ),
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: _pages,
            ),
          ),
        ),
      ],
    );
  }
}
