import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zona_gris_mobile/app/app_session_watcher.dart';
import 'package:zona_gris_mobile/app/inactivity.dart';
import 'package:zona_gris_mobile/app/router_provider.dart';
import 'package:zona_gris_mobile/features/cocedores/screens/cocedores_page.dart';
import 'package:zona_gris_mobile/features/cocedores/screens/registro_form.dart';
import 'package:zona_gris_mobile/features/cocedores/screens/validacion_page.dart';
import 'package:zona_gris_mobile/features/home/screens/landing_screen.dart';
import '../auth/screens/login_screen.dart';

const primaryColor = Color(0xFF3498DB);
const primaryLight = Color(0xFFEBF5FB);

class ZonaGrisApp extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey;
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey;
  const ZonaGrisApp({
    super.key,
    required this.navigatorKey,
    required this.scaffoldMessengerKey,
  });

  @override
  Widget build(BuildContext context) {
    final router = Provider.of<RouterProvider>(context);
    Widget screen;

    switch (router.route) {
      case AppRoute.login:
        screen = const LoginScreen();
        break;
      case AppRoute.home:
        screen = const LandingScreen();
        break;
      case AppRoute.cocedores:
        screen = const CocedorSelectionScreen();
        break;
      case AppRoute.registroCocedor:
        screen = const RegistroCocedorScreen();
        break;
      case AppRoute.validacionCocedor:
        screen = const ValidacionCocedorScreen();
        break;
    }

    return AppSessionWatcher(
      navigatorKey: navigatorKey,
      scaffoldMessengerKey: scaffoldMessengerKey,
      child: MaterialApp(
        navigatorKey: navigatorKey,
        scaffoldMessengerKey: scaffoldMessengerKey,
        title: 'Zona Gris',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: primaryColor,
            primary: primaryColor,
            secondary: primaryLight,
          ),
        ),
        builder: (ctx, child) => InactivityListener(child: child),
        home: screen,
      ),
    );
  }
}
