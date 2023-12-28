import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:showcaseview/showcaseview.dart';

//cubit
import '../../../../cubits/home/home_cubit.dart';

//widgets

import 'search_home_delegate.dart';

class SearchBar extends StatelessWidget {
  const SearchBar({Key? key, required this.three}) : super(key: key);

  final GlobalKey three;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (_, state) {
        switch (state.status) {
          case HomeStatus.loading:
            return const Center(child: CupertinoActivityIndicator());
          case HomeStatus.success:
            return Showcase(
                key: three,
                disableMovingAnimation: true,
                title: 'Busqueda!',
                description:
                    'Encuentra al cliente que necesitas tanto por nombre, por nit, por dirección o por facturas',
                child: IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () {
                      showSearch(
                          context: context,
                          delegate: SearchHomeDelegate(state.works));
                    }));
          case HomeStatus.failure:
            return Showcase(
                key: three,
                disableMovingAnimation: true,
                title: 'Busqueda!',
                description:
                'Encuentra al cliente que necesitas tanto por nombre, por nit, por dirección o por facturas',
                child: IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () {
                      showSearch(
                          context: context,
                          delegate: SearchHomeDelegate(state.works));
                    }));
          default:
            return const SizedBox();
        }
      },
    );
  }
}
