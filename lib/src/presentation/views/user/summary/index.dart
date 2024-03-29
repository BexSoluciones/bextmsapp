import 'package:bexdeliveries/src/config/size.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:showcaseview/showcaseview.dart';

//models
import '../../../../domain/models/arguments.dart';

//cubit
import '../../../cubits/summary/summary_cubit.dart';

//features
import 'features/bottom_bar.dart';
import 'features/header.dart';
import 'features/list_view.dart';
import 'features/sliver-app_bar.dart';

class SummaryView extends StatefulWidget {
  const SummaryView({super.key, required this.arguments});

  final SummaryArgument arguments;

  @override
  SummaryViewState createState() => SummaryViewState();
}

class SummaryViewState extends State<SummaryView> {
  final GlobalKey one = GlobalKey();
  final GlobalKey two = GlobalKey();
  final GlobalKey three = GlobalKey();
  final GlobalKey four = GlobalKey();
  final GlobalKey five = GlobalKey();

  late SummaryCubit summaryCubit;

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void initState() {
    summaryCubit = BlocProvider.of<SummaryCubit>(context);
    summaryCubit.getAllSummariesByOrderNumber(widget.arguments.work.id!);

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
    var isFirstLaunch = summaryCubit.storageService.getBool('summary-is-init');
    if (isFirstLaunch == null || isFirstLaunch == false) {
      summaryCubit.storageService.setBool('summary-is-init', true);
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
        child: Scaffold(resizeToAvoidBottomInset: true, body: _buildBody()));
  }

  Widget _buildBody() {
    return SizedBox(
      width: getFullScreenWidth(),
      height: getFullScreenHeight(),
      child: Stack(
        children: [
          SizedBox(
            width: getFullScreenWidth(),
            height: getFullScreenHeight()! / 1.1,
            child: CustomScrollView(
              slivers: [
                AppBarSummary(
                  arguments: widget.arguments,
                  summaryCubit: summaryCubit,
                ),
                HeaderSummary(
                  arguments: widget.arguments,
                  one: one,
                  two: two,
                  three: three,
                  four: four,
                ),
                ListViewSummary(
                    summaryCubit: summaryCubit,
                    arguments: widget.arguments,
                    one: one,
                    two: two,
                    three: three,
                    four: four,
                    five: five),
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: BottomViewSummary(
              arguments: widget.arguments,
              summaryCubit: summaryCubit,
            ),
          ),
        ],
      ),
    );
  }
}
