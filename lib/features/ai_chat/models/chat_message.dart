enum ChatSender { user, ai }

class ChatMessage {
  final String content;
  final ChatSender sender;

  ChatMessage({
    required this.content,
    required this.sender,
  });
}