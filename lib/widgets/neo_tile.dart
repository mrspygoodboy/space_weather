import 'package:flutter/material.dart';
import '../models/near_earth_object.dart';

class NeoTile extends StatelessWidget {
  final NearEarthObject neo;
  final VoidCallback onTap;

  const NeoTile({super.key, required this.neo, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Asteroid icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: neo.isPotentiallyHazardous
                      ? cs.error.withOpacity(0.1)
                      : cs.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  neo.isPotentiallyHazardous
                      ? Icons.warning_amber_rounded
                      : Icons.circle_outlined,
                  color: neo.isPotentiallyHazardous ? cs.error : cs.primary,
                  size: 26,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            neo.name,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (neo.isPotentiallyHazardous)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: cs.error.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                              border:
                                  Border.all(color: cs.error.withOpacity(0.4)),
                            ),
                            child: Text(
                              'Hazardous',
                              style: TextStyle(
                                fontSize: 11,
                                color: cs.error,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    _InfoRow(
                      icon: Icons.calendar_today_outlined,
                      label: 'Closest approach: ${neo.closeApproachDate}',
                      theme: theme,
                    ),
                    const SizedBox(height: 4),
                    _InfoRow(
                      icon: Icons.straighten_outlined,
                      label:
                          'Diameter: ${neo.estimatedDiameterMinKm.toStringAsFixed(2)}–${neo.estimatedDiameterMaxKm.toStringAsFixed(2)} km',
                      theme: theme,
                    ),
                    const SizedBox(height: 4),
                    _InfoRow(
                      icon: Icons.swap_horiz_rounded,
                      label:
                          'Miss distance: ${(neo.missDistanceKm / 1000).toStringAsFixed(0)}k km',
                      theme: theme,
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded,
                  size: 18, color: cs.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final ThemeData theme;

  const _InfoRow(
      {required this.icon, required this.label, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 13, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
