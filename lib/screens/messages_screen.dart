import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../state/app_state.dart';
import '../theme/pusula_theme.dart';
import '../widgets/common.dart';
import '../widgets/home_button.dart';
import 'provider_detail_screen.dart';

/// "Mesajlasma" design: conversation list (search box, unread dots,
/// active chat highlighted) + chat pane with an offer context strip,
/// green my-bubbles and automatic contact masking until the first
/// lesson is confirmed. Mobile shows one column with "←" back.
class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  String? _selectedId;
  String _listQuery = '';

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final me = app.currentUser!;
    var convs = app.myConversations;
    if (_listQuery.trim().isNotEmpty) {
      final q = _listQuery.trim().toLowerCase();
      convs = convs.where((c) {
        final other = app.userById(c.otherUserId(me.id));
        return (other?.name ?? '').toLowerCase().contains(q);
      }).toList();
    }
    final wide = MediaQuery.of(context).size.width >= 900;

    if (convs.isEmpty && _listQuery.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Henüz mesajınız yok.\nMesajlaşma, teklifler üzerinden veya '
            'ilan sayfalarındaki "Mesaj" butonuyla açılır.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (!wide) {
      return _list(app, me, convs, (id) {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => ChatScreen(conversationId: id)));
      });
    }

    final selected = convs
            .where((c) => c.id == _selectedId)
            .firstOrNull ??
        (convs.isNotEmpty ? convs.first : null);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          width: 320,
          child: _list(app, me, convs,
              (id) => setState(() => _selectedId = id),
              activeId: selected?.id),
        ),
        const VerticalDivider(width: 1),
        Expanded(
          child: selected == null
              ? const Center(child: Text('Bir sohbet seçin'))
              : ChatView(conversationId: selected.id),
        ),
      ],
    );
  }

  Widget _list(AppState app, AppUser me, List<Conversation> convs,
      void Function(String id) onOpen,
      {String? activeId}) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
          child: TextField(
            decoration: const InputDecoration(
              hintText: 'Sohbetlerde ara…',
              prefixIcon: Icon(Icons.search, size: 18),
              isDense: true,
            ),
            onChanged: (v) => setState(() => _listQuery = v),
          ),
        ),
        Expanded(
          child: ListView(
            children: [
              for (final conv in convs)
                _listTile(app, me, conv, conv.id == activeId, onOpen),
            ],
          ),
        ),
        Container(
          margin: const EdgeInsets.all(10),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: PusulaColors.surface,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Text(
            '🔒 Telefon, e-posta ve adres paylaşımı ilk ders onayına kadar '
            'otomatik gizlenir.',
            style: TextStyle(fontSize: 11.5, color: PusulaColors.muted),
          ),
        ),
      ],
    );
  }

  Widget _listTile(AppState app, AppUser me, Conversation conv, bool active,
      void Function(String id) onOpen) {
    final other = app.userById(conv.otherUserId(me.id));
    final name = other?.name ?? 'Bilinmeyen kullanıcı';
    final last = conv.lastMessage;
    final unread = last != null && last.senderId != me.id;

    return InkWell(
      onTap: () => onOpen(conv.id),
      child: Container(
        color: active ? PusulaColors.primarySoft : null,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor:
                  active ? Colors.white : PusulaColors.primarySoft,
              child: Text(name.characters.first.toUpperCase(),
                  style: const TextStyle(
                      color: PusulaColors.primaryDark,
                      fontWeight: FontWeight.w700)),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text('$name ✓',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700)),
                      ),
                      if (last != null)
                        Text(formatTime(last.sentAt),
                            style: const TextStyle(
                                fontSize: 11, color: PusulaColors.faint)),
                    ],
                  ),
                  Text(other?.role.labelTr ?? '',
                      style: const TextStyle(
                          fontSize: 11, color: PusulaColors.muted)),
                  Text(
                    last == null
                        ? 'Henüz mesaj yok'
                        : app.maskContact(last.text, conv).$1,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 12.5,
                        fontWeight:
                            unread ? FontWeight.w600 : FontWeight.w400,
                        color: unread
                            ? PusulaColors.ink
                            : PusulaColors.muted),
                  ),
                ],
              ),
            ),
            if (unread)
              Container(
                margin: const EdgeInsets.only(left: 8),
                width: 9,
                height: 9,
                decoration: const BoxDecoration(
                  color: PusulaColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Chat pane per the design; embedded in the two-pane layout or pushed
/// standalone as [ChatScreen].
class ChatView extends StatefulWidget {
  const ChatView({super.key, required this.conversationId});

  final String conversationId;

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _send(AppState app, Conversation conv) {
    if (_controller.text.trim().isEmpty) return;
    app.sendMessage(conv, _controller.text);
    _controller.clear();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  /// Offer/bid between the two parties, for the context strip.
  (String, String)? _offerContext(AppState app, Conversation conv) {
    final me = app.currentUser!;
    final otherId = conv.otherUserId(me.id);
    for (final o in app.offers) {
      final providerOwner = app.providerById(o.providerId)?.ownerUserId;
      final pair = {o.requesterId, providerOwner};
      if (pair.containsAll({me.id, otherId})) {
        final name = app.providerById(o.providerId)?.name ?? 'İlan';
        return (
          name,
          o.quotedPrice != null
              ? 'Teklif: ${formatPrice(o.quotedPrice!)}/ay · ${o.status.labelTr}'
              : 'Teklif isteği · ${o.status.labelTr}'
        );
      }
    }
    for (final b in app.bids) {
      final owner = app.studentListingById(b.listingId)?.ownerUserId;
      if ({b.teacherUserId, owner}.containsAll({me.id, otherId})) {
        final title = app.studentListingById(b.listingId)?.title ?? 'İlan';
        return (
          title,
          'Teklif: ₺${b.price.toStringAsFixed(0)}/ders · ${switch (b.status) {
            BidStatus.accepted => 'Kabul edildi',
            BidStatus.rejected => 'Reddedildi',
            _ => 'Bekliyor',
          }}'
        );
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final me = app.currentUser!;
    final conv = app.conversations
        .where((c) => c.id == widget.conversationId)
        .firstOrNull;
    if (conv == null) return const Center(child: Text('Sohbet bulunamadı'));
    final other = app.userById(conv.otherUserId(me.id));
    final otherName = other?.name ?? 'Sohbet';
    final context_ = _offerContext(app, conv);

    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: const BoxDecoration(
            color: PusulaColors.card,
            border: Border(bottom: BorderSide(color: PusulaColors.border)),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: PusulaColors.primarySoft,
                child: Text(otherName.characters.first.toUpperCase(),
                    style: const TextStyle(
                        color: PusulaColors.primaryDark,
                        fontWeight: FontWeight.w700,
                        fontSize: 14)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('$otherName ✓',
                        style: const TextStyle(
                            fontSize: 14.5, fontWeight: FontWeight.w700)),
                    Text(
                      '${other?.role.labelTr ?? ''} · genellikle 1 saat '
                      'içinde yanıtlar',
                      style: const TextStyle(
                          fontSize: 11.5, color: PusulaColors.muted),
                    ),
                  ],
                ),
              ),
              if (other?.providerId != null)
                TextButton(
                  onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (_) => ProviderDetailScreen(
                              providerId: other!.providerId!))),
                  child: const Text('Profili gör'),
                ),
            ],
          ),
        ),
        // Offer context strip
        if (context_ != null)
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: PusulaColors.primarySoft,
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(context_.$1,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: PusulaColors.primaryDark)),
                      Text(context_.$2,
                          style: const TextStyle(
                              fontSize: 11.5,
                              color: PusulaColors.primaryDark)),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).maybePop(),
                  child: const Text('Teklife git →',
                      style: TextStyle(fontSize: 12.5)),
                ),
              ],
            ),
          ),
        // Messages
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(14),
            itemCount: conv.messages.length,
            itemBuilder: (context, i) {
              final m = conv.messages[i];
              final mine = m.senderId == me.id;
              final (text, masked) = app.maskContact(m.text, conv);
              return Column(
                crossAxisAlignment: mine
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment:
                        mine ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      constraints: const BoxConstraints(maxWidth: 420),
                      decoration: BoxDecoration(
                        color:
                            mine ? PusulaColors.primary : Colors.white,
                        border: mine
                            ? null
                            : Border.all(color: PusulaColors.border),
                        borderRadius: mine
                            ? const BorderRadius.only(
                                topLeft: Radius.circular(16),
                                topRight: Radius.circular(16),
                                bottomRight: Radius.circular(4),
                                bottomLeft: Radius.circular(16),
                              )
                            : const BorderRadius.only(
                                topLeft: Radius.circular(16),
                                topRight: Radius.circular(16),
                                bottomRight: Radius.circular(16),
                                bottomLeft: Radius.circular(4),
                              ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(text,
                              style: TextStyle(
                                  fontSize: 14,
                                  height: 1.4,
                                  color: mine
                                      ? Colors.white
                                      : PusulaColors.ink)),
                          const SizedBox(height: 2),
                          Text(formatTime(m.sentAt),
                              style: TextStyle(
                                  fontSize: 10,
                                  color: mine
                                      ? Colors.white70
                                      : PusulaColors.faint)),
                        ],
                      ),
                    ),
                  ),
                  if (masked)
                    Container(
                      margin: const EdgeInsets.only(bottom: 4),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFBF1DF),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: const Text(
                        '⚠ Bir mesajdaki iletişim bilgisi güvenlik gereği '
                        'gizlendi',
                        style: TextStyle(
                            fontSize: 11, color: Color(0xFF8A6212)),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
        // Composer
        SafeArea(
          child: Container(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
            decoration: const BoxDecoration(
              color: PusulaColors.card,
              border:
                  Border(top: BorderSide(color: PusulaColors.border)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Mesaj yazın…',
                      isDense: true,
                    ),
                    onSubmitted: (_) => _send(app, conv),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: () => _send(app, conv),
                  child: const Text('Gönder'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Standalone chat route (mobile flow and direct pushes).
class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key, required this.conversationId});

  final String conversationId;

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final me = app.currentUser!;
    final conv = app.conversations
        .where((c) => c.id == conversationId)
        .firstOrNull;
    final other =
        conv == null ? null : app.userById(conv.otherUserId(me.id));
    return Scaffold(
      appBar: AppBar(
        title: Text(other?.name ?? 'Sohbet'),
        actions: const [HomeButton(), SizedBox(width: 8)],
      ),
      body: conv == null
          ? const Center(child: Text('Sohbet bulunamadı'))
          : ChatView(conversationId: conversationId),
    );
  }
}
