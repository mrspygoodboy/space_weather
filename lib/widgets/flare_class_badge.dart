import 'package:flutter/material.dart';
import '../models/solar_flare.dart';

class FlareClassBadge extends StatelessWidget {
  final FlareClass flareClass;
  final String classType;
  final double size;

  const FlareClassBadge({
    super.key,
    required this.flareClass,
    required this.classType,
    this.size = 14,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _color(context).withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _color(context).withOpacity(0.4)),
      ),
      child: Text(
        classType,
        style: TextStyle(
          fontSize: size,
          fontWeight: FontWeight.w700,
          color: _color(context),
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Color _color(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
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
