import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

//core
import '../../../../core/helpers/index.dart';

//bloc
import '../../blocs/splash/splash_bloc.dart';
import '../../widgets/splash_widget.dart';

//services
import '../../../locator.dart';
import '../../../services/navigation.dart';


final NavigationService _navigationService = locator<NavigationService>();

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
    Future.delayed(Duration.zero, () => helperFunctions.versionCheck(context));
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
          body: SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: BlocProvider(
              create: (_) => SplashScreenBloc(),
              child: BlocListener<SplashScreenBloc, SplashScreenState>(
                listener: (context, state) {
                  if (state is Loaded) {
                    _navigationService.goTo(state.route!);
                  }
                },
                child: const SplashScreenWidget(),
              ),
            ),
          ),
        );
  }
}
