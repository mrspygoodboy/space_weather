import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/near_earth_object.dart';

class NeoDetailScreen extends StatelessWidget {
  final NearEarthObject neo;
  const NeoDetailScreen({super.key, required this.neo});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(neo.name, overflow: TextOverflow.ellipsis),
        actions: [
          if (neo.nasaJplUrl.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.open_in_browser_rounded),
              tooltip: 'View on NASA JPL',
              onPressed: () async {
                final uri = Uri.parse(neo.nasaJplUrl);
                if (await canLaunchUrl(uri)) await launchUrl(uri);
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: neo.isPotentiallyHazardous
                            ? cs.errorContainer
                            : cs.primaryContainer,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        neo.isPotentiallyHazardous
                            ? Icons.warning_amber_rounded
                            : Icons.circle_outlined,
                        size: 32,
                        color: neo.isPotentiallyHazardous
                            ? cs.error
                            : cs.primary,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            neo.name,
                            style: theme.textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: neo.isPotentiallyHazardous
                                  ? cs.error.withOpacity(0.12)
                                  : cs.primary.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              neo.isPotentiallyHazardous
                                  ? 'Potentially Hazardous'
                                  : 'Non-Hazardous',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: neo.isPotentiallyHazardous
                                    ? cs.error
                                    : cs.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 8),

            _SectionCard(title: 'Close approach', children: [
              _Row(Icons.calendar_today_outlined, 'Date',
                  neo.closeApproachDate),
              _Row(Icons.public_rounded, 'Orbiting body', neo.orbitingBody),
              _Row(Icons.swap_horiz_rounded, 'Miss distance',
                  '${(neo.missDistanceKm / 1000).toStringAsFixed(0)}k km  (${(neo.missDistanceKm / 384400).toStringAsFixed(2)} lunar dist.)'),
              _Row(Icons.speed_rounded, 'Relative velocity',
                  '${(neo.relativeVelocityKmh / 1000).toStringAsFixed(1)} km/s'),
            ]),

            const SizedBox(height: 8),

            _SectionCard(title: 'Physical properties', children: [
              _Row(Icons.straighten_outlined, 'Min diameter',
                  '${neo.estimatedDiameterMinKm.toStringAsFixed(3)} km'),
              _Row(Icons.straighten_outlined, 'Max diameter',
                  '${neo.estimatedDiameterMaxKm.toStringAsFixed(3)} km'),
              _Row(Icons.radio_button_unchecked_rounded, 'Avg diameter',
                  '${neo.averageDiameterKm.toStringAsFixed(3)} km'),
            ]),

            const SizedBox(height: 16),

            Text('ID: ${neo.id}',
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: cs.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _SectionCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant)),
          const SizedBox(height: 12),
          ...children,
        ]),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _Row(this.icon, this.label, this.value);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, size: 16, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 10),
        SizedBox(
          width: 120,
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
