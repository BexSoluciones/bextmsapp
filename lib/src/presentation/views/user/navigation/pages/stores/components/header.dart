import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
//providers
import '../../../../../../providers/general_provider.dart';

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
                Consumer<GeneralProvider>(
                  builder: (context, state, _) =>
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
          Consumer<GeneralProvider>(
            builder: (context, state, _) => IconButton(
              icon: const Icon(Icons.cancel),
              tooltip: 'Disable Caching',
              onPressed: state.currentStore == null
                  ? null
                  : () {
                      state.currentStore = null;
                      Provider.of<GeneralProvider>(context).resetMap();
                    },
            ),
          ),
        ],
      );
}
