import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

//core
import '../../../../core/helpers/index.dart';

//bloc
import '../../../config/size.dart';
import '../../blocs/splash/splash_bloc.dart';
import '../../widgets/splash_widget.dart';

//services
import '../../../locator.dart';
import '../../../services/navigation.dart';
import '../../../services/storage.dart';

// This the widget where the BLoC states and events are handled.
class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  final helperFunctions = HelperFunctions();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: BlocProvider(
          create: (_) => SplashBloc(
              storageService: locator<LocalStorageService>(),
              navigationService: locator<NavigationService>()),
          child: BlocListener<SplashBloc, SplashState>(
            listener: (context, state) {
              if (state is Loaded) {
                context.read<SplashBloc>().navigationService.goTo(state.route!);
              }
            },
            child: const SplashScreenWidget(),
          ),
        ),
      ),
    );
  }
}
