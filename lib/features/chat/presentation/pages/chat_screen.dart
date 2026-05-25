import 'package:flutter/material.dart';
import 'package:flutter_ai_tapchuan/core/constants/color_constants.dart';
import 'package:flutter_ai_tapchuan/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:flutter_ai_tapchuan/services/api_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  String? _currentToken(BuildContext context) {
    try {
      return context.read<AuthCubit>().state.token;
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final token = _currentToken(context);
    if (token == null || token.isEmpty) {
      return const Scaffold(
        appBar: _ChatAppBar(title: 'Chat'),
        body: Center(child: Text('Vui lòng đăng nhập để xem tin nhắn.')),
      );
    }

    return _ConversationList(token: token);
  }
}

class _ConversationList extends StatefulWidget {
  final String token;

  const _ConversationList({required this.token});

  @override
  State<_ConversationList> createState() => _ConversationListState();
}

class _ConversationListState extends State<_ConversationList> {
  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _conversations = const [];

  @override
  void initState() {
    super.initState();
    _loadConversations();
  }

  Future<void> _loadConversations() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final result = await ApiService.getListConversation(widget.token, 0, 20);
    if (!mounted) return;

    if (result['code'] == '1000') {
      setState(() {
        _conversations = _extractList(result['data']);
        _loading = false;
      });
    } else {
      setState(() {
        _error = result['message'] ?? 'Không thể tải danh sách hội thoại';
        _loading = false;
      });
    }
  }

  Future<void> _deleteConversation(Map<String, dynamic> conversation) async {
    await ApiService.deleteConversation(
      widget.token,
      partnerId: _partnerId(conversation),
      conversationId: _conversationId(conversation),
    );
    await _loadConversations();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceWhite,
      appBar: _ChatAppBar(
        title: 'Chat',
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadConversations,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Text(_error!, style: const TextStyle(color: AppColors.errorRed)),
      );
    }

    if (_conversations.isEmpty) {
      return RefreshIndicator(
        onRefresh: _loadConversations,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(height: 220),
            Center(child: Text('Chưa có hội thoại nào.')),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadConversations,
      child: ListView.separated(
        itemCount: _conversations.length,
        separatorBuilder: (_, _) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final conversation = _conversations[index];
          return ListTile(
            leading: _Avatar(url: _avatar(conversation)),
            title: Text(
              _title(conversation),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              _lastMessage(conversation),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'delete') {
                  _deleteConversation(conversation);
                }
              },
              itemBuilder: (context) => const [
                PopupMenuItem(value: 'delete', child: Text('Xóa hội thoại')),
              ],
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => _ChatRoomScreen(
                    token: widget.token,
                    conversation: conversation,
                  ),
                ),
              ).then((_) => _loadConversations());
            },
          );
        },
      ),
    );
  }
}

class _ChatRoomScreen extends StatefulWidget {
  final String token;
  final Map<String, dynamic> conversation;

  const _ChatRoomScreen({required this.token, required this.conversation});

  @override
  State<_ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<_ChatRoomScreen> {
  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _messages = const [];

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    await ApiService.setReadMessage(
      widget.token,
      partnerId: _partnerId(widget.conversation),
      conversationId: _conversationId(widget.conversation),
    );

    final result = await ApiService.getConversation(
      widget.token,
      0,
      30,
      partnerId: _partnerId(widget.conversation),
      conversationId: _conversationId(widget.conversation),
    );

    if (!mounted) return;
    if (result['code'] == '1000') {
      setState(() {
        _messages = _extractList(result['data']);
        _loading = false;
      });
    } else {
      setState(() {
        _error = result['message'] ?? 'Không thể tải tin nhắn';
        _loading = false;
      });
    }
  }

  Future<void> _deleteMessage(Map<String, dynamic> message) async {
    final messageId = _messageId(message);
    if (messageId == null || messageId.isEmpty) return;

    await ApiService.deleteMessage(widget.token, messageId);
    await _loadMessages();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: _ChatAppBar(
        title: _title(widget.conversation),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadMessages),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Text(_error!, style: const TextStyle(color: AppColors.errorRed)),
      );
    }

    if (_messages.isEmpty) {
      return RefreshIndicator(
        onRefresh: _loadMessages,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(height: 220),
            Center(child: Text('Chưa có tin nhắn nào.')),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadMessages,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        itemCount: _messages.length,
        itemBuilder: (context, index) {
          final message = _messages[index];
          final mine = _isMine(message);
          return Align(
            alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
            child: GestureDetector(
              onLongPress: () => _deleteMessage(message),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 280),
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: mine ? AppColors.primaryBlue : AppColors.surfaceWhite,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  _messageText(message),
                  style: TextStyle(
                    color: mine ? Colors.white : AppColors.textPrimary,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ChatAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;

  const _ChatAppBar({required this.title, this.actions});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.surfaceWhite,
      foregroundColor: AppColors.textPrimary,
      title: Text(
        title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      actions: actions,
    );
  }
}

class _Avatar extends StatelessWidget {
  final String url;

  const _Avatar({required this.url});

  @override
  Widget build(BuildContext context) {
    if (url.isEmpty) {
      return const CircleAvatar(child: Icon(Icons.person));
    }

    return CircleAvatar(
      backgroundImage: NetworkImage(url),
      onBackgroundImageError: (_, _) {},
      child: const SizedBox.shrink(),
    );
  }
}

List<Map<String, dynamic>> _extractList(dynamic data) {
  if (data is List) {
    return data
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }
  if (data is Map) {
    final nestedData = data['data'];
    if (nestedData is List) return _extractList(nestedData);
    final conversations = data['conversations'];
    if (conversations is List) return _extractList(conversations);
    final messages = data['messages'];
    if (messages is List) return _extractList(messages);
  }
  return const [];
}

Map<String, dynamic>? _asMap(dynamic value) {
  if (value is Map) return Map<String, dynamic>.from(value);
  return null;
}

Map<String, dynamic>? _partner(Map<String, dynamic> conversation) {
  return _asMap(conversation['partner']) ??
      _asMap(conversation['user']) ??
      _asMap(conversation['receiver']) ??
      _asMap(conversation['sender']);
}

String? _partnerId(Map<String, dynamic> conversation) {
  final partner = _partner(conversation);
  final value =
      conversation['partnerId'] ??
      conversation['partner_id'] ??
      conversation['userId'] ??
      partner?['id'];
  return value?.toString();
}

String? _conversationId(Map<String, dynamic> conversation) {
  final value =
      conversation['conversationId'] ??
      conversation['conversation_id'] ??
      conversation['id'];
  return value?.toString();
}

String _title(Map<String, dynamic> conversation) {
  final partner = _partner(conversation);
  return _firstString([
    conversation['partnerName'],
    conversation['name'],
    partner?['username'],
    partner?['name'],
  ], fallback: 'Người dùng');
}

String _avatar(Map<String, dynamic> conversation) {
  final partner = _partner(conversation);
  return _firstString([
    conversation['avatar'],
    conversation['partnerAvatar'],
    partner?['avatar'],
  ]);
}

String _lastMessage(Map<String, dynamic> conversation) {
  final lastMessage =
      _asMap(conversation['lastMessage']) ??
      _asMap(conversation['last_message']);
  return _firstString([
    lastMessage?['content'],
    lastMessage?['message'],
    conversation['lastMessage'],
    conversation['last_message'],
    conversation['message'],
  ], fallback: 'Nhấn để xem hội thoại');
}

String? _messageId(Map<String, dynamic> message) {
  final value = message['messageId'] ?? message['message_id'] ?? message['id'];
  return value?.toString();
}

String _messageText(Map<String, dynamic> message) {
  return _firstString([
    message['content'],
    message['message'],
    message['text'],
  ]);
}

bool _isMine(Map<String, dynamic> message) {
  final value = message['isMine'] ?? message['mine'] ?? message['is_mine'];
  if (value is bool) return value;
  if (value is num) return value != 0;
  if (value is String) {
    return value == '1' || value.toLowerCase() == 'true';
  }
  return false;
}

String _firstString(List<dynamic> values, {String fallback = ''}) {
  for (final value in values) {
    if (value != null && value.toString().isNotEmpty) {
      return value.toString();
    }
  }
  return fallback;
}
