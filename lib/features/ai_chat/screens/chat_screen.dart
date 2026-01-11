import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/chat_provider.dart';
import '../models/chat_message.dart';

class ChatScreen extends ConsumerWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final messages = ref.watch(chatProvider);
    final notifier = ref.read(chatProvider.notifier);
    final controller = TextEditingController();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor ?? colorScheme.primary,
        elevation: theme.appBarTheme.elevation ?? 4,
        title: Row(
          children: [
            Icon(Icons.smart_toy, color: colorScheme.onPrimary),
            const SizedBox(width: 8),
            Text(
              'AI Assistant',
              style: theme.textTheme.titleLarge?.copyWith(color: theme.appBarTheme.foregroundColor ?? colorScheme.onPrimary, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(18)),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [theme.scaffoldBackgroundColor, theme.cardColor.withOpacity(0.95)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
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
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeOut,
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      decoration: BoxDecoration(
                        color: isUser
                            ? colorScheme.primary.withOpacity(0.95)
                            : theme.cardColor,
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(18),
                          topRight: const Radius.circular(18),
                          bottomLeft: Radius.circular(isUser ? 18 : 4),
                          bottomRight: Radius.circular(isUser ? 4 : 18),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.10),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Text(
                        msg.content,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: isUser ? colorScheme.onPrimary : theme.textTheme.bodyLarge?.color?.withOpacity(0.92),
                          fontSize: 16,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: theme.cardColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.07),
                    blurRadius: 12,
                    offset: const Offset(0, -2),
                  ),
                ],
                borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller,
                      style: theme.textTheme.bodyLarge?.copyWith(color: theme.textTheme.bodyLarge?.color, fontSize: 16),
                      decoration: InputDecoration(
                        hintText: 'Type your message...',
                        hintStyle: theme.textTheme.bodyLarge?.copyWith(color: theme.hintColor, fontSize: 15),
                        filled: true,
                        fillColor: theme.cardColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
                      ),
                      textInputAction: TextInputAction.send,
                      onSubmitted: (text) {
                        if (text.isNotEmpty) {
                          notifier.sendMessage(text);
                          controller.clear();
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [colorScheme.primary, colorScheme.secondary],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: colorScheme.primary.withOpacity(0.25),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: Icon(Icons.send, color: colorScheme.onPrimary, size: 26),
                      tooltip: 'Send',
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