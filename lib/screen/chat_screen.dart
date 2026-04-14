import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';

import '../controller/chat_controller.dart';
import '../widgets/chat/message_bubble.dart';
import '../widgets/chat/chat_input.dart';
import '../widgets/chat/history_drawer.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _queryController = TextEditingController();
  final _scrollController = ScrollController();

  final stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterTts _tts = FlutterTts();

  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _initVoice();
  }

  Future<void> _initVoice() async {
    await _speech.initialize();
    await _tts.setLanguage('en-US');
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  // 🎤 Voice
  void _listen(ChatController controller) async {
    if (!_isListening) {
      bool available = await _speech.initialize();
      if (available) {
        setState(() => _isListening = true);

        _speech.listen(
          onResult: (val) {
            _queryController.text = val.recognizedWords;

            if (val.finalResult) {
              setState(() => _isListening = false);

              controller.sendQuery(_queryController.text);
              _queryController.clear();
              _scrollToBottom();
            }
          },
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  Future<void> _speak(String text) async {
    await _tts.speak(text.replaceAll(RegExp(r'[\*#_]'), ''));
  }

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<ChatController>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(controller.activePdfName ?? "Fluxen AI"),
        actions: [
          if (controller.activePdfName != null)
            IconButton(
              icon: const Icon(Icons.close, color: Colors.red),
              onPressed: () {
                controller.activePdfName = null;
                controller.notifyListeners();
              },
            ),
          IconButton(
            icon: const Icon(Icons.note_add),
            onPressed: controller.processPdf,
          ),
        ],
      ),
      drawer: HistoryDrawer(onNewChat: controller.startNewSession),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: controller.messages.length,
              itemBuilder: (c, i) {
                final msg = controller.messages[i];

                // 🔊 Speak AI message automatically
                if (!msg.isUser && i == controller.messages.length - 1) {
                  _speak(msg.text);
                }

                return MessageBubble(msg: msg);
              },
            ),
          ),
          if (controller.isLoading) const LinearProgressIndicator(),
          ChatInput(
            controller: _queryController,
            onSend: () {
              controller.sendQuery(_queryController.text);
              _queryController.clear();
              _scrollToBottom();
            },
            onMic: () => _listen(controller),
            isListening: _isListening,
          ),
        ],
      ),
    );
  }
}
