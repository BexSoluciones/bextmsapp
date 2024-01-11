import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

//cubit
import '../../../../cubits/home/home_cubit.dart';

class ScheduleBar extends StatefulWidget {
  const ScheduleBar({Key? key}) : super(key: key);

  @override
  State<ScheduleBar> createState() => _LogoutBarState();
}

class _LogoutBarState extends State<ScheduleBar> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (_, state) {
        switch (state.status) {
          case HomeStatus.loading:
            return const Center(child: CupertinoActivityIndicator());
          case HomeStatus.success:
            return IconButton(
                icon: const Icon(Icons.task),
                onPressed: () async {
                  BlocProvider.of<HomeCubit>(context).schedule();
                });
          case HomeStatus.failure:
            return IconButton(
                icon: const Icon(Icons.task),
                onPressed: () async {
                  BlocProvider.of<HomeCubit>(context).schedule();
                });
          default:
            return const SizedBox();
        }
      },
    );
  }
}
