import 'package:bexdeliveries/src/config/size.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

//utils
import '../../../../../utils/constants/nums.dart';

//domain
import '../../../../../domain/models/work.dart';

//cubit
import '../../../../cubits/work/work_cubit.dart';

//extensions
import '../../../../../utils/extensions/scroll_controller_extension.dart';

//widget
import 'sub-item.dart';

class NotVisitedViewWork extends StatefulWidget {
  const NotVisitedViewWork({super.key, required this.workcode});

  final String workcode;

  @override
  NotVisitedViewWorkState createState() => NotVisitedViewWorkState();
}

class NotVisitedViewWorkState extends State<NotVisitedViewWork> {
  bool isLoading = false;

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    final calculatedTextScaleFactor = textScaleFactor(context);
    final workCubit = BlocProvider.of<WorkCubit>(context);
    final scrollController = ScrollController();

    scrollController.onScrollEndsListener(() {
      workCubit.getAllWorksByWorkcode(widget.workcode, false);
    });

    return SafeArea(
        child: BlocBuilder<WorkCubit, WorkState>(builder: (context, state) {
      switch (state.runtimeType) {
        case WorkLoading:
          return const Center(child: CupertinoActivityIndicator());
        case WorkSuccess:
          return _buildWork(scrollController, widget.workcode, state.notVisited,
              state.noMoreData, state.started, calculatedTextScaleFactor);
        default:
          return const SizedBox();
      }
    }));
  }

  Widget _buildWork(
      ScrollController scrollController,
      String workcode,
      List<Work> works,
      bool noMoreData,
      bool isStarted,
      double calculatedTextScaleFactor) {
    return Padding(
        padding: const EdgeInsets.only(
            left: kDefaultPadding, right: kDefaultPadding, top: 10.0),
        child: Column(
          children: [
            SizedBox(
              height: 40,
              width: double.infinity,
              child: Center(
                  child: Text('SERVICIO: ${widget.workcode}',
                      textScaler: TextScaler.linear(calculatedTextScaleFactor),
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary))),
            ),
            Flexible(
                flex: 16,
                child: buildStaticBody(works, scrollController, isStarted)),
            if (!noMoreData)
              const Padding(
                padding: EdgeInsets.only(top: 14, bottom: 32),
                child: CupertinoActivityIndicator(),
              ),
          ],
        ));
  }

  Widget buildStaticBody(
      List<Work> works, ScrollController scrollController, bool isStarted) {
    if (works.isEmpty) {
      return const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [Text('No tienes clientes por visitar.')],
      );
    } else {
      return ListView.builder(
          controller: scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: works.length,
          itemBuilder: (context, index) {
            final work = works[index];
            return SubItemWork(index: index, work: work, enabled: isStarted);
          });
    }
  }
}
