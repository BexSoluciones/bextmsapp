import 'dart:async';

import 'package:bexdeliveries/src/config/size.dart';
import 'package:flutter/material.dart' hide SearchBar;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:showcaseview/showcaseview.dart';

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
    with SingleTickerProviderStateMixin {
  final GlobalKey one = GlobalKey();
  final GlobalKey two = GlobalKey();
  final GlobalKey three = GlobalKey();
  final GlobalKey four = GlobalKey();
  final GlobalKey five = GlobalKey();

  late HomeCubit homeCubit;

  @override
  void initState() {
    startHomeWidget();
    homeCubit = BlocProvider.of<HomeCubit>(context);
    homeCubit.getAllWorks();
    homeCubit.getUser();
    super.initState();
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

  @override
  Widget build(BuildContext context) {
    final calculatedTextScaleFactor = textScaleFactor(context);
    final calculatedFon = getProportionateScreenHeight(16);
    return WillPopScope(
        onWillPop: () async {
          return false;
        },
        child: Scaffold(
          drawer: drawer(context, homeCubit.state.user),
          appBar: AppBar(
            iconTheme: IconThemeData(color: Theme.of(context).colorScheme.primary),
            actions: [
              StatusBar(one: one),
              const VerticalDivider(
                color: kPrimaryColor,
                thickness: 1.0,
              ),
              SyncBar(two: two),
              SearchBar(three: three),
              LogoutBar(four: four)
            ],
            title:  Text(
              'Servicios',
              textScaleFactor: calculatedTextScaleFactor ,
              style: TextStyle(fontSize: calculatedFon, fontWeight: FontWeight.bold),
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
        ));
  }
}
