import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

//cubits
import '../blocs/splash/splash_bloc.dart';

//constants
import '../../utils/constants/colors.dart';

class SplashScreenWidget extends StatefulWidget {
  const SplashScreenWidget({ super.key });

  @override
  SplashScreenWidgetState createState() => SplashScreenWidgetState();
}

class SplashScreenWidgetState extends State<SplashScreenWidget> {
  @override
  void initState() {
    super.initState();
    _dispatchEvent(context);
  }

  @override
  Widget build(BuildContext context) {
    return  Stack(
      fit: StackFit.expand,
      children: <Widget>[
        Container(),
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Expanded(
              flex: 2,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Image.asset('assets/images/icon.png',
                      width: 400.0, height: 400.0),
                  const CircularProgressIndicator(
                    valueColor:
                    AlwaysStoppedAnimation<Color>(kPrimaryColor),
                  ),
                ],
              ),
            ),
          ],
        )
      ],
    );
  }

  //This method will dispatch the navigateToHomeScreen event.
  void _dispatchEvent(BuildContext context) {
    BlocProvider.of<SplashBloc>(context).add(HandleNavigateEvent());
  }
}