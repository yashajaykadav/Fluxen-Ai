import 'package:flutter/material.dart';

class ChatInput extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final VoidCallback onMic;
  final bool isListening;

  const ChatInput({
    super.key,
    required this.controller,
    required this.onSend,
    required this.onMic,
    required this.isListening,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: Icon(isListening ? Icons.mic : Icons.mic_none),
          onPressed: onMic,
        ),
        Expanded(
          child: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: "Ask..."),
          ),
        ),
        IconButton(icon: const Icon(Icons.send), onPressed: onSend),
      ],
    );
  }
}
