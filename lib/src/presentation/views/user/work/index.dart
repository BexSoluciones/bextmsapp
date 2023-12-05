import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:showcaseview/showcaseview.dart';

//blocs
import '../../../blocs/issues/issues_bloc.dart';

//cubit
import '../../../cubits/work/work_cubit.dart';

//models
import '../../../../domain/models/arguments.dart';

//utils
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/strings.dart';

// //features
import 'features/tabview.dart';
import 'features/visited.dart';
import 'features/not_visited.dart';
import 'features/not-georeferenced.dart';
import 'features/search_delegate.dart';

//services
import '../../../../locator.dart';
import '../../../../services/navigation.dart';
import '../../../../services/storage.dart';

//widgets
import '../../../widgets/icon_wifi_widget.dart';

final NavigationService _navigationService = locator<NavigationService>();
final LocalStorageService _storageService = locator<LocalStorageService>();

class WorkView extends StatefulWidget {
  const WorkView({Key? key, required this.arguments}) : super(key: key);

  final WorkArgument arguments;

  @override
  WorkViewState createState() => WorkViewState();
}

class WorkViewState extends State<WorkView>
    with SingleTickerProviderStateMixin {
  final GlobalKey one = GlobalKey();
  final GlobalKey two = GlobalKey();
  final GlobalKey three = GlobalKey();
  final GlobalKey four = GlobalKey();
  final GlobalKey five = GlobalKey();
  final GlobalKey six = GlobalKey();
  final GlobalKey seven = GlobalKey();
  final GlobalKey eight = GlobalKey();

  late WorkCubit workCubit;
  late IssuesBloc issuesBloc;

  late TabController tabController;
  var tabIndex = 0;

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void initState() {
    tabController = TabController(length: 3, vsync: this);

    workCubit = BlocProvider.of<WorkCubit>(context);
    issuesBloc = BlocProvider.of<IssuesBloc>(context);

    workCubit.getAllWorksByWorkcode(widget.arguments.work.workcode!, true);

    setState(() {
      tabIndex = workCubit.state.index;
      tabController.animateTo(tabIndex);
    });

    startWidgetWork();
    super.initState();
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  void startWidgetWork() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _isFirstLaunch().then((result) {
        if (result == null || result == false) {
          ShowCaseWidget.of(context)
              .startShowCase([one, two, three, four, five, six, seven]);
        }
      });

      tabController.addListener(_handleTabSelection);
    });
  }

  void _handleTabSelection() {
    setState(() {
      tabIndex = tabController.index;
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
  Widget build(BuildContext context) {
    return PopScope(
        canPop: false,
        child: BlocBuilder<WorkCubit, WorkState>(builder: (context, state) {
          return Scaffold(
              key: Key(state.key.toString()),
              appBar: AppBar(
                leading: IconButton(
                  icon:  Icon(Icons.arrow_back_ios_new, color: Theme.of(context).colorScheme.primary),
                  onPressed: () => _navigationService.replaceTo(homeRoute),
                ),
                actions: [
                  const IconConnection(),
                  Visibility(
                      visible: state.started,
                      child: const VerticalDivider(
                        color: kPrimaryColor,
                        thickness: 1.0,
                      )),
                  Showcase(
                      key: two,
                      disableMovingAnimation: true,
                      title: 'Navega!',
                      description:
                          'Llega a todos los cliente a traves de nuestra navegación!',
                      child: Visibility(
                          visible: state.started,
                          child: IconButton(
                              icon: const Icon(Icons.near_me),
                              onPressed: () async {
                                await _navigationService.goTo(navigationRoute,
                                    arguments: widget.arguments.work.workcode);
                              }))),
                  Showcase(
                      key: four,
                      disableMovingAnimation: true,
                      title: 'Busqueda!',
                      description:
                          'Encuantra al cliente que necesitas tanto por nombre, por nit o por dirección',
                      child: Visibility(
                          visible: state.started,
                          child: IconButton(
                              icon: const Icon(Icons.search),
                              onPressed: () async {
                                await showSearch(
                                    context: context,
                                    delegate: SearchWorkDelegate(state.works));
                              }))),
                  Showcase(
                      key: eight,
                      disableMovingAnimation: true,
                      title: 'Reporta un problema!',
                      description:
                          'Cuando tengas un problema con tu ruta, reportalo!',
                      child: Visibility(
                          visible: state.started,
                          child: IconButton(
                              icon: const Icon(Icons.warning),
                              onPressed: () async {
                                issuesBloc.add(GetIssuesList(
                                    currentStatus: 'work',
                                    summaryId: null,
                                    workId: widget.arguments.work.id));
                                await _navigationService.goTo(issueRoute);
                              }))),
                ],
                bottom: state.started
                    ? TabViewWork(
                        tabController: tabController,
                        workcode: widget.arguments.work.workcode!)
                    : null,
              ),
              body: TabBarView(
                controller: tabController,
                children: [
                  NotVisitedViewWork(workcode: widget.arguments.work.workcode!),
                  VisitedViewWork(workcode: widget.arguments.work.workcode!),
                  NotGeoreferencedViewWork(
                      workcode: widget.arguments.work.workcode!)
                ],
              ),
              floatingActionButton: Showcase(
                  key: one,
                  disableMovingAnimation: true,
                  title: 'Comienza tu planilla!',
                  description:
                      'Con esta opción darás inicio a la planilla y todas su funcionalidades!',
                  child: Visibility(
                      visible: !state.started,
                      child: FloatingActionButton(
                        child: const Icon(Icons.play_arrow),
                        onPressed: () => _navigationService.goTo(confirmRoute,
                            arguments: widget.arguments),
                      ))));
        }));
  }
}
