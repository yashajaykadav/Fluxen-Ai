import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../models/chat_history.dart';
import '../models/document_chunk.dart';
import '../objectbox.g.dart';
import '../services/objectbox_service.dart';
import '../services/openrouter_service.dart';
import '../services/pdf_service.dart';
import '../services/vector_service.dart';
import '../services/embedding_service.dart';

class ChatController extends ChangeNotifier {
  final OpenRouterService _aiService;
  final PdfService _pdfService;
  final VectorService _vectorService;
  final EmbeddingService _embeddingService;
  late final Box<ChatSession> _sessionBox;
  late final Box<ChatMessageEntity> _messageBox;

  List<ChatMessageEntity> messages = [];
  String? activePdfName;
  bool isLoading = false;
  ChatSession? currentSession;

  ChatController({
    required OpenRouterService aiService,
    required PdfService pdfService,
    required VectorService vectorService,
    required EmbeddingService embeddingService,
  }) : _aiService = aiService,
       _pdfService = pdfService,
       _vectorService = vectorService,
       _embeddingService = embeddingService,
       _sessionBox = ObjectBoxService.store.box<ChatSession>(),
       _messageBox = ObjectBoxService.store.box<ChatMessageEntity>() {
    _vectorService.init(); // IMPORTANT
    startNewSession();
  }

  // 🆕 NEW CHAT
  void startNewSession() {
    currentSession = ChatSession(title: "New Chat", timestamp: DateTime.now());
    _sessionBox.put(currentSession!);

    messages.clear();
    activePdfName = null;
    notifyListeners();
  }

  // 🤖 SEND QUERY (FIXED)
  Future<void> sendQuery(String text) async {
    if (text.trim().isEmpty) return;

    final userMsg = ChatMessageEntity(
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
    );
    userMsg.session.target = currentSession;
    _messageBox.put(userMsg);
    messages.add(userMsg);
    isLoading = true;
    notifyListeners();

    try {
      String context = "";

      if (activePdfName != null) {
        final vector = await _embeddingService.getEmbedding(text);
        final chunks = _vectorService.searchRelevant(vector, limit: 3);
        context = chunks.map((c) => c.text).join("\n---\n");
      }

      final answer = await _aiService.askAi(text, context);

      final aiMsg = ChatMessageEntity(
        text: answer,
        isUser: false,
        timestamp: DateTime.now(),
      );

      aiMsg.session.target = currentSession;
      _messageBox.put(aiMsg);
      messages.add(aiMsg);

      if (messages.length == 2) {
        currentSession!.title = text;
      }
    } catch (e) {
      messages.add(
        ChatMessageEntity(
          text: "Error: $e",
          isUser: false,
          timestamp: DateTime.now(),
        ),
      );
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  List<ChatSession> getAllSessions() {
    return _sessionBox.getAll()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  void loadSession(ChatSession session) {
    currentSession = session;

    messages = session.messages.toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    notifyListeners();
  }

  // 📄 PROCESS PDF (FIXED)
  Future<void> processPdf() async {
    isLoading = true;
    notifyListeners();

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result == null) return;

      final file = File(result.files.single.path!);
      final text = await _pdfService.extractText(file);

      final chunks = _pdfService.splitIntoChunks(text);

      for (var chunk in chunks) {
        final vector = await _embeddingService.getEmbedding(chunk);

        _vectorService.saveChunks([
          DocumentChunk(
            text: chunk,
            fileName: result.files.single.name,
            signature: vector,
          ),
        ]);
      }

      activePdfName = result.files.single.name;

      messages.add(
        ChatMessageEntity(
          text: "PDF Loaded: ${result.files.single.name}",
          isUser: false,
          timestamp: DateTime.now(),
        ),
      );
    } catch (e) {
      messages.add(
        ChatMessageEntity(
          text: "Error loading PDF: $e",
          isUser: false,
          timestamp: DateTime.now(),
        ),
      );
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
