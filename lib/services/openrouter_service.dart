import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OpenRouterService {
  final _storage = FlutterSecureStorage();
  // final String _apiKey =
  //     "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";
  final String _baseUrl = "https://openrouter.ai/api/v1/chat/completions";

  Future<String> askAi(String prompt, String context) async {
    final apiKey = await _storage.read(key: 'openrouter_api_key');
    final prefs = await SharedPreferences.getInstance();
    final model =
        prefs.getString('selected_model') ??
        'nvidia/nemotron-3-super-120b-a12b:free';

    if (apiKey == null || apiKey.isEmpty) {
      return "Please Set Your API Key In Setting";
    }
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
          'HTTP-Referer': 'https://fluxen.ai', // Optional: your app site
          'X-Title': 'Fluxen Assistant', // Optional: your app name
        },
        body: jsonEncode({
          'model': model,
          // Inside askAi()
          'messages': [
            {
              'role': 'system',
              'content': context.isEmpty
                  ? 'You are Fluxen, a helpful Personal AI Assistant. Provide concise and accurate answers.'
                  : 'You are Fluxen. Use the following PDF snippets to answer the user. If not in context, say you don\'t know.\n\nCONTEXT: $context',
            },
            {'role': 'user', 'content': prompt},
          ],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'];
        return content ?? "The AI returned an empty response.";
      } else {
        final errorData = jsonDecode(response.body);
        return "API Error: ${errorData['error']['message'] ?? response.statusCode}";
      }
    } catch (e) {
      return "Network Error: $e";
    }
  }
}
