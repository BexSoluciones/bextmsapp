import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:showcaseview/showcaseview.dart';

//cubit
import '../../../../cubits/home/home_cubit.dart';

class SyncBar extends StatelessWidget {
  const SyncBar({Key? key, required this.two}) : super(key: key);

  final GlobalKey two;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (_, state) {
        switch (state.runtimeType) {
          case HomeLoading:
            return const Center(child: CupertinoActivityIndicator());
          case HomeSuccess:
            return Showcase(
                key: two,
                disableMovingAnimation: true,
                title: 'Sincronización!',
                description:
                    'Sincroniza todas las planillas para que estes al día',
                child: IconButton(
                    icon: const Icon(Icons.sync),
                    onPressed: () => context.read<HomeCubit>().sync()
                    ));
          default:
            return const SizedBox();
        }
      },
    );
  }
}
