import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('About')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 16),
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: cs.primaryContainer,
                shape: BoxShape.circle,
              ),
              child:
                  Icon(Icons.wb_sunny_rounded, size: 44, color: cs.primary),
            ),
            const SizedBox(height: 16),
            Text('Space Weather',
                style: theme.textTheme.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text('Version 1.0.0',
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: cs.onSurfaceVariant)),
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Developer',
                        style: theme.textTheme.labelLarge
                            ?.copyWith(color: cs.onSurfaceVariant)),
                    const SizedBox(height: 12),
                    _Row(theme, Icons.person_outline_rounded, 'Name',
                        'Aliyan'),
                    _Row(theme, Icons.school_outlined, 'Institution',
                        'TAMK — Tampere University of Applied Sciences'),
                    _Row(theme, Icons.code_rounded, 'Studio',
                        'Redemption Studio'),
                    _Row(theme, Icons.email_outlined, 'Contact',
                        'aliyan@redemption.studio'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Data sources',
                        style: theme.textTheme.labelLarge
                            ?.copyWith(color: cs.onSurfaceVariant)),
                    const SizedBox(height: 12),
                    _Row(theme, Icons.satellite_alt_outlined, 'Solar flares',
                        'NASA DONKI (CCMC)'),
                    _Row(theme, Icons.circle_outlined, 'Asteroids',
                        'NASA NeoWs (Near Earth Object Web Service)'),
                    const SizedBox(height: 8),
                    Text(
                      'Data provided by NASA\'s Center for Near Earth Object Studies and the Community Coordinated Modeling Center. Not for safety-critical use.',
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: cs.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Built with',
                        style: theme.textTheme.labelLarge
                            ?.copyWith(color: cs.onSurfaceVariant)),
                    const SizedBox(height: 12),
                    _Row(theme, Icons.flutter_dash_rounded, 'Framework',
                        'Flutter 3.x'),
                    _Row(theme, Icons.settings_outlined, 'State management',
                        'Provider'),
                    _Row(theme, Icons.route_outlined, 'Navigation',
                        'go_router'),
                    _Row(theme, Icons.storage_outlined, 'Persistence',
                        'shared_preferences'),
                    _Row(theme, Icons.http_rounded, 'Networking',
                        'http'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              '© 2025 Aliyan / Redemption Studio\nMobile Applications — TAMK',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: cs.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final ThemeData theme;
  final IconData icon;
  final String label;
  final String value;

  const _Row(this.theme, this.icon, this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, size: 16, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 10),
        SizedBox(
          width: 100,
          child: Text(label,
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        ),
        Expanded(
          child: Text(value,
              style: theme.textTheme.bodySmall
                  ?.copyWith(fontWeight: FontWeight.w500)),
        ),
      ]),
    );
  }
}
