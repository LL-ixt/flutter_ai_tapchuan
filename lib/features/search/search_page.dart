import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_ai_tapchuan/features/search/presentation/bloc/search_cubit.dart';
import 'package:flutter_ai_tapchuan/features/search/presentation/bloc/search_state.dart';
import 'package:flutter_ai_tapchuan/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:flutter_ai_tapchuan/features/profile/presentation/pages/profile_screen.dart';
import '../../core/widgets/post_card.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SearchCubit()
        ..getSavedSearches(token: context.read<AuthCubit>().state.token ?? ''),
      child: const _SearchPageView(),
    );
  }
}

class _SearchPageView extends StatefulWidget {
  const _SearchPageView();

  @override
  State<_SearchPageView> createState() => _SearchPageViewState();
}

class _SearchPageViewState extends State<_SearchPageView> {
  // Biến điều khiển thanh nhập văn bản
  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        titleSpacing: 0,
        title: TextField(
          controller: _searchController,
          autofocus: true,
          onChanged: (value) {
            setState(() {
              _searchQuery = value;
            });
          },
          onSubmitted: (value) {
            if (value.trim().isNotEmpty) {
              final authToken = context.read<AuthCubit>().state.token;
              final userId = context.read<AuthCubit>().state.userId ?? '';
              context.read<SearchCubit>().search(
                token: authToken ?? '',
                keyword: value.trim(),
                userId: userId,
              );
            }
          },
          decoration: InputDecoration(
            hintText: 'Tìm kiếm trên EduSocial...',
            border: InputBorder.none,
            prefixIcon: const Icon(Icons.search, color: Colors.grey),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.close, color: Colors.grey),
                    onPressed: () {
                      setState(() {
                        _searchController.clear();
                        _searchQuery = '';
                      });
                    },
                  )
                : null,
          ),
        ),
      ),
      body: _searchQuery.isEmpty
          ? _buildRecentSearches()
          : _buildSearchResults(),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // GIAO DIỆN 1: MÀN HÌNH LỊCH SỬ TÌM KIẾM
  Widget _buildRecentSearches() {
    return BlocBuilder<SearchCubit, SearchState>(
      builder: (context, state) {
        if (state is SavedSearchLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is SavedSearchLoaded) {
          final searches = state.searches;

          if (searches.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Không có lịch sử tìm kiếm',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
            );
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Tìm kiếm gần đây',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          // Xóa tất cả tìm kiếm
                          final authToken = context
                              .read<AuthCubit>()
                              .state
                              .token;
                          context.read<SearchCubit>().deleteAllSearches(
                            token: authToken ?? '',
                          );
                        },
                        child: const Text(
                          'XÓA TẤT CẢ',
                          style: TextStyle(color: Colors.blue),
                        ),
                      ),
                    ],
                  ),
                ),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: searches.length,
                  itemBuilder: (context, index) {
                    final search = searches[index];
                    return ListTile(
                      leading: const Icon(Icons.search, color: Colors.grey),
                      title: Text(search['keyword'] ?? ''),
                      trailing: IconButton(
                        icon: const Icon(
                          Icons.close,
                          size: 20,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          // Xóa 1 mục tìm kiếm
                          final authToken =
                              context.read<AuthCubit>().state.token ?? '';
                          context.read<SearchCubit>().deleteSearch(
                            token: authToken,
                            searchId: search['search_id'] ?? '',
                          );
                        },
                      ),
                      onTap: () {
                        setState(() {
                          _searchController.text = search['keyword'] ?? '';
                          _searchQuery = search['keyword'] ?? '';
                        });
                        // Thực hiện tìm kiếm
                        final authToken = context.read<AuthCubit>().state.token;
                        final userId =
                            context.read<AuthCubit>().state.userId ?? '';
                        context.read<SearchCubit>().search(
                          token: authToken ?? '',
                          keyword: search['keyword'] ?? '',
                          userId: userId,
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          );
        } else if (state is SavedSearchError) {
          return Center(
            child: Text(
              state.message,
              style: const TextStyle(color: Colors.red),
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  // GIAO DIỆN 2: MÀN HÌNH KẾT QUẢ TÌM KIẾM
  Widget _buildSearchResults() {
    return BlocBuilder<SearchCubit, SearchState>(
      builder: (context, state) {
        if (state is SearchLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is SearchLoaded) {
          final data = state.results;
          final rawUsers = (data['users'] as List<dynamic>?) ?? [];
          final rawPosts = (data['posts'] as List<dynamic>?) ?? [];

          final users = rawUsers.where((u) {
            if (u is! Map<String, dynamic>) return false;
            final username = u['username']?.toString() ?? '';
            final name = u['name']?.toString() ?? '';
            return _matchesSearch(username, _searchQuery) ||
                _matchesSearch(name, _searchQuery);
          }).toList();

          final posts = rawPosts
              .where((p) {
                if (p is! Map<String, dynamic>) return false;
                final described = p['described']?.toString() ?? '';
                final title = p['title']?.toString() ?? '';
                final author = p['author'] is Map ? p['author'] as Map : {};
                final authorName = author['name']?.toString() ?? '';
                final authorUsername = author['username']?.toString() ?? '';

                return _matchesSearch(described, _searchQuery) ||
                    _matchesSearch(title, _searchQuery) ||
                    _matchesSearch(authorName, _searchQuery) ||
                    _matchesSearch(authorUsername, _searchQuery);
              })
              .map((e) {
                final postMap = Map<String, dynamic>.from(e as Map);
                if (postMap.containsKey('post_id')) {
                  postMap['id'] = postMap['post_id'];
                }
                if (postMap.containsKey('is_liked')) {
                  postMap['isLiked'] = postMap['is_liked'].toString() == '1';
                }
                if (postMap.containsKey('created')) {
                  postMap['created_at'] = postMap['created'];
                }
                return postMap;
              })
              .toList();

          if (users.isEmpty && posts.isEmpty) {
            return Center(
              child: Text(
                'Không tìm thấy kết quả cho "$_searchQuery"',
                style: TextStyle(color: Colors.grey[600]),
              ),
            );
          }

          return DefaultTabController(
            length: 3,
            child: Column(
              children: [
                const TabBar(
                  labelColor: Colors.blue,
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: Colors.blue,
                  tabs: [
                    Tab(text: "Tất cả"),
                    Tab(text: "Người dùng"),
                    Tab(text: "Bài viết"),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      Builder(
                        builder: (ctx) => _buildAllTab(ctx, users, posts),
                      ),
                      _buildUsersTab(users),
                      _buildPostsTab(posts),
                    ],
                  ),
                ),
              ],
            ),
          );
        } else if (state is SearchError) {
          return Center(
            child: Text(
              state.message,
              style: const TextStyle(color: Colors.red),
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildAllTab(
    BuildContext context,
    List<dynamic> users,
    List<dynamic> posts,
  ) {
    return CustomScrollView(
      slivers: [
        if (users.isNotEmpty) ...[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Người dùng',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () {
                      DefaultTabController.of(context).animateTo(1);
                    },
                    child: const Text('Xem tất cả'),
                  ),
                ],
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final user = users[index] as Map<String, dynamic>;
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(
                    user['avatar'] ?? "https://i.pravatar.cc/150",
                  ),
                ),
                title: Text(
                  user['username'] ?? 'Không tên',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(user['role'] == 'GV' ? 'Giáo viên' : 'Học viên'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProfileScreen(
                        userId:
                            user['id']?.toString() ??
                            user['user_id']?.toString() ??
                            '',
                      ),
                    ),
                  );
                },
              );
            }, childCount: users.length > 3 ? 3 : users.length),
          ),
          const SliverToBoxAdapter(
            child: Divider(thickness: 8, color: Color(0xFFE5E6EB)),
          ),
        ],
        if (posts.isNotEmpty) ...[
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Text(
                'Bài viết',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final post = posts[index] as Map<String, dynamic>;
              return PostCard(
                postData: post,
                isLiked: post['is_felt'] == '1' || post['is_felt'] == 1,
                onLikeToggle: () {},
              );
            }, childCount: posts.length),
          ),
        ],
      ],
    );
  }

  Widget _buildUsersTab(List<dynamic> users) {
    if (users.isEmpty)
      return const Center(child: Text("Không có người dùng nào."));
    return ListView.builder(
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index] as Map<String, dynamic>;
        return ListTile(
          leading: CircleAvatar(
            backgroundImage: NetworkImage(
              user['avatar'] ?? "https://i.pravatar.cc/150",
            ),
          ),
          title: Text(
            user['username'] ?? 'Không tên',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(user['role'] == 'GV' ? 'Giáo viên' : 'Học viên'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ProfileScreen(
                  userId:
                      user['id']?.toString() ??
                      user['user_id']?.toString() ??
                      '',
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPostsTab(List<dynamic> posts) {
    if (posts.isEmpty)
      return const Center(child: Text("Không có bài viết nào."));
    // Sử dụng ListView.builder để tạo List scrollable và render tăng dần giúp tối ưu thời gian load
    return ListView.builder(
      itemCount: posts.length,
      itemBuilder: (context, index) {
        final post = posts[index] as Map<String, dynamic>;
        return Column(
          children: [
            PostCard(
              postData: post,
              isLiked: post['is_felt'] == '1' || post['is_felt'] == 1,
              onLikeToggle: () {},
            ),
            const Divider(
              thickness: 8,
              color: Color(0xFFE5E6EB),
            ), // Facebook style divider
          ],
        );
      },
    );
  }

  String _removeDiacritics(String str) {
    var withDiacritics =
        'àáạảãâầấậẩẫăằắặẳẵèéẹẻẽêềếệểễìíịỉĩòóọỏõôồốộổỗơờớợởỡùúụủũưừứựửữỳýỵỷỹđÀÁẠẢÃÂẦẤẬẨẪĂẰẮẶẲẴÈÉẸẺẼÊỀẾỆỂỄÌÍỊỈĨÒÓỌỎÕÔỒỐỘỔỖƠỜỚỢỞỠÙÚỤỦŨƯỪỨỰỬỮỲÝỴỶỸĐ';
    var withoutDiacritics =
        'aaaaaaaaaaaaaaaaaeeeeeeeeeeeiiiiiooooooooooooooooouuuuuuuuuuuyyyyydAAAAAAAAAAAAAAAAAEEEEEEEEEEEIIIIIOOOOOOOOOOOOOOOOOOUUUUUUUUUUUYYYYYD';

    for (int i = 0; i < withDiacritics.length; i++) {
      str = str.replaceAll(withDiacritics[i], withoutDiacritics[i]);
    }
    return str;
  }

  bool _matchesSearch(String target, String keyword) {
    final normalizedTarget = _removeDiacritics(target.toLowerCase());
    final normalizedKeyword = _removeDiacritics(keyword.toLowerCase().trim());
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
}
