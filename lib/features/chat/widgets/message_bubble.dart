import 'package:flutter/material.dart';

class MessageBubble extends StatelessWidget {
  final String text;
  final bool isMine;
  final String? moodLabel; // optional mood tag

  const MessageBubble({super.key, required this.text, required this.isMine, this.moodLabel});

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final Color bubbleColor = isMine ? scheme.primary : scheme.surface;
    final Color textColor = isMine ? scheme.onPrimary : scheme.onSurface;

    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
        constraints: const BoxConstraints(maxWidth: 320),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (moodLabel != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  moodLabel!,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: textColor.withValues(alpha: 0.9),
                      ),
                ),
              ),
            Text(text, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: textColor)),
          ],
        ),
      ),
    );
  }
}


