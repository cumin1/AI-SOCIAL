import 'package:flutter/material.dart';

import '../../data/models/profile.dart';

class QuestionsPage extends StatefulWidget {
  const QuestionsPage({super.key, required this.profile, required this.onDone});
  final Profile profile;
  final void Function(List<Map<String, String>> answers) onDone;

  @override
  State<QuestionsPage> createState() => _QuestionsPageState();
}

class _QuestionsPageState extends State<QuestionsPage> {
  final List<_Q> _qs = const [
    _Q('当你和陌生人开始聊天时，你更希望对方先聊什么？'),
    _Q('你最近一次真正感到被理解，发生在什么场景？'),
    _Q('在交流中，你更看重“真实表达”还是“彼此舒适”？为什么？'),
    _Q('如果对话变得尴尬，你通常会怎么做来让彼此放松？'),
    _Q('什么样的交流让你感觉安全、愿意多说一点？'),
    _Q('你理想的一次线下相遇是什么样的？地点/氛围/做什么？'),
    _Q('别人身上的哪些特质会让你想更了解Ta？'),
    _Q('你更容易被哪类问题打开话匣子？（如：童年回忆/近期小确幸/价值观…）'),
    _Q('当情绪低落时，你更需要倾听、建议还是陪伴？'),
    _Q('回想一次让你成长的关系，它给了你什么支持？'),
  ];
  final Map<int, TextEditingController> _controllers = {};

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _submit() {
    final List<Map<String, String>> answers = [];
    for (int i = 0; i < _qs.length; i++) {
      final String a = _controllers[i]?.text.trim() ?? '';
      answers.add({'q': _qs[i].text, 'a': a});
    }
    widget.onDone(answers);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('回答几个问题')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _qs.length + 1,
        itemBuilder: (context, idx) {
          if (idx == _qs.length) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(top: 12),
                child: FilledButton(onPressed: _submit, child: const Text('完成')),
              ),
            );
          }
          final _Q q = _qs[idx];
          final ctrl = _controllers.putIfAbsent(idx, () => TextEditingController());
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(q.text, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  TextField(
                    controller: ctrl,
                    minLines: 2,
                    maxLines: 6,
                    decoration: const InputDecoration(hintText: '写下你的想法…'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _Q {
  final String text;
  const _Q(this.text);
}


