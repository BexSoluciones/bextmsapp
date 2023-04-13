import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/network/network_bloc.dart';

class IconConnection extends StatelessWidget {
  const IconConnection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NetworkBloc, NetworkState>(
      builder: (context, state) {
        if (state is NetworkFailure) {
          return const Icon(Icons.wifi_off);
        } else if (state is NetworkSuccess) {
          return const Icon(Icons.wifi);
        } else {
          return const Icon(Icons.e_mobiledata);
        }
      },
    );
  }
}
