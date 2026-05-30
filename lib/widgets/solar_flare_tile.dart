import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/solar_flare.dart';
import 'flare_class_badge.dart';

class SolarFlareTile extends StatelessWidget {
  final SolarFlare flare;
  final VoidCallback onTap;

  const SolarFlareTile({
    super.key,
    required this.flare,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final date = flare.beginDateTime;
    final dateStr = date != null
        ? DateFormat('MMM d, yyyy • HH:mm').format(date.toLocal())
        : flare.beginTime;

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Solar icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _iconColor(context).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.wb_sunny_rounded,
                  color: _iconColor(context),
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        FlareClassBadge(
                          flareClass: flare.flareClass,
                          classType: flare.classType,
                        ),
                        if (flare.linkedEventIds.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          Tooltip(
                            message: 'Has linked CME',
                            child: Icon(
                              Icons.link_rounded,
                              size: 16,
                              color: theme.colorScheme.secondary,
                            ),
                          ),
                        ],
                        const Spacer(),
                        Icon(
                          Icons.chevron_right_rounded,
                          size: 18,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      dateStr,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (flare.sourceLocation != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 13,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            flare.sourceLocation!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          if (flare.activeRegionNum != null) ...[
                            const SizedBox(width: 8),
                            Text(
                              'AR ${flare.activeRegionNum}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                    if (flare.note != null && flare.note!.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        flare.note!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _iconColor(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    switch (flare.flareClass) {
      case FlareClass.x:
        return cs.error;
      case FlareClass.m:
        return Colors.orange;
      case FlareClass.c:
        return Colors.amber.shade700;
      case FlareClass.b:
        return cs.primary;
      case FlareClass.unknown:
        return cs.onSurfaceVariant;
    }
  }
}
