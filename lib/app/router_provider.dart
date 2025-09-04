import 'package:flutter/material.dart';

enum AppRoute { login, home, cocedores, registroCocedor, validacionCocedor }

class RouterProvider extends ChangeNotifier {
  AppRoute _route = AppRoute.login;

  AppRoute get route => _route;

  void goTo(AppRoute newRoute) {
    _route = newRoute;
    notifyListeners();
  }

  void reset() {
    _route = AppRoute.login;
    notifyListeners();
  }
}
