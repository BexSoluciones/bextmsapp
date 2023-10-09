import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:showcaseview/showcaseview.dart';

//utils
import '../../../../utils/constants/strings.dart';

//models
import '../../../../domain/models/arguments.dart';

//cubit
import '../../../cubits/summary/summary_cubit.dart';

//widgets
import '../../../widgets/icon_wifi_widget.dart';

//services
import '../../../../locator.dart';
import '../../../../services/storage.dart';
import '../../../../services/navigation.dart';

//features
import 'features/header.dart';
import 'features/list_view.dart';

final NavigationService _navigationService = locator<NavigationService>();
final LocalStorageService _storageService = locator<LocalStorageService>();

class SummaryView extends StatefulWidget {
  const SummaryView({Key? key, required this.arguments}) : super(key: key);

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

  @override
  void didChangeDependencies() {
    summaryCubit = BlocProvider.of<SummaryCubit>(context);
    summaryCubit.getAllSummariesByOrderNumber(widget.arguments.work.id!);
    super.didChangeDependencies();
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
    var isFirstLaunch = _storageService.getBool('summary-is-init');
    if (isFirstLaunch == null || isFirstLaunch == false) {
      _storageService.setBool('summary-is-init', true);
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
        child: BlocBuilder<SummaryCubit, SummaryState>(builder: (context, state) {
          return Scaffold(
            resizeToAvoidBottomInset: true,
            appBar: AppBar(
              backgroundColor: Theme.of(context).colorScheme.primary,
              leading: IconButton(
                  onPressed: () {
                    if (widget.arguments.origin != null &&
                        widget.arguments.origin == 'navigation') {
                      _navigationService.goBack();
                    } else {
                      _navigationService.goTo(workRoute,
                          arguments: WorkArgument(work: widget.arguments.work));
                    }
                  },
                  icon:  Icon(Icons.arrow_back_ios_new,color:Theme.of(context).colorScheme.secondaryContainer)),
              actions: [
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: IconConnection(),
                ),
                state.time != null
                    ? GestureDetector(
                        onTap: () async => await summaryCubit
                            .getDiffTime(widget.arguments.work.id!),
                        child: Text('Tiempo ${state.time}',
                            style:  TextStyle(fontSize: 18,color:Theme.of(context).colorScheme.secondaryContainer)))
                    : Container(),
              ],
              shadowColor: Theme.of(context).colorScheme.shadow,
              notificationPredicate: (ScrollNotification notification) {
                return notification.depth == 1;
              },
            ),
            body: _buildBody()
          );
        }));
  }

  Widget _buildBody() {
    return SafeArea(
        child: Center(
          child: ListView(
            children: [
              Container(color:Theme.of(context).colorScheme.primary,child: HeaderSummary(arguments: widget.arguments)),
              ListViewSummary(
                  arguments: widget.arguments,
                  one: one,
                  two: two,
                  three: three,
                  four: four,
                  five: five)
            ],
          ),
        ));
  }
}
