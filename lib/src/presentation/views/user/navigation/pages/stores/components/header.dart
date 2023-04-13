import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../shared/state/general_provider.dart';

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
                  builder: (context, provider, _) =>
                      provider.currentStore == null
                          ? const Text('Caching Disabled')
                          : Text(
                              'Current Store: ${provider.currentStore}',
                              overflow: TextOverflow.fade,
                              softWrap: false,
                            ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 15),
          Consumer<GeneralProvider>(
            child: const Icon(Icons.cancel),
            builder: (context, provider, child) => IconButton(
              icon: child!,
              tooltip: 'Disable Caching',
              onPressed: provider.currentStore == null
                  ? null
                  : () {
                      provider
                        ..currentStore = null
                        ..resetMap();
                    },
            ),
          ),
        ],
      );
}
