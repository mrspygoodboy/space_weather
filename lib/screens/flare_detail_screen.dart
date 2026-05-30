import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/solar_flare.dart';
import '../widgets/flare_class_badge.dart';

class FlareDetailScreen extends StatelessWidget {
  final SolarFlare flare;
  const FlareDetailScreen({super.key, required this.flare});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('Flare ${flare.classType}'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.wb_sunny_rounded,
                            size: 32, color: _severityColor(cs)),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            FlareClassBadge(
                              flareClass: flare.flareClass,
                              classType: flare.classType,
                              size: 18,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _severityLabel(),
                              style: theme.textTheme.bodySmall
                                  ?.copyWith(color: cs.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _SeverityBar(flareClass: flare.flareClass),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 8),

            // Timing
            _SectionCard(
              title: 'Event timing',
              children: [
                _DetailRow(
                  icon: Icons.play_arrow_rounded,
                  label: 'Begin',
                  value: _formatDate(flare.beginDateTime) ?? flare.beginTime,
                ),
                if (flare.peakDateTime != null)
                  _DetailRow(
                    icon: Icons.flash_on_rounded,
                    label: 'Peak',
                    value: _formatDate(flare.peakDateTime)!,
                  ),
                if (flare.endTime != null)
                  _DetailRow(
                    icon: Icons.stop_rounded,
                    label: 'End',
                    value: _formatDate(DateTime.tryParse(flare.endTime!)) ??
                        flare.endTime!,
                  ),
                if (flare.peakDateTime != null && flare.beginDateTime != null)
                  _DetailRow(
                    icon: Icons.timer_outlined,
                    label: 'Duration to peak',
                    value: _duration(
                        flare.beginDateTime!, flare.peakDateTime!),
                  ),
              ],
            ),

            const SizedBox(height: 8),

            // Location
            if (flare.sourceLocation != null || flare.activeRegionNum != null)
              _SectionCard(
                title: 'Source location',
                children: [
                  if (flare.sourceLocation != null)
                    _DetailRow(
                      icon: Icons.location_on_outlined,
                      label: 'Heliographic position',
                      value: flare.sourceLocation!,
                    ),
                  if (flare.activeRegionNum != null)
                    _DetailRow(
                      icon: Icons.blur_circular_rounded,
                      label: 'Active region',
                      value: 'AR ${flare.activeRegionNum}',
                    ),
                ],
              ),

            const SizedBox(height: 8),

            // Notes
            if (flare.note != null && flare.note!.isNotEmpty)
              _SectionCard(
                title: 'Notes',
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(flare.note!,
                        style: theme.textTheme.bodyMedium),
                  ),
                ],
              ),

            const SizedBox(height: 8),

            // Linked events
            if (flare.linkedEventIds.isNotEmpty)
              _SectionCard(
                title: 'Linked events',
                children: flare.linkedEventIds
                    .map((id) => _DetailRow(
                          icon: Icons.link_rounded,
                          label: 'Event',
                          value: id,
                        ))
                    .toList(),
              ),

            const SizedBox(height: 24),

            // ID footer
            Text(
              'Event ID: ${flare.id}',
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: cs.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }

  Color _severityColor(ColorScheme cs) {
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

  String _severityLabel() {
    switch (flare.flareClass) {
      case FlareClass.x:
        return 'Extreme — R3–R5 radio blackout possible';
      case FlareClass.m:
        return 'Major — R1–R2 radio blackout possible';
      case FlareClass.c:
        return 'Moderate — minor impacts at high latitudes';
      case FlareClass.b:
        return 'Minor — rarely causes noticeable effects';
      case FlareClass.unknown:
        return 'Classification unknown';
    }
  }

  String? _formatDate(DateTime? dt) {
    if (dt == null) return null;
    return DateFormat('MMM d, yyyy • HH:mm UTC').format(dt.toUtc());
  }

  String _duration(DateTime from, DateTime to) {
    final diff = to.difference(from);
    if (diff.inHours > 0) {
      return '${diff.inHours}h ${diff.inMinutes.remainder(60)}m';
    }
    return '${diff.inMinutes}m';
  }
}

class _SeverityBar extends StatelessWidget {
  final FlareClass flareClass;
  const _SeverityBar({required this.flareClass});

  @override
  Widget build(BuildContext context) {
    final severity = flareClass.severity;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Severity',
            style: Theme.of(context)
                .textTheme
                .labelSmall
                ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: severity / 4,
            minHeight: 8,
            backgroundColor:
                Theme.of(context).colorScheme.surfaceContainerHighest,
            color: _barColor(Theme.of(context).colorScheme),
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text('B', style: TextStyle(fontSize: 11)),
            Text('C', style: TextStyle(fontSize: 11)),
            Text('M', style: TextStyle(fontSize: 11)),
            Text('X', style: TextStyle(fontSize: 11)),
          ],
        ),
      ],
    );
  }

  Color _barColor(ColorScheme cs) {
    switch (flareClass) {
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

class _SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SectionCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: Theme.of(context)
                    .textTheme
                    .labelLarge
                    ?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant)),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon,
              size: 16,
              color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 10),
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
          ),
          Expanded(
            child: Text(value,
                style: theme.textTheme.bodySmall
                    ?.copyWith(fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}
