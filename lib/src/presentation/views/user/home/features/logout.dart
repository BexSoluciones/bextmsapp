import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:showcaseview/showcaseview.dart';

//cubit
import '../../../../cubits/home/home_cubit.dart';

class LogoutBar extends StatefulWidget {
  const LogoutBar({super.key, required this.four});

  final GlobalKey four;

  @override
  State<LogoutBar> createState() => _LogoutBarState();
}

class _LogoutBarState extends State<LogoutBar> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      buildWhen: (previous, current) => previous.status != current.status,
      builder: (_, state) {
        switch (state.status) {
          case HomeStatus.loading:
            return const Center(child: CupertinoActivityIndicator());
          case HomeStatus.success:
            return Showcase(
                key: widget.four,
                disableMovingAnimation: true,
                title: 'Cierra sesión',
                description: 'Adios vaquero 😢😢😢',
                child: GestureDetector(
                  onLongPress: () =>
                      BlocProvider.of<HomeCubit>(context).forceLogout(),
                  onTap: () => BlocProvider.of<HomeCubit>(context).logout(),
                  child: const Icon(Icons.logout),
                ));
          case HomeStatus.failure:
            return Showcase(
                key: widget.four,
                disableMovingAnimation: true,
                title: 'Cierra sesión',
                description: 'Adios vaquero 😢😢😢',
                child: GestureDetector(
                  onLongPress: () =>
                      BlocProvider.of<HomeCubit>(context).forceLogout(),
                  onTap: () => BlocProvider.of<HomeCubit>(context).logout(),
                  child: const Icon(Icons.logout),
                ));
          default:
            return const SizedBox();
        }
      },
    );
  }
}
