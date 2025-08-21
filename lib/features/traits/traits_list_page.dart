import 'package:flutter/material.dart';

import '../../services/trait_service.dart';
import '../../data/models/trait.dart';
import 'traits_detail_page.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('我的特质')),
      body: _traits.isEmpty
          ? const Center(child: Text('暂无特质，请完成标签和问答生成画像'))
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 3 / 4.2,
              ),
              itemCount: _traits.length,
              itemBuilder: (context, idx) {
                final t = _traits[idx];
                return _TraitCard(trait: t);
              },
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
    return InkWell(
      onTap: () => Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => TraitsDetailPage(trait: trait))),
      borderRadius: BorderRadius.circular(16),
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover image (placeholder gradient)
            Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    scheme.primary.withValues(alpha: 0.85),
                    scheme.secondary.withValues(alpha: 0.85),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              alignment: Alignment.bottomLeft,
              padding: const EdgeInsets.all(12),
              child: Text(
                trait.title,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(color: scheme.onPrimary),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                trait.description,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
