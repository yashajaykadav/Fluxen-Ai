import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'screen/chat_screen.dart';
import 'controller/chat_controller.dart';
import 'services/objectbox_service.dart';
import 'services/openrouter_service.dart';
import 'services/pdf_service.dart';
import 'services/vector_service.dart';
import 'services/embedding_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ObjectBoxService.init();
  runApp(
    ChangeNotifierProvider(
      create: (_) => ChatController(
        aiService: OpenRouterService(),
        pdfService: PdfService(),
        vectorService: VectorService(),
        embeddingService: EmbeddingService(),
      ),
      child: const FluxenAI(),
    ),
  );
}

class FluxenAI extends StatelessWidget {
  const FluxenAI({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.blue),
      home: const ChatScreen(),
    );
  }
}
