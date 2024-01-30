import 'dart:async';
import 'package:bexdeliveries/src/config/size.dart';
import 'package:bexdeliveries/src/domain/models/enterprise_config.dart';
import 'package:bexdeliveries/src/presentation/blocs/gps/gps_bloc.dart';
import 'package:bexdeliveries/src/presentation/widgets/upgrader_widget.dart';
import 'package:flutter/material.dart' hide SearchBar;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:upgrader/upgrader.dart';

//cubit
import '../../../cubits/home/home_cubit.dart';

//utils
import '../../../../utils/constants/colors.dart';

//services
import '../../../../locator.dart';
import '../../../../services/storage.dart';

//widgets
import '../../../widgets/drawer_widget.dart';
import 'features/status.dart';
import 'features/logout.dart';
import 'features/list_view.dart';
import 'features/search.dart';
import 'features/sync.dart';

final LocalStorageService _storageService = locator<LocalStorageService>();

class HomeView extends StatefulWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  HomeViewState createState() => HomeViewState();
}

class HomeViewState extends State<HomeView>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  final GlobalKey one = GlobalKey();
  final GlobalKey two = GlobalKey();
  final GlobalKey three = GlobalKey();
  final GlobalKey four = GlobalKey();
  final GlobalKey five = GlobalKey();

  late HomeCubit homeCubit;
  late GpsBloc gpsBloc;

  @override
  void initState() {
    EnterpriseConfig? enterpriseConfig;
    var storedConfig = _storageService.getObject('config');
    if (storedConfig != null) {
      enterpriseConfig = EnterpriseConfig.fromMap(storedConfig);
    }
    startHomeWidget();
    homeCubit = BlocProvider.of<HomeCubit>(context);
    gpsBloc = BlocProvider.of<GpsBloc>(context);
    homeCubit.getAllWorks();
    homeCubit.getUser();
    gpsBloc.startFollowingUser();
    if (enterpriseConfig != null && enterpriseConfig.backgroundLocation!) {
      helperFunctions.initLocationService();
    }

    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void startHomeWidget() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      helperFunctions.versionCheck(context);
      await _isFirstLaunch().then((result) {
        if (result == null || result == false) {
          ShowCaseWidget.of(context)
              .startShowCase([one, two, three, four, five]);
        }
      });
    });
  }

  Future<bool?> _isFirstLaunch() async {
    var isFirstLaunch = _storageService.getBool('home-is-init');
    if (isFirstLaunch == null || isFirstLaunch == false) {
      _storageService.setBool('home-is-init', true);
    }
    return isFirstLaunch;
  }

  @override
  Widget build(BuildContext context) {
    final calculatedTextScaleFactor = textScaleFactor(context);
    final calculatedFon = getProportionateScreenHeight(16);
    return UpgraderDialog(
        child: PopScope(
            canPop: false,
            child: Scaffold(
              drawer: drawer(context, homeCubit.state.user),
              appBar: AppBar(
                iconTheme:
                    IconThemeData(color: Theme.of(context).colorScheme.primary),
                actions: [
                  StatusBar(one: one),
                  const VerticalDivider(
                    color: kPrimaryColor,
                    thickness: 1.0,
                  ),
                  SyncBar(two: two),
                  SearchBar(three: three),
                  LogoutBar(four: four),
                ],
                title: Text(
                  'Servicios',
                  textScaler: TextScaler.linear(calculatedTextScaleFactor),
                  style: TextStyle(
                      fontSize: calculatedFon, fontWeight: FontWeight.bold),
                ),
                notificationPredicate: (ScrollNotification notification) {
                  return notification.depth == 1;
                },
              ),
              body: SafeArea(
                  child: Padding(
                      padding: const EdgeInsets.only(
                        top: 20.0,
                        left: 16.0,
                        right: 16.0,
                        bottom: 20.0,
                      ),
                      child: HomeListView(five: five))),
            )));
  }
}
