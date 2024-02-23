import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:showcaseview/showcaseview.dart';

//model
import '../../../../../domain/models/work.dart';

//cubits
import '../../../../cubits/home/home_cubit.dart';

//widgets
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
    homeCubit.getAllWorks();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return buildBlocConsumer();
  }

  void buildBlocListener(BuildContext context, HomeState state) async {
    if (state.status == HomeStatus.failure && state.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            state.error!,
            style: const TextStyle(color: Colors.white),
          ),
        ),
      );
    }
  }

  Widget buildBlocConsumer() {
    return BlocConsumer<HomeCubit, HomeState>(
      listener: buildBlocListener,
      builder: (context, state) {
        if (state.status == HomeStatus.loading) {
          return const Center(child: CupertinoActivityIndicator());
        } else if (state.status == HomeStatus.success ||
            state.status == HomeStatus.failure) {
          return _buildHome(state.works);
        } else {
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
        if (work.active == true && work.status != 'complete') {
          if (index == 0) {
            return showCaseServiceTile(context, work);
          } else {
            return ItemWork(work: work);
          }
        } else {
          return const SizedBox();
        }
      },
    );
  }

  Widget showCaseServiceTile(BuildContext context, Work work) {
    return Showcase(
        key: widget.five,
        disableMovingAnimation: true,
        description:
            'Este en tu primera planilla, click para ver sus clientes!',
        child: ItemWork(work: work));
  }
}
