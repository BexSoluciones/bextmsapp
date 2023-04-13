import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:showcaseview/showcaseview.dart';

//models
import '../../../../domain/models/arguments.dart';

//cubit
import '../../../cubits/inventory/inventory_cubit.dart';

//services
import '../../../../locator.dart';
import '../../../../services/storage.dart';

//features
import 'features/silverapp_bar.dart';
import 'features/header.dart';
import 'features/list_view.dart';
import 'features/bottom_bar.dart';

final LocalStorageService _storageService = locator<LocalStorageService>();

class InventoryView extends StatefulWidget {
  const InventoryView({Key? key, required this.arguments}) : super(key: key);

  final InventoryArgument arguments;

  @override
  InventoryViewState createState() => InventoryViewState();
}

class InventoryViewState extends State<InventoryView> {
  final GlobalKey one = GlobalKey();
  final GlobalKey two = GlobalKey();
  final GlobalKey three = GlobalKey();
  final GlobalKey four = GlobalKey();
  final GlobalKey five = GlobalKey();

  late InventoryCubit inventoryCubit;

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void initState() {
    inventoryCubit = BlocProvider.of<InventoryCubit>(context);
    inventoryCubit.getAllInventoryByOrderNumber(widget.arguments.work.id!, widget.arguments.orderNumber);

    startWidgetSummary();
    super.initState();
  }

  void startWidgetSummary() {
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
    var isFirstLaunch = _storageService.getBool('inventory-is-init');
    if (isFirstLaunch == null || isFirstLaunch == false) {
      _storageService.setBool('inventory-is-init', true);
    }
    return isFirstLaunch;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async => false,
        child: BlocBuilder<InventoryCubit, InventoryState>(builder: (context, state) {
          return Scaffold(
              resizeToAvoidBottomInset: true,
              body: CustomScrollView(
                slivers: [
                  AppBarInventory(
                      arguments: widget.arguments,
                      one: one,
                      isArrived: state.isArrived ?? false),
                  HeaderInventory(
                      arguments: widget.arguments,
                      totalSummaries: state.totalSummaries,
                      two: two),
                  ListViewInventory(
                      arguments: widget.arguments,
                      three: three,
                      isArrived: state.isArrived ?? false)
                ],
              ),
              bottomNavigationBar: BottomBarInventory(
                arguments: widget.arguments,
                isArrived: state.isArrived ?? false,
                isRejected: state.isRejected ?? false,
                isPartial: state.isPartial ?? false,
                myContext: context,
                four: four,
              ));
        }));
  }
}
