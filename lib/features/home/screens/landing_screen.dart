import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zona_gris_mobile/auth/providers/auth_provider.dart';
import 'package:zona_gris_mobile/app/router_provider.dart';
import 'package:zona_gris_mobile/shared/widgets/card_option.dart';
import 'package:zona_gris_mobile/shared/widgets/header.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:zona_gris_mobile/shared/widgets/session_timer.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;

    final Map<String, List<Widget> Function(BuildContext)> perfilCards = {
      'operador zona gris': (context) => [
        cardOption(
          context,
          icon: FontAwesomeIcons.fire,
          title: 'Registro Hora X Hora Cocedor',
          subtitle: 'Captura de parámetros de cocedores',
          color: const Color.fromARGB(255, 192, 153, 47),
          iconBg: const Color.fromARGB(
            255,
            192,
            153,
            47,
          ).withValues(alpha: 0.15),
          onTap: () => context.read<RouterProvider>().goTo(AppRoute.cocedores),
        ),
      ],
      'supervisor extraccion': (context) => [
        cardOption(
          context,
          icon: FontAwesomeIcons.fire,
          title: 'Validar Cocedores',
          subtitle: 'Validar parámetros de cocedores',
          color: const Color.fromARGB(255, 192, 153, 47),
          iconBg: const Color.fromARGB(
            255,
            192,
            153,
            47,
          ).withValues(alpha: 0.15),
          onTap: () => context.read<RouterProvider>().goTo(AppRoute.cocedores),
        ),
      ],
    };

    List<Widget> buildCardsForUser(
      BuildContext context,
      List<String> perfiles,
    ) {
      if (perfiles.map((p) => p.toLowerCase()).contains('admin')) {
        return perfilCards.values.expand((b) => b(context)).toList();
      }
      return perfiles
          .map((p) => p.toLowerCase())
          .where(perfilCards.containsKey)
          .expand((p) => perfilCards[p]!(context))
          .toList();
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {},
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Zona Gris',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
          ),
          centerTitle: true,
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
          elevation: 4,
          actions: [
            const SessionTimer(),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Cerrar sesión',
              onPressed: () {
                auth.logout();
                context.read<RouterProvider>().reset();
              },
            ),
          ],
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Theme.of(context).colorScheme.secondary,
                const Color(0xFFE8F4FF),
              ],
              stops: const [0.0, 0.5],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                Header(
                  nombre: user?.usuarioNombre ?? '',
                  primaryColor: Theme.of(context).colorScheme.primary,
                  primaryLight: Theme.of(context).colorScheme.primary,
                  icon: Icon(
                    Icons.person,
                    size: 28,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  title: '¡Hola, ${user?.usuarioNombre}!',
                  subtitle: 'Bienvenido al sistema de zona gris',
                ),
                const SizedBox(height: 28),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Text(
                    '¿Qué deseas hacer?',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey[800],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: GridView(
                      padding: const EdgeInsets.only(bottom: 20),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 16,
                            crossAxisSpacing: 16,
                            childAspectRatio: 0.85,
                          ),
                      children: buildCardsForUser(context, [
                        if (user?.perfil != null) user!.perfil,
                      ]),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
