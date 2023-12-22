import 'package:showcaseview/showcaseview.dart';
import 'package:flutter/material.dart';
import 'dart:async';

//domain
import '../../../../domain/models/arguments.dart';

//features
import 'features/sliver-appbar.dart';
import 'features/listview.dart';

//services
import '../../../../locator.dart';
import '../../../../services/storage.dart';

final LocalStorageService _storageService = locator<LocalStorageService>();

class PackageView extends StatefulWidget {
  const PackageView({Key? key, required this.arguments}) : super(key: key);

  final PackageArgument arguments;

  @override
  PackageViewState createState() => PackageViewState();
}

class PackageViewState extends State<PackageView> with WidgetsBindingObserver {
  final GlobalKey one = GlobalKey();
  final GlobalKey two = GlobalKey();

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void initState() {
    startPackageWidget();
    super.initState();
  }

  void startPackageWidget() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _isFirstLaunch().then((result) {
        if (result == null || result == false) {
          ShowCaseWidget.of(context).startShowCase([one, two]);
        }
      });
    });
  }

  Future<bool?> _isFirstLaunch() async {
    var isFirstLaunch = _storageService.getBool('work-is-init');
    if (isFirstLaunch == null || isFirstLaunch == false) {
      _storageService.setBool('work-is-init', true);
    }
    return isFirstLaunch;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
        canPop: false,
        child: Scaffold(
          resizeToAvoidBottomInset: true,
          body: CustomScrollView(
            slivers: <Widget>[
              AppBarInventory(
                arguments: widget.arguments,
                one: one,
                isArrived: false,
              ),
              ListViewPackage(
                arguments: widget.arguments,
                two: two,
              )
            ],
          ),
        ));
  }
}
