import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/network/network_bloc.dart';

class IconConnection extends StatelessWidget {
  const IconConnection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NetworkBloc, NetworkState>(
      buildWhen: (previous, current) => previous != current,
      builder: (context, state) {
        if (state is NetworkFailure) {
          return Icon(Icons.wifi_off,
              color: Theme.of(context).colorScheme.primary);
        } else if (state is NetworkSuccess) {
          return Icon(Icons.wifi,
              color: Theme.of(context).colorScheme.primary);
        } else {
          return Icon(Icons.e_mobiledata,
              color: Theme.of(context).colorScheme.primary);
        }
      },
    );
  }
}
