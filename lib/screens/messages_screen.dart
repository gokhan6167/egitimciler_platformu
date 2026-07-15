import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../widgets/common.dart';

/// Conversation list for the signed-in user.
class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final convs = app.myConversations;
    final me = app.currentUser!;

    if (convs.isEmpty) {
      return const Center(
        child: Text('Henüz mesajınız yok.\nİlan sayfalarından mesaj gönderebilirsiniz.',
            textAlign: TextAlign.center),
      );
    }

    return ListView.separated(
      itemCount: convs.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, i) {
        final conv = convs[i];
        final other = app.userById(conv.otherUserId(me.id));
        final last = conv.lastMessage;
        return ListTile(
          leading: const CircleAvatar(child: Icon(Icons.person)),
          title: Text(other?.name ?? 'Bilinmeyen kullanıcı'),
          subtitle: Text(
            last == null ? 'Henüz mesaj yok' : last.text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: last == null ? null : Text(formatTime(last.sentAt)),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => ChatScreen(conversationId: conv.id)),
          ),
        );
      },
    );
  }
}

/// One-on-one chat.
class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key, required this.conversationId});

  final String conversationId;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _send(AppState app) {
    final conv = app.conversations
        .where((c) => c.id == widget.conversationId)
        .firstOrNull;
    if (conv == null) return;
    app.sendMessage(conv, _controller.text);
    _controller.clear();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final me = app.currentUser!;
    final conv = app.conversations
        .where((c) => c.id == widget.conversationId)
        .firstOrNull;
    if (conv == null) {
      return const Scaffold(body: Center(child: Text('Sohbet bulunamadı')));
    }
    final other = app.userById(conv.otherUserId(me.id));

    return Scaffold(
      appBar: AppBar(title: Text(other?.name ?? 'Sohbet')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(12),
              itemCount: conv.messages.length,
              itemBuilder: (context, i) {
                final m = conv.messages[i];
                final mine = m.senderId == me.id;
                return Align(
                  alignment:
                      mine ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 3),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    constraints: const BoxConstraints(maxWidth: 420),
                    decoration: BoxDecoration(
                      color: mine
                          ? Theme.of(context).colorScheme.primaryContainer
                          : Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(m.text),
                        Text(formatTime(m.sentAt),
                            style: const TextStyle(
                                fontSize: 10, color: Colors.grey)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        hintText: 'Mesaj yazın...',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      onSubmitted: (_) => _send(app),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    icon: const Icon(Icons.send),
                    onPressed: () => _send(app),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
