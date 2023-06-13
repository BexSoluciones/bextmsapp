import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:showcaseview/showcaseview.dart';

//model
import '../../../../../domain/models/work.dart';

//cubits
import '../../../../cubits/home/home_cubit.dart';

//widgets
import '../../../../widgets/skeleton_loader_widget.dart';
import 'item.dart';

class HomeListView extends StatefulWidget {
  const HomeListView({Key? key, required this.five}) : super(key: key);

  final GlobalKey five;

  @override
  State<HomeListView> createState() => _HomeListViewState();
}

class _HomeListViewState extends State<HomeListView> {

  late HomeCubit homeCubit;

  @override
  void initState() {
    homeCubit = BlocProvider.of<HomeCubit>(context);
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (_, state) {
        switch (state.runtimeType) {
          case HomeLoading:
            return const SkeletonLoading(cant: 10);
          case HomeSuccess:
            return _buildHome(
              state.works,
            );
          default:
            return const SizedBox();
        }
      },
    );
  }

  Widget _buildHome(
    List<Work> works,
  ) {
    return ListView.separated(
      itemCount: works.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16.0),
      itemBuilder: (context, index) {
        final work = works[index];
        if (index == 0) {
          return showCaseServiceTile(context, work);
        } else {
          if (work.active == true && work.status != 'complete') {
            return ItemWork(work: work);
          } else {
            return Container();
          }
        }
      },
    );
  }

  Widget showCaseServiceTile(BuildContext context, Work work) {
    if (work.active == true && work.status != 'complete') {
      return Showcase(
          key: widget.five,
          disableMovingAnimation: true,
          description:
              'Este en tu primera planilla, click para ver sus clientes!',
          child: ItemWork(work: work));
    } else {
      return Container();
    }
  }
}
