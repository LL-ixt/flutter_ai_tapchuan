import 'package:flutter/material.dart';
import 'package:flutter_ai_tapchuan/core/constants/color_constants.dart';
import 'package:flutter_ai_tapchuan/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:flutter_ai_tapchuan/services/api_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/create_chat_cubit.dart';
import '../bloc/create_chat_state.dart';
import '../bloc/chat_cubit.dart';
import 'chat_room_screen.dart';

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

    return BlocProvider(
      create: (_) => CreateChatCubit(),
      child: _ConversationList(token: token),
    );
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

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  List<dynamic> _searchResults = [];
  bool _searchLoading = false;

  Future<void> _performSearch(String keyword) async {
    if (keyword.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _searchLoading = false;
      });
      return;
    }

    setState(() {
      _searchLoading = true;
    });

    try {
      final authState = context.read<AuthCubit>().state;
      final myUserId = authState.userId ?? '';
      final response = await ApiService.search(
        widget.token,
        keyword.trim(),
        myUserId,
        0,
        50,
      );

      if (!mounted) return;

      if (response['code'] == '1000') {
        final data = response['data'] as Map<String, dynamic>? ?? {};
        final List<dynamic> usersList = (data['users'] as List<dynamic>?) ?? [];

        final filteredUsers = usersList.where((u) {
          if (u is! Map<String, dynamic>) return false;
          final username = u['username']?.toString() ?? '';
          final name = u['name']?.toString() ?? '';
          return _matchesSearch(username, keyword) ||
              _matchesSearch(name, keyword);
        }).toList();

        setState(() {
          _searchResults = filteredUsers;
          _searchLoading = false;
        });
      } else {
        setState(() {
          _searchResults = [];
          _searchLoading = false;
        });
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _searchResults = [];
        _searchLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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

  // Hàm hiển thị hộp thoại tìm kiếm "Tạo tin nhắn mới"
  void _showNewMessageSheet(BuildContext context) {
    final searchController = TextEditingController();
    final createCubit = context.read<CreateChatCubit>();
    createCubit.reset(); // Xóa trạng thái cũ đi nếu có

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return BlocProvider.value(
          value: createCubit, // Truyền Cubit hiện tại vào sheet context
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
              left: 20,
              right: 20,
              top: 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Tạo tin nhắn mới",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 15),

                // Ô Search box nhập ID theo đúng thiết kế slide
                TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    hintText: "Nhập user_id đối phương...",
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 15),

                // Lắng nghe dữ liệu đổ về từ Cubit phát ra
                BlocConsumer<CreateChatCubit, CreateChatState>(
                  listener: (context, state) {
                    if (state is CreateChatSuccess) {
                      Navigator.pop(sheetContext); // Đóng hộp thoại tìm kiếm

                      // 1. Lấy thông tin mình từ AuthCubit
                      final authState = context.read<AuthCubit>().state;
                      final myInfo = {
                        'id': authState.userId ?? 'my_id_001',
                        'username': authState.username,
                        'avatar': '',
                      };

                      // 2. Thông tin đối phương vừa bốc được qua API get_user_info
                      final partnerInfo = state.partnerInfo;

                      // 3. Kích hoạt Socket phòng chat qua ChatCubit
                      context.read<ChatCubit>().joinChatRoom(
                        token: widget.token,
                        myInfo: myInfo,
                        partnerInfo: partnerInfo,
                      );

                      // 4. CHUYỂN MÀN HÌNH SANG GIAO DIỆN NHẮN TIN THỜI GIAN THỰC
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChatRoomDetailScreen(
                            partnerInfo: partnerInfo,
                            token: widget.token,
                            myInfo: myInfo,
                            conversationId: partnerInfo['conversationId']
                                ?.toString(), // Có thể null cho chat mới
                          ),
                        ),
                      ).then((_) => _loadConversations());
                    }
                  },
                  builder: (context, state) {
                    if (state is CreateChatLoading) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(10.0),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }

                    return Column(
                      children: [
                        if (state is CreateChatFailure)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Text(
                              state.message,
                              style: const TextStyle(color: AppColors.errorRed),
                            ),
                          ),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryBlue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () {
                              context.read<CreateChatCubit>().findUserToChat(
                                token: widget.token,
                                userId: searchController.text.trim(),
                              );
                            },
                            child: const Text(
                              "Tìm kiếm & Bắt đầu Chat",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 25),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _deleteConversation(Map<String, dynamic> conversation) async {
    await ApiService.deleteConversation(
      widget.token,
      partnerId: _partnerId(conversation),
      conversationId: _conversationId(conversation),
    );
    await _loadConversations();
  }

  void _openChat(Map<String, dynamic> conversation) {
    final authState = context.read<AuthCubit>().state;
    final Map<String, dynamic> myInfo = {
      'id': authState.userId ?? 'my_id_001',
      'username': authState.username,
      'avatar': '',
    };

    final Map<String, dynamic> partnerInfo = {
      'id': _partnerId(conversation),
      'username': _title(conversation),
      'avatar': _avatar(conversation),
    };

    context.read<ChatCubit>().joinChatRoom(
      token: widget.token,
      myInfo: myInfo,
      partnerInfo: partnerInfo,
      conversationId: _conversationId(conversation),
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatRoomDetailScreen(
          partnerInfo: partnerInfo,
          token: widget.token,
          myInfo: myInfo,
          conversationId: _conversationId(conversation),
        ),
      ),
    ).then((_) => _loadConversations());
  }

  String _formatLastMessageTime(dynamic rawTime) {
    if (rawTime == null || rawTime.toString().isEmpty) return '';
    try {
      DateTime date;
      if (rawTime is String) {
        date = DateTime.parse(rawTime).toLocal();
      } else if (rawTime is num) {
        date = DateTime.fromMillisecondsSinceEpoch(rawTime.toInt()).toLocal();
      } else {
        return '';
      }

      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inMinutes < 1) {
        return 'Vừa xong';
      } else if (difference.inMinutes < 60) {
        return '${difference.inMinutes} phút';
      } else if (difference.inHours < 24) {
        return '${difference.inHours} giờ';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} ngày';
      } else {
        return '${date.day}/${date.month}';
      }
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceWhite,
      appBar: _ChatAppBar(
        title: 'Đoạn chat',
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: AppColors.textPrimary),
            tooltip: "Tạo tin nhắn mới",
            onPressed: () => _showNewMessageSheet(context),
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.textPrimary),
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

    final activePartners = _conversations
        .map((c) => _partner(c))
        .where((p) => p != null && _partnerId({'partner': p}) != null)
        .toList();

    return RefreshIndicator(
      onRefresh: _loadConversations,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Row(
                children: [
                  const Icon(Icons.search, color: Colors.grey, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: (val) {
                        setState(() {
                          _searchQuery = val;
                        });
                        _performSearch(val);
                      },
                      decoration: const InputDecoration(
                        hintText: 'Tìm kiếm trên Messenger',
                        hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                  if (_searchQuery.isNotEmpty)
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _searchController.clear();
                          _searchQuery = '';
                          _searchResults = [];
                          _searchLoading = false;
                        });
                      },
                      child: const Icon(
                        Icons.clear,
                        color: Colors.grey,
                        size: 20,
                      ),
                    ),
                ],
              ),
            ),
          ),

          if (_searchQuery.isNotEmpty)
            Expanded(
              child: _searchLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _searchResults.isEmpty
                  ? const Center(
                      child: Text(
                        'Không tìm thấy người dùng phù hợp.',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: _searchResults.length,
                      itemBuilder: (context, index) {
                        final user =
                            _searchResults[index] as Map<String, dynamic>;
                        final name = user['username'] ?? 'User';
                        final avatarUrl = user['avatar'] ?? '';
                        final partnerIdStr =
                            user['id']?.toString() ??
                            user['user_id']?.toString() ??
                            '';
                        final roleStr = user['role'] == 'GV'
                            ? 'Giảng viên'
                            : 'Học viên';

                        return InkWell(
                          onTap: () {
                            final conv = _conversations.firstWhere(
                              (c) => _partnerId(c) == partnerIdStr,
                              orElse: () => <String, dynamic>{},
                            );
                            if (conv.isNotEmpty) {
                              _openChat(conv);
                            } else {
                              // Bắt đầu chat mới
                              final authState = context.read<AuthCubit>().state;
                              final myInfo = {
                                'id': authState.userId ?? 'my_id_001',
                                'username': authState.username,
                                'avatar': '',
                              };
                              final partnerInfo = {
                                'id': partnerIdStr,
                                'username': name,
                                'avatar': avatarUrl,
                              };
                              context.read<ChatCubit>().joinChatRoom(
                                token: widget.token,
                                myInfo: myInfo,
                                partnerInfo: partnerInfo,
                              );
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ChatRoomDetailScreen(
                                    partnerInfo: partnerInfo,
                                    token: widget.token,
                                    myInfo: myInfo,
                                  ),
                                ),
                              ).then((_) => _loadConversations());
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 10.0,
                            ),
                            child: Row(
                              children: [
                                _Avatar(url: avatarUrl, radius: 24),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        name,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        roleStr,
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            )
          else ...[
            // 2. Horizontal Active Row
            if (activePartners.isNotEmpty) ...[
              Container(
                height: 96,
                padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  itemCount: activePartners.length,
                  itemBuilder: (context, index) {
                    final partner = Map<String, dynamic>.from(
                      activePartners[index]!,
                    );
                    final name =
                        partner['username'] ?? partner['name'] ?? 'User';
                    final avatarUrl = partner['avatar'] ?? '';
                    final partnerIdStr = partner['id']?.toString() ?? '';

                    return GestureDetector(
                      onTap: () {
                        final conv = _conversations.firstWhere(
                          (c) => _partnerId(c) == partnerIdStr,
                          orElse: () => <String, dynamic>{},
                        );
                        if (conv.isNotEmpty) {
                          _openChat(conv);
                        } else {
                          // Bắt đầu chat mới
                          final authState = context.read<AuthCubit>().state;
                          final myInfo = {
                            'id': authState.userId ?? 'my_id_001',
                            'username': authState.username,
                            'avatar': '',
                          };
                          context.read<ChatCubit>().joinChatRoom(
                            token: widget.token,
                            myInfo: myInfo,
                            partnerInfo: partner,
                          );
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ChatRoomDetailScreen(
                                partnerInfo: partner,
                                token: widget.token,
                                myInfo: myInfo,
                              ),
                            ),
                          ).then((_) => _loadConversations());
                        }
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 16.0),
                        width: 64,
                        child: Column(
                          children: [
                            Stack(
                              children: [
                                _Avatar(url: avatarUrl, radius: 26),
                                Positioned(
                                  right: 0,
                                  bottom: 0,
                                  child: Container(
                                    width: 14,
                                    height: 14,
                                    decoration: BoxDecoration(
                                      color: Colors.green,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 2.5,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],

            // 3. Conversation List
            Expanded(
              child: _conversations.isEmpty
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: const [
                        SizedBox(height: 120),
                        Center(
                          child: Text(
                            'Chưa có hội thoại nào.',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      ],
                    )
                  : ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4.0,
                        vertical: 8.0,
                      ),
                      itemCount: _conversations.length,
                      itemBuilder: (context, index) {
                        final conversation = _conversations[index];
                        final avatarUrl = _avatar(conversation);
                        final titleText = _title(conversation);
                        final myUserId =
                            context.read<AuthCubit>().state.userId ?? '';
                        final lastMsgText = _lastMessage(
                          conversation,
                          myUserId,
                        );

                        final lastMessageObj =
                            _asMap(conversation['lastMessage']) ??
                            _asMap(conversation['last_message']) ??
                            _asMap(conversation['lastmessage']) ??
                            {};
                        final createdTime =
                            lastMessageObj['created'] ??
                            conversation['updatedAt'] ??
                            '';
                        final displayTime = _formatLastMessageTime(createdTime);

                        final lastMessageUnread = lastMessageObj['unread'];
                        final bool isMine = lastMsgText.startsWith('Bạn:');
                        final bool isUnread = (lastMessageUnread == '1' ||
                            lastMessageUnread == 1 ||
                            lastMessageUnread == true ||
                            conversation['unread'] == true ||
                            conversation['isRead'] == false) && !isMine;

                        return InkWell(
                          onTap: () => _openChat(conversation),
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12.0,
                              vertical: 8.0,
                            ),
                            child: Row(
                              children: [
                                Stack(
                                  children: [
                                    _Avatar(url: avatarUrl, radius: 28),
                                    Positioned(
                                      right: 0,
                                      bottom: 0,
                                      child: Container(
                                        width: 14,
                                        height: 14,
                                        decoration: BoxDecoration(
                                          color: Colors.green,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: Colors.white,
                                            width: 2,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        titleText,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: isUnread
                                              ? FontWeight.bold
                                              : FontWeight.w600,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              lastMsgText,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: isUnread
                                                    ? FontWeight.bold
                                                    : FontWeight.normal,
                                                color: isUnread
                                                    ? Colors.black87
                                                    : Colors.grey[600],
                                              ),
                                            ),
                                          ),
                                          if (displayTime.isNotEmpty) ...[
                                            Text(
                                              ' • $displayTime',
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: isUnread
                                                    ? FontWeight.bold
                                                    : FontWeight.normal,
                                                color: isUnread
                                                    ? Colors.black54
                                                    : Colors.grey[500],
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                if (isUnread)
                                  Container(
                                    width: 12,
                                    height: 12,
                                    margin: const EdgeInsets.only(right: 8),
                                    decoration: const BoxDecoration(
                                      color: AppColors.primaryBlue,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                PopupMenuButton<String>(
                                  icon: const Icon(
                                    Icons.more_horiz,
                                    color: Colors.grey,
                                  ),
                                  onSelected: (value) {
                                    if (value == 'delete') {
                                      _deleteConversation(conversation);
                                    }
                                  },
                                  itemBuilder: (context) => const [
                                    PopupMenuItem(
                                      value: 'delete',
                                      child: Text('Xóa hội thoại'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ],
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
  final double radius;

  const _Avatar({required this.url, this.radius = 20});

  @override
  Widget build(BuildContext context) {
    if (url.isEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: Colors.blue[50],
        child: Icon(
          Icons.person,
          size: radius * 1.1,
          color: AppColors.primaryBlue,
        ),
      );
    }

    return CircleAvatar(
      radius: radius,
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
      partner?['id'] ??
      conversation['partnerId'] ??
      conversation['partner_id'] ??
      conversation['userId'];
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

String _lastMessage(Map<String, dynamic> conversation, String myUserId) {
  final lastMessage =
      _asMap(conversation['lastMessage']) ??
      _asMap(conversation['last_message']) ??
      _asMap(conversation['lastmessage']);

  final messageText = _firstString([
    lastMessage?['content'],
    lastMessage?['message'],
    conversation['lastMessage'],
    conversation['last_message'],
    conversation['lastmessage'],
    conversation['message'],
  ], fallback: 'Nhấn để xem hội thoại');

  if (lastMessage != null && messageText != 'Nhấn để xem hội thoại') {
    final senderMap =
        _asMap(lastMessage['sender']) ?? _asMap(lastMessage['user']) ?? {};
    final senderId =
        senderMap['id']?.toString() ??
        lastMessage['senderId']?.toString() ??
        lastMessage['sender_id']?.toString() ??
        '';
    final senderName = senderMap['name']?.toString() ?? '';
    final partnerId = _partnerId(conversation);
    final isMine =
        (senderId == myUserId) ||
        (senderName == 'Tôi') ||
        (lastMessage['isMine'] == true || lastMessage['mine'] == true) ||
        (senderId.isNotEmpty &&
            partnerId != null &&
            partnerId.isNotEmpty &&
            senderId != partnerId);

    if (isMine) {
      return 'Bạn: $messageText';
    }
  }
  return messageText;
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

bool _matchesSearch(String target, String keyword) {
  final normalizedTarget = target.toLowerCase();
  final normalizedKeyword = keyword.toLowerCase().trim();
  if (normalizedKeyword.isEmpty) return false;

  // Exact match
  if (normalizedTarget.contains(normalizedKeyword)) return true;

  // Split into individual words
  final words = normalizedKeyword
      .split(RegExp(r'\s+'))
      .where((w) => w.isNotEmpty)
      .toList();
  if (words.isEmpty) return false;

  // Check if target contains all words (regardless of order)
  return words.every((word) => normalizedTarget.contains(word));
}
