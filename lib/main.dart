import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zona_gris_mobile/app/router_provider.dart';
import 'package:zona_gris_mobile/features/cocedores/providers/cocedores_providers.dart';
import 'package:zona_gris_mobile/features/cocedores/providers/registro_provider.dart';
import 'package:zona_gris_mobile/features/cocedores/providers/validacion_provider.dart';
import 'package:zona_gris_mobile/shared/providers/session_provider.dart';

import 'app/app.dart';
import 'auth/providers/auth_provider.dart';

final navigatorKey = GlobalKey<NavigatorState>();
final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => SessionProvider()),
        ChangeNotifierProvider(create: (_) => RouterProvider()),
        ChangeNotifierProvider(create: (_) => CocedoresProvider()),
        ChangeNotifierProvider(create: (_) => RegistroProvider()),
        ChangeNotifierProvider(create: (_) => ValidacionProvider()),
      ],
      child: ZonaGrisApp(
        navigatorKey: navigatorKey,
        scaffoldMessengerKey: scaffoldMessengerKey,
      ),
    ),
  );
}
