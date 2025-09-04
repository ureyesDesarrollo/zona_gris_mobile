import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zona_gris_mobile/app/router_provider.dart';
import 'package:zona_gris_mobile/auth/providers/auth_provider.dart';
import 'package:zona_gris_mobile/shared/providers/session_provider.dart';

class AppSessionWatcher extends StatefulWidget {
  final Widget child;
  final GlobalKey<NavigatorState> navigatorKey;
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey;
  const AppSessionWatcher({
    super.key,
    required this.child,
    required this.navigatorKey,
    required this.scaffoldMessengerKey,
  });

  @override
  State<AppSessionWatcher> createState() => _AppSessionWatcherState();
}

class _AppSessionWatcherState extends State<AppSessionWatcher> {
  bool _started = false;

  void _onExpire() {
    // No dependas de un BuildContext de una pantalla que pudo haber sido destruida
    widget.scaffoldMessengerKey.currentState?.showSnackBar(
      const SnackBar(content: Text('Sesión cerrada por inactividad')),
    );
    context.read<AuthProvider>().logout();
    context.read<RouterProvider>().goTo(AppRoute.login);
    // (opc) también puedes limpiar el stack de navegación real si usas rutas nativas:
    // widget.navigatorKey.currentState?.pushNamedAndRemoveUntil('/login', (_) => false);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final isLoggedIn = context.watch<AuthProvider>().isLoggedIn;
    final currentRoute = context.watch<RouterProvider>().route;
    final session = context.read<SessionProvider>();

    final onLoginArea = isLoggedIn && currentRoute != AppRoute.login;

    if (onLoginArea && !_started) {
      session.startSession(_onExpire); // ✅ arranca una vez
      _started = true;
    } else if ((!onLoginArea || !isLoggedIn) && _started) {
      session.cancelSession(); // ✅ detiene al salir / ir a login
      _started = false;
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
