import 'dart:convert';
import 'package:http/http.dart' as http;
import 'openai_key_store.dart';

class ChatService {
 static const _endpoint =
  'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent';

  Future<String> sendMessage(String message) async {
    final apiKey = await OpenAIKeyStore.getKey();

    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('Gemini API key not set');
    }

    final uri = Uri.parse('$_endpoint?key=$apiKey');

    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'contents': [
          {
            'parts': [
              {
                'text':
                    'You are a supportive habit and productivity assistant. '
                    'Be concise, positive, and motivating.\n\n$message'
              }
            ]
          }
        ]
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Gemini error ${response.statusCode}: ${response.body}',
      );
    }

    final data = jsonDecode(response.body);

    return data['candidates'][0]['content']['parts'][0]['text'];
  }
}