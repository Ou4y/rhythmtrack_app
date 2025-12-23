import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/chat_message.dart';
import '../services/chat_service.dart';

final chatProvider =
    StateNotifierProvider<ChatNotifier, List<ChatMessage>>(
  (ref) => ChatNotifier(),
);

class ChatNotifier extends StateNotifier<List<ChatMessage>> {
  ChatNotifier() : super([]);

  final ChatService _service = ChatService();

  Future<void> sendMessage(String text) async {
    state = [
      ...state,
      ChatMessage(content: text, sender: ChatSender.user),
    ];

    try {
      final reply = await _service.sendMessage(text);
      state = [
        ...state,
        ChatMessage(content: reply, sender: ChatSender.ai),
      ];
    } catch (e) {
      state = [
        ...state,
        ChatMessage(
          content: 'AI Error: $e',
          sender: ChatSender.ai,
        ),
      ];
    }
  }
}