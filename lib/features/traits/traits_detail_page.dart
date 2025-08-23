import 'dart:ui';
import 'package:flutter/material.dart';

import '../../data/models/trait.dart';

class TraitsDetailPage extends StatelessWidget {
  final UserTrait trait;
  const TraitsDetailPage({super.key, required this.trait});

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final int seed = trait.id.hashCode.abs();
    final _DopaStyle style = _dopaFromSeed(scheme, seed);
    return Scaffold(
      appBar: AppBar(title: Text(trait.title)),
      body: Stack(
        children: [
          // Background dopamine blobs
          Positioned(
            top: -60,
            left: -40,
            child: _blob(220, style.bgA.withValues(alpha: 0.35)),
          ),
          Positioned(
            bottom: -80,
            right: -30,
            child: _blob(260, style.bgB.withValues(alpha: 0.28)),
          ),
          Positioned(
            top: 180,
            right: -70,
            child: _blob(180, style.bgC.withValues(alpha: 0.25)),
          ),
          // Scrollable content with a big card
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: _DopaCard(
                style: style,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [style.primary, style.secondary],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: Icon(style.icon, color: Colors.white),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            trait.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      trait.description,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 16),
                    // metrics row
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        _metricPill(context, icon: Icons.bolt_rounded, label: '强度', value: _metric(seed, 65, 95)),
                        _metricPill(context, icon: Icons.wb_sunny_rounded, label: '温暖', value: _metric(seed + 7, 60, 92)),
                        _metricPill(context, icon: Icons.shield_moon_rounded, label: '稳定', value: _metric(seed + 13, 58, 90)),
                      ],
                    ),
                    if (trait.evidenceTags.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      Text('相关标签', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: trait.evidenceTags.map((t) => Chip(label: Text(t))).toList(),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DopaCard extends StatelessWidget {
  const _DopaCard({required this.child, required this.style});
  final Widget child;
  final _DopaStyle style;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    // Outer gradient border
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [style.primary, style.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Container(
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: scheme.surface.withValues(alpha: 0.94),
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(color: style.primary.withValues(alpha: 0.15), blurRadius: 20, offset: const Offset(0, 10)),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

class _DopaStyle {
  final Color primary;
  final Color secondary;
  final Color bgA;
  final Color bgB;
  final Color bgC;
  final IconData icon;
  const _DopaStyle({
    required this.primary,
    required this.secondary,
    required this.bgA,
    required this.bgB,
    required this.bgC,
    required this.icon,
  });
}

_DopaStyle _dopaFromSeed(ColorScheme scheme, int seed) {
  final variants = <_DopaStyle>[
    _DopaStyle(
      primary: const Color(0xFFFF6B6B), // coral red
      secondary: const Color(0xFFFFCA3A), // mango
      bgA: const Color(0xFF845EC2),
      bgB: const Color(0xFF2C73D2),
      bgC: const Color(0xFF00C9A7),
      icon: Icons.auto_awesome_rounded,
    ),
    _DopaStyle(
      primary: const Color(0xFF60DB89), // neon green
      secondary: const Color(0xFF58C7F3), // cyan
      bgA: const Color(0xFFF9A8D4),
      bgB: const Color(0xFFA78BFA),
      bgC: const Color(0xFFFCA5A5),
      icon: Icons.local_fire_department_rounded,
    ),
    _DopaStyle(
      primary: const Color(0xFFFB7185), // pink
      secondary: const Color(0xFFF59E0B), // amber
      bgA: const Color(0xFF34D399),
      bgB: const Color(0xFF60A5FA),
      bgC: const Color(0xFFFECACA),
      icon: Icons.stars_rounded,
    ),
  ];
  return variants[seed % variants.length];
}

Widget _blob(double size, Color color) {
  return Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      gradient: RadialGradient(
        colors: [color, color.withValues(alpha: 0.0)],
        stops: const [0.2, 1.0],
      ),
    ),
  );
}

int _metric(int seed, int min, int max) {
  final int span = (max - min).clamp(1, 100);
  return (min + (seed % (span + 1))).clamp(0, 100);
}

Widget _metricPill(BuildContext context, {required IconData icon, required String label, required int value}) {
  final ColorScheme scheme = Theme.of(context).colorScheme;
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
    decoration: ShapeDecoration(
      color: scheme.surfaceContainerHighest,
      shape: const StadiumBorder(),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: scheme.primary),
        const SizedBox(width: 6),
        Text('$label $value%', style: Theme.of(context).textTheme.labelSmall),
      ],
    ),
  );
}
