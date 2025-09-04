import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zona_gris_mobile/shared/providers/session_provider.dart';

class InactivityListener extends StatelessWidget {
  final Widget? child;
  const InactivityListener({super.key, this.child});

  @override
  Widget build(BuildContext context) {
    final session = context.read<SessionProvider>();
    return Listener(
      onPointerDown: (_) => session.resetSession(
        () {},
      ), // si tu SessionProvider recuerda el callback, basta: session.resetSession();
      child: Focus(
        onKeyEvent: (node, event) {
          session.resetSession(() {});
          return KeyEventResult.ignored;
        },
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () => session.resetSession(() {}),
          child: child,
        ),
      ),
    );
  }
}
