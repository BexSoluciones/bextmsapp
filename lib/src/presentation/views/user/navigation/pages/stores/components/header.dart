import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

//cubit
import '../../../../../../cubits/general/general_cubit.dart';

class Header extends StatelessWidget {
  const Header({
    super.key,
  });

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Stores',
                ),
                BlocBuilder<GeneralCubit, GeneralState>(
                  builder: (context, state) =>
                      state.currentStore == null
                          ? const Text('Caching Disabled')
                          : Text(
                              'Current Store: ${state.currentStore}',
                              overflow: TextOverflow.fade,
                              softWrap: false,
                            ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 15),
          BlocBuilder<GeneralCubit, GeneralState>(
            builder: (context, state) => IconButton(
              icon: const Icon(Icons.cancel),
              tooltip: 'Disable Caching',
              onPressed: state.currentStore == null
                  ? null
                  : () {
                      state.currentStore = null;
                      BlocProvider.of<GeneralCubit>(context).resetMap();
                    },
            ),
          ),
        ],
      );
}
