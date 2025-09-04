import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/session_provider.dart';

class SessionTimer extends StatelessWidget {
  const SessionTimer({super.key});

  @override
  Widget build(BuildContext context) {
    final tiempo = context.watch<SessionProvider>().remainingFormatted;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.indigo.shade100.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.timer, size: 18),
          const SizedBox(width: 6),
          Text('Sesión: $tiempo', style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }
}
