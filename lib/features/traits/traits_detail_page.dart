import 'package:flutter/material.dart';

import '../../data/models/trait.dart';

class TraitsDetailPage extends StatelessWidget {
  final UserTrait trait;
  const TraitsDetailPage({super.key, required this.trait});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(trait.title)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(trait.title, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 12),
            Text(trait.description),
            if (trait.evidenceTags.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text('相关标签', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: trait.evidenceTags.map((t) => Chip(label: Text(t))).toList(),
              ),
            ]
          ],
        ),
      ),
    );
  }
}


