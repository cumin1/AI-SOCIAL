import 'package:flutter/material.dart';

import 'widgets/message_bubble.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();
  final List<_Msg> _messages = <_Msg>[];
  String? _currentMood; // current mood tag for next message

  final List<String> _moods = const ['🙂 放松', '🤝 信任', '🫶 共情', '🤔 思考', '😌 平静', '😟 焦虑'];

  void _send() {
    final String text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add(_Msg(text: text, mine: true, mood: _currentMood));
      _controller.clear();
      // Simulate slow/soft reply
      Future<void>.delayed(const Duration(milliseconds: 600), () {
        if (!mounted) return;
        setState(() {
          _messages.add(_Msg(text: '收到啦，我在听你说。', mine: false));
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('聊天'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final _Msg m = _messages[index];
                return MessageBubble(
                  text: m.text,
                  isMine: m.mine,
                  moodLabel: m.mood,
                );
              },
            ),
          ),
          _Composer(
            controller: _controller,
            onSend: _send,
            moods: _moods,
            onMoodSelected: (m) => setState(() => _currentMood = m),
            currentMood: _currentMood,
          ),
        ],
      ),
    );
  }
}

class _Composer extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final List<String> moods;
  final String? currentMood;
  final ValueChanged<String?> onMoodSelected;

  const _Composer({
    required this.controller,
    required this.onSend,
    required this.moods,
    required this.onMoodSelected,
    required this.currentMood,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
        child: Row(
          children: [
            PopupMenuButton<String>(
              tooltip: '心情标注',
              onSelected: (m) => onMoodSelected(m),
              itemBuilder: (context) => [
                const PopupMenuItem<String>(value: null, child: Text('清除标注')),
                ...moods.map((m) => PopupMenuItem<String>(value: m, child: Text(m))),
              ],
              child: CircleAvatar(
                backgroundColor: scheme.secondary,
                child: Text(
                  (currentMood != null ? currentMood!.characters.first : '🙂'),
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: controller,
                minLines: 1,
                maxLines: 5,
                decoration: const InputDecoration(
                  hintText: '慢慢说，不急～',
                ),
              ),
            ),
            const SizedBox(width: 8),
            FilledButton(
              onPressed: onSend,
              child: const Icon(Icons.send_rounded),
            ),
          ],
        ),
      ),
    );
  }
}

class _Msg {
  final String text;
  final bool mine;
  final String? mood;
  _Msg({required this.text, required this.mine, this.mood});
}


