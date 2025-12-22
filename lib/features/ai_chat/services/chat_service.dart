import 'dart:convert';
import 'package:http/http.dart' as http;
import 'openai_key_store.dart';

class ChatService {
  static const _endpoint = 'https://api.openai.com/v1/chat/completions';

  Future<String> sendMessage(String message) async {
    final apiKey = await OpenAIKeyStore.getKey();

    if (apiKey == null) {
      throw Exception('OpenAI API key not set');
    }

    final response = await http.post(
      Uri.parse(_endpoint),
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'model': 'gpt-4o-mini',
        'messages': [
          {
            'role': 'system',
            'content':
                'You are a supportive productivity and habit-building assistant.'
          },
          {'role': 'user', 'content': message},
        ],
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch AI response');
    }

    final data = jsonDecode(response.body);
    return data['choices'][0]['message']['content'];
  }
}