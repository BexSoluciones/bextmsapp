import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:showcaseview/showcaseview.dart';

//cubit
import '../../../../cubits/home/home_cubit.dart';

class LogoutBar extends StatefulWidget {
  const LogoutBar({Key? key, required this.four}) : super(key: key);

  final GlobalKey four;

  @override
  State<LogoutBar> createState() => _LogoutBarState();
}

class _LogoutBarState extends State<LogoutBar> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
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
                child: IconButton(
                    icon: const Icon(Icons.logout),
                    onPressed: () async {
                      BlocProvider.of<HomeCubit>(context).logout();
                    }));
          case HomeStatus.failure:
            return Showcase(
                key: widget.four,
                disableMovingAnimation: true,
                title: 'Cierra sesión',
                description: 'Adios vaquero 😢😢😢',
                child: IconButton(
                    icon: const Icon(Icons.logout),
                    onPressed: () async {
                      BlocProvider.of<HomeCubit>(context).logout();
                    }));
          default:
            return const SizedBox();
        }
      },
    );
  }
}
