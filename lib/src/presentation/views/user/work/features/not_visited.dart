import 'package:bexdeliveries/src/config/size.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

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
  late WorkCubit workCubit;
  static const _pageSize = 20;

  final PagingController<int, Work> _pagingController =
      PagingController(firstPageKey: 0);

  Future<void> _fetchPage(int pageKey) async {
    try {
      final newItems = await workCubit.getAllWorksByWorkcodePaginated(
          widget.workcode, pageKey, _pageSize);
      final isLastPage = newItems.length < _pageSize;
      if (isLastPage) {
        _pagingController.appendLastPage(newItems);
      } else {
        final nextPageKey = pageKey + newItems.length;
        _pagingController.appendPage(newItems, nextPageKey);
      }
    } catch (error) {
      _pagingController.error = error;
    }
  }

  @override
  void initState() {
    workCubit = BlocProvider.of<WorkCubit>(context);
    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });
    super.initState();
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    final calculatedTextScaleFactor = textScaleFactor(context);

    return SafeArea(
        child: BlocBuilder<WorkCubit, WorkState>(builder: (context, state) {
      switch (state.runtimeType) {
        case WorkLoading:
          return const Center(child: CupertinoActivityIndicator());
        case WorkSuccess:
          return _buildWork(widget.workcode, state.notVisited, state.noMoreData,
              state.started, calculatedTextScaleFactor);
        default:
          return const SizedBox();
      }
    }));
  }

  Widget _buildWork(String workcode, List<Work> works, bool noMoreData,
      bool isStarted, double calculatedTextScaleFactor) {
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
            Flexible(flex: 16, child: buildStaticBody(isStarted)),
          ],
        ));
  }

  Widget buildStaticBody(bool isStarted) {
    if (_pagingController.itemList != null && _pagingController.itemList!.isEmpty) {
      return const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [Text('No tienes clientes por visitar.')],
      );
    } else {
      return PagedListView<int, Work>(
        shrinkWrap: true,
        pagingController: _pagingController,
        builderDelegate: PagedChildBuilderDelegate<Work>(
            itemBuilder: (context, work, index) {
          return SubItemWork(index: index, work: work, enabled: isStarted);
        }),
      );
    }
  }
}
