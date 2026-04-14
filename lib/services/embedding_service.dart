import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class EmbeddingService {
  final _storage = const FlutterSecureStorage();
  final String _url = "https://openrouter.ai/api/v1/embeddings";

  Future<List<double>> getEmbedding(String text) async {
    final apiKey = await _storage.read(key: 'openrouter_api_key');

    final response = await http.post(
      Uri.parse(_url),
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'model': 'openai/text-embedding-3-small', // High efficiency model
        'input': text.replaceAll("\n", " "),
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<double>.from(data['data'][0]['embedding']);
    } else {
      throw Exception("Embedding Failed: ${response.body}");
    }
  }
}
