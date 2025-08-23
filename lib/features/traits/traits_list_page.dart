import 'package:flutter/material.dart';

import '../../services/trait_service.dart';
import '../../data/models/trait.dart';
import 'traits_detail_page.dart';
import '../../data/models/profile.dart';
import '../../services/profile_service.dart';
import '../onboarding/tag_select_page.dart';

class TraitsListPage extends StatefulWidget {
  const TraitsListPage({super.key});

  @override
  State<TraitsListPage> createState() => _TraitsListPageState();
}

class _TraitsListPageState extends State<TraitsListPage> {
  List<UserTrait> _traits = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final list = await TraitService().loadTraits();
    if (!mounted) return;
    setState(() => _traits = list);
  }

  Future<void> _startOnboarding() async {
    final profileSvc = ProfileService();
    Profile? profile = await profileSvc.loadProfile();
    if (profile == null) {
      profile = profileSvc.generateAnonymous();
      await profileSvc.saveProfile(profile);
    }
    if (!mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TagSelectPage(
          profile: profile!,
          onDone: () async {
            // After AI generation completes, reload traits
            await _load();
            if (mounted) Navigator.of(context).pop();
          },
        ),
      ),
    );
    if (mounted) {
      await _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('我的特质'),
        actions: [
          IconButton(
            tooltip: '刷新',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _load,
          ),
          IconButton(
            tooltip: '重新生成（AI）',
            icon: const Icon(Icons.auto_awesome_rounded),
            onPressed: () async {
              await TraitService().clearTraits();
              if (!mounted) return;
              await _startOnboarding();
            },
          ),
        ],
      ),
      body: _traits.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('暂无特质卡片\n请选择标签并回答问题，由AI为你生成画像与特质。', textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: _startOnboarding,
                      icon: const Icon(Icons.auto_awesome_rounded),
                      label: const Text('去生成我的特质'),
                    ),
                  ],
                ),
              ),
            )
          : RefreshIndicator(
              onRefresh: _load,
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  mainAxisExtent: 280,
                ),
                itemCount: _traits.length,
                itemBuilder: (context, idx) {
                  final t = _traits[idx];
                  return _TraitCard(trait: t);
                },
              ),
            ),
    );
  }
}

class _TraitCard extends StatelessWidget {
  final UserTrait trait;
  const _TraitCard({required this.trait});

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    // derive a stable index from id to vary visuals
    final int seed = trait.id.hashCode.abs();
    final _CoverStyle cover = _coverFromSeed(scheme, seed);
    return InkWell(
      onTap: () => Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => TraitsDetailPage(trait: trait))),
      borderRadius: BorderRadius.circular(16),
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 2,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover area with gradient + subtle decorations
            SizedBox(
              height: 108,
              width: double.infinity,
              child: Stack(
                children: [
                  // gradient background
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: cover.colors,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                  // decorative circles
                  Positioned(
                    right: -20,
                    top: -10,
                    child: _bubble(
                      70,
                      cover.decoration.withValues(alpha: 0.14),
                    ),
                  ),
                  Positioned(
                    left: -10,
                    bottom: -15,
                    child: _bubble(
                      56,
                      cover.decoration.withValues(alpha: 0.12),
                    ),
                  ),
                  // title + icon
                  Positioned(
                    left: 12,
                    right: 12,
                    bottom: 12,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Icon(
                          cover.icon,
                          color: cover.onColor.withValues(alpha: 0.9),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            trait.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  color: cover.onColor,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
              child: Text(
                trait.description,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // metrics footer: replace repetitive tags with compact visual indicators
            // keep content compact; no extra bottom spacer to avoid overflow
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _metricPill(
                    context,
                    icon: Icons.bolt_rounded,
                    label: '强度',
                    value: _metricValueFromSeed(seed, 62, 95),
                  ),
                  _metricPill(
                    context,
                    icon: Icons.wb_sunny_rounded,
                    label: '温暖',
                    value: _metricValueFromSeed(seed + 7, 60, 92),
                  ),
                  _metricPill(
                    context,
                    icon: Icons.shield_moon_rounded,
                    label: '稳定',
                    value: _metricValueFromSeed(seed + 13, 58, 90),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 2),
          ],
        ),
      ),
    );
  }
}

class _CoverStyle {
  final List<Color> colors;
  final Color onColor;
  final Color decoration;
  final IconData icon;
  const _CoverStyle(this.colors, this.onColor, this.decoration, this.icon);
}

_CoverStyle _coverFromSeed(ColorScheme scheme, int seed) {
  final variants = <_CoverStyle>[
    _CoverStyle(
      [
        scheme.primary.withValues(alpha: 0.92),
        scheme.secondary.withValues(alpha: 0.85),
      ],
      scheme.onPrimary,
      scheme.tertiary,
      Icons.local_fire_department_rounded,
    ),
    _CoverStyle(
      [
        Color.lerp(scheme.primary, scheme.tertiary, 0.3)!,
        Color.lerp(scheme.secondary, scheme.primary, 0.2)!,
      ],
      scheme.onPrimary,
      scheme.primary,
      Icons.auto_awesome_rounded,
    ),
    _CoverStyle(
      [
        scheme.secondary.withValues(alpha: 0.9),
        scheme.tertiary.withValues(alpha: 0.9),
      ],
      scheme.onSecondary,
      scheme.secondary,
      Icons.stars_rounded,
    ),
    _CoverStyle(
      [
        const Color(0xFF6EE7F2).withValues(alpha: 0.9),
        const Color(0xFFA78BFA).withValues(alpha: 0.9),
      ],
      Colors.white,
      const Color(0xFFF472B6),
      Icons.favorite_rounded,
    ),
  ];
  return variants[seed % variants.length];
}

Widget _bubble(double size, Color color) {
  return Container(
    width: size,
    height: size,
    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
  );
}

Widget _metricPill(
  BuildContext context, {
  required IconData icon,
  required String label,
  required int value,
}) {
  final ColorScheme scheme = Theme.of(context).colorScheme;
  return Container(
    padding: const EdgeInsets.symmetric(
      horizontal: 6,
      vertical: 5,
    ), // Compact metric pill padding
    decoration: ShapeDecoration(
      color: scheme.surfaceContainerHighest,
      shape: const StadiumBorder(),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: scheme.primary),
        const SizedBox(width: 4),
        Text('$label $value%', style: Theme.of(context).textTheme.labelSmall),
      ],
    ),
  );
}

int _metricValueFromSeed(int seed, int min, int max) {
  final int span = (max - min).clamp(1, 100);
  final int v = min + (seed % (span + 1));
  return v.clamp(0, 100);
}
