import 'package:flutter/material.dart';

import '../../data/models/profile.dart';
import '../../services/ai_gateway.dart';
import '../../services/persona_service.dart';
import '../onboarding/questions_page.dart';
import '../../services/trait_service.dart';

class TagSelectPage extends StatefulWidget {
  const TagSelectPage({super.key, required this.profile, required this.onDone});
  final Profile profile;
  final VoidCallback onDone;

  @override
  State<TagSelectPage> createState() => _TagSelectPageState();
}

class _TagSelectPageState extends State<TagSelectPage> {
  final Set<String> _selected = <String>{};
  bool _loading = false;
  final AiGateway _ai = AiGateway();
  final PersonaService _personaService = PersonaService();

  final Map<String, List<String>> _categories = const {
    '沟通偏好': ['安静独处','慢热','直接坦诚','倾听者','共情','理性思考','探索新知'],
    '情绪与安全': ['社恐','焦虑','需要安全感','平静','敏感','自我接纳'],
    '兴趣爱好': ['音乐','艺术','文学','电影','摄影','咖啡','桌游','二次元'],
    '生活方式': ['徒步','露营','跑步','瑜伽','城市漫步','早睡','夜猫子'],
  };

  Future<void> _finish() async {
    if (_selected.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('请选择至少一个标签')));
      return;
    }
    // Go to questions page, then call LLM with both tags and answers
    final answers = await Navigator.of(context).push<List<Map<String, String>>>(
      MaterialPageRoute(
        builder: (_) => QuestionsPage(
          profile: widget.profile,
          onDone: (ans) => Navigator.of(context).pop(ans),
        ),
      ),
    );
    if (answers == null) return;
    setState(() => _loading = true);
    final combined = await _ai.generatePersonaAndTraits(
      userId: widget.profile.userId,
      tags: _selected.toList(),
      answers: answers,
    );
    await _personaService.savePersona(combined.persona);
    await TraitService().saveTraits(combined.traits);
    if (!mounted) return;
    // Success animation + toast message, then finish
    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => const _SuccessDialog(),
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('用户画像以及特质卡片已经生成，请在“我的”标签页进行查看')),
    );
    widget.onDone();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('选择你的标签')),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: _categories.entries.map((entry) {
                return _CategorySection(
                  title: entry.key,
                  tags: entry.value,
                  selected: _selected,
                  onToggle: (t, v) {
                    setState(() {
                      if (v) {
                        _selected.add(t);
                      } else {
                        _selected.remove(t);
                      }
                    });
                  },
                );
              }).toList(),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: FilledButton(
                onPressed: _loading ? null : _finish,
                child: _loading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('完成'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategorySection extends StatelessWidget {
  final String title;
  final List<String> tags;
  final Set<String> selected;
  final void Function(String tag, bool selected) onToggle;

  const _CategorySection({
    required this.title,
    required this.tags,
    required this.selected,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: tags.map((t) {
                final bool isSelected = selected.contains(t);
                return FilterChip(
                  label: Text(t),
                  selected: isSelected,
                  selectedColor: scheme.secondary.withValues(alpha: 0.24),
                  onSelected: (v) => onToggle(t, v),
                  shape: StadiumBorder(side: BorderSide(color: isSelected ? scheme.primary : scheme.outlineVariant)),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _SuccessDialog extends StatefulWidget {
  const _SuccessDialog();

  @override
  State<_SuccessDialog> createState() => _SuccessDialogState();
}

class _SuccessDialogState extends State<_SuccessDialog> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 420));
    _scale = CurvedAnimation(parent: _controller, curve: Curves.easeOutBack);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return ScaleTransition(
      scale: _scale,
      child: AlertDialog(
        title: const Text('生成完成'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle_rounded, color: scheme.primary, size: 56),
            const SizedBox(height: 12),
            const Text('用户画像和特质卡片已生成，前往“我的”查看。'),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('好的')),
        ],
      ),
    );
  }
}


