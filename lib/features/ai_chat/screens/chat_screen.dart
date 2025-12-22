import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/chat_provider.dart';
import '../models/chat_message.dart';

class ChatScreen extends ConsumerWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messages = ref.watch(chatProvider);
    final notifier = ref.read(chatProvider.notifier);
    final controller = TextEditingController();

    return Scaffold(
      backgroundColor: const Color(0xFF0F1A20),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F1A20),
        elevation: 0,
        title: const Text(
          'AI Assistant',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Container(
        color: const Color(0xFF0F1A20),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: messages.length,
                itemBuilder: (_, i) {
                  final msg = messages[i];
                  final isUser = msg.sender == ChatSender.user;

                  return Align(
                    alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      decoration: BoxDecoration(
                        color: isUser ? const Color(0xFF0EA5E9) : const Color(0xFF151F28),
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(18),
                          topRight: const Radius.circular(18),
                          bottomLeft: Radius.circular(isUser ? 18 : 4),
                          bottomRight: Radius.circular(isUser ? 4 : 18),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        msg.content,
                        style: TextStyle(
                          color: isUser ? Colors.white : Colors.white.withOpacity(0.85),
                          fontSize: 16,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Container(
              color: const Color(0xFF151F28),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Type your message...',
                        hintStyle: TextStyle(color: Colors.white54),
                        filled: true,
                        fillColor: const Color(0xFF151F28),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF0EA5E9),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white),
                      onPressed: () {
                        if (controller.text.isNotEmpty) {
                          notifier.sendMessage(controller.text);
                          controller.clear();
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}