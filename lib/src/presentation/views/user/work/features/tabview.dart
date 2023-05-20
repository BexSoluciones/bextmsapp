import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

//cubit
import '../../../../cubits/work/work_cubit.dart';

class TabViewWork extends StatefulWidget  implements PreferredSizeWidget {
  const TabViewWork({super.key,  required this.tabController, required this.workcode });

  final TabController tabController;
  final String workcode;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  State<TabViewWork> createState() => _TabViewWorkState();
}

class _TabViewWorkState extends State<TabViewWork> {

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WorkCubit, WorkState>(
      builder: (context, state) {
        return TabBar(
          controller: widget.tabController,
          isScrollable: true,
          labelPadding: const EdgeInsets.symmetric(horizontal: 10.0),
          tabs: [
            Tab(
                text: 'NO VISITADOS (${state.notVisited.length.toString()})',
                icon: const Icon(Icons.emoji_people)),
            Tab(
                text: 'VISITADOS (${state.visited.length.toString()})',
                icon:
                const Icon(Icons.nature_people_outlined)),
            Tab(
                text: 'NO GEOREFERENCIADOS (${state.notGeoreferenced.length.toString()})',
                icon: const Icon(Icons.location_off))

          ],
        );
      }
    );
  }
}