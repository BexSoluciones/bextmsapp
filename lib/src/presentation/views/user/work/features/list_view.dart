import 'package:bexdeliveries/src/config/size.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:showcaseview/showcaseview.dart';

//cubit
import '../../../../../domain/models/work.dart';
import '../../../../../presentation/cubits/work/work_cubit.dart';

//utils
import '../../../../../utils/constants/nums.dart';

//features
import 'item_work.dart';

//widgets
import '../../../../widgets/skeleton_loader_widget.dart';

//extensions
import '../../../../../utils/extensions/scroll_controller_extension.dart';

class ListViewWork extends StatefulWidget {
  const ListViewWork({Key? key, required this.workcode, required this.six})
      : super(key: key);

  final GlobalKey six;
  final String workcode;

  @override
  ListViewWorkState createState() => ListViewWorkState();
}

class ListViewWorkState extends State<ListViewWork> {
  final scrollController = ScrollController();

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final calculatedTextScaleFactor = textScaleFactor(context);
    final calculatedFon = getProportionateScreenHeight(18);
    final workCubit = BlocProvider.of<WorkCubit>(context);
    final scrollController = ScrollController();

    scrollController.onScrollEndsListener(() {
      workCubit.getAllWorksByWorkcode(widget.workcode, false);
    });

    return BlocBuilder<WorkCubit, WorkState>(builder: (context, state) {
      switch (state.runtimeType) {
        case WorkLoading:
          return const SkeletonLoading(cant: 10);
        case WorkSuccess:
          return _buildWork(scrollController, widget.workcode, state.works,
              state.noMoreData, calculatedTextScaleFactor, calculatedFon);
        default:
          return const SizedBox();
      }
    });
  }

  Widget _buildWork(
      ScrollController scrollController,
      String workcode,
      List<Work> works,
      bool noMoreData,
      double calculatedTextScaleFactor,
      double calculatedFon) {
    return Padding(
      padding: const EdgeInsets.all(kDefaultPadding),
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        controller: scrollController,
        slivers: [
          SliverToBoxAdapter(
              child: SizedBox(
                  height: 40,
                  width: double.infinity,
                  child: Center(
                      child: Text('SERVICIO: $workcode',
                          textScaler:
                              TextScaler.linear(calculatedTextScaleFactor),
                          style: TextStyle(
                              fontSize: calculatedFon,
                              fontWeight: FontWeight.bold))))),
          buildStaticBody(works),
          if (!noMoreData)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.only(top: 14, bottom: 32),
                child: CupertinoActivityIndicator(),
              ),
            )
        ],
      ),
    );
  }

  Widget buildStaticBody(works) {
    if (works.isEmpty) {
      return SliverToBoxAdapter(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            //TODO: [Heider Zapa] change for svg
            //Lottie.asset('assets/animations/36499-page-not-found.json'),
            Text('No hay clients asociadas a este servicio ${widget.workcode}.')
          ],
        ),
      );
    } else {
      return SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final work = works[index];
            if (index == 0) {
              return showCaseClientTile(context, work, index);
            } else {
              return ItemWork(index: index, work: work);
            }
          },
          childCount: works.length,
        ),
      );
    }
  }

  Widget showCaseClientTile(BuildContext context, work, index) {
    return Showcase(
        key: widget.six,
        disableMovingAnimation: true,
        description: 'Este en tu primer cliente, click para ver sus facturas!',
        child: ItemWork(index: index, work: work));
  }
}
