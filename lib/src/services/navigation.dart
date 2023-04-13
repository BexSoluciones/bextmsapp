import 'package:flutter/material.dart';

class NavigationService {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  Future<dynamic> goTo(String routeName, {dynamic arguments}) {
    return navigatorKey.currentState!
        .pushNamed(routeName, arguments: arguments);
  }

  Future<dynamic> replaceTo(String routeName, {dynamic arguments}) {
    return navigatorKey.currentState!.pushNamedAndRemoveUntil(
        routeName, (route) => false,
        arguments: arguments);
  }

  void goBack() {
    return navigatorKey.currentState!.pop(true);
  }
}
