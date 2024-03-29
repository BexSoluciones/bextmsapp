import 'dart:async';
import 'package:bexdeliveries/src/services/styled_dialog_controller.dart';
import 'package:flutter/material.dart' hide SearchBar;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:showcaseview/showcaseview.dart';

//core
import '../../../../../core/helpers/index.dart';

//config
import '../../../../config/size.dart';

//cubit
import '../../../cubits/home/home_cubit.dart';

//blocs
import '../../../blocs/gps/gps_bloc.dart';

//utils
import '../../../../utils/constants/colors.dart';

//services
import '../../../../locator.dart';
import '../../../../services/storage.dart';

//widgets
import '../../../widgets/drawer_widget.dart';
import '../../../widgets/error_alert_dialog.dart';
import '../../../widgets/upgrader_widget.dart';
import 'features/status.dart';
import 'features/logout.dart';
import 'features/list_view.dart';
import 'features/search.dart';
import 'features/sync.dart';

class HomeView extends StatefulWidget {
  final String navigation;
  const HomeView({super.key, required this.navigation});

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

  final LocalStorageService _storageService = locator<LocalStorageService>();
  final helperFunctions = HelperFunctions();

  late HomeCubit homeCubit;
  late GpsBloc gpsBloc;

  @override
  void initState() {
    startHomeWidget();
    homeCubit = BlocProvider.of<HomeCubit>(context);
    gpsBloc = BlocProvider.of<GpsBloc>(context);
    homeCubit.getAllWorks();
    homeCubit.getUser();
    gpsBloc.add(OnStartFollowingUser());

    if (widget.navigation == 'collection') {
      Future.delayed(Duration.zero, () => homeCubit.schedule());
    }

    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    if (widget.navigation == 'collection') {
      Future.delayed(Duration.zero, () => homeCubit.schedule());
    }
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void startHomeWidget() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
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

  final styledDialogController = locator<StyledDialogController>();

  @override
  Widget build(BuildContext context) {
    final calculatedTextScaleFactor = textScaleFactor(context);
    final calculatedFon = getProportionateScreenHeight(16);
    return BlocConsumer<GpsBloc, GpsState>(
      listener: (context, state) {
        if (state.isGpsEnabled == true && state.showDialog == true) {
          styledDialogController.closeVisibleDialog();
        } else if (state.isGpsEnabled == false) {
          context.read<GpsBloc>().add(const GpsShowDisabled());
          styledDialogController.showDialogWithStyle(Status.error,
              closingFunction: () => Navigator.of(context).pop());
        }
      },
      builder: (context, state) => UpgraderDialog(
          child: PopScope(
              canPop: false,
              child: Scaffold(
                drawer: drawer(context, homeCubit.state.user),
                appBar: AppBar(
                  iconTheme: IconThemeData(
                      color: Theme.of(context).colorScheme.primary),
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
              ))),
    );
  }
}
