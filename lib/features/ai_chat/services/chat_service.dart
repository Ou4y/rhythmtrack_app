import 'dart:convert';
import 'package:http/http.dart' as http;
import 'openai_key_store.dart';

class ChatService {
  static const _endpoint =
      'https://openrouter.ai/api/v1/chat/completions';

  Future<String> sendMessage(String message) async {
    final apiKey = await OpenRouterKeyStore.getKey();

    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('OpenRouter API key not set');
    }

    final response = await http.post(
      Uri.parse(_endpoint),
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
        // REQUIRED by OpenRouter
        'HTTP-Referer': 'https://rhythmtrack.app',
        'X-Title': 'RhythmTrack',
      },
      body: jsonEncode({
        'model': 'openai/gpt-4o-mini',
        'messages': [
          {
            'role': 'system',
            'content':
                'You are a supportive habit and productivity assistant. '
                'Be concise, motivating, and practical.'
          },
          {
            'role': 'user',
            'content': message,
          }
        ],
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'OpenRouter error ${response.statusCode}: ${response.body}',
      );
    }

    final data = jsonDecode(response.body);
    return data['choices'][0]['message']['content'];
  }
}