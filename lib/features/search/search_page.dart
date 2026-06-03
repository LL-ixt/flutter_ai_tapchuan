import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_ai_tapchuan/features/search/presentation/bloc/search_cubit.dart';
import 'package:flutter_ai_tapchuan/features/search/presentation/bloc/search_state.dart';
import 'package:flutter_ai_tapchuan/features/auth/presentation/bloc/auth_cubit.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SearchCubit()
        ..getSavedSearches(
          token: context.read<AuthCubit>().state.token ?? '',
        ),
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
      body: _searchQuery.isEmpty ? _buildRecentSearches() : _buildSearchResults(),
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
          return const Center(
            child: CircularProgressIndicator(),
          );
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
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      TextButton(
                        onPressed: () {
                          // Xóa tất cả tìm kiếm
                          final authToken = context.read<AuthCubit>().state.token;
                          context.read<SearchCubit>().deleteAllSearches(token: authToken?? '');
                        },
                        child: const Text('XÓA TẤT CẢ', style: TextStyle(color: Colors.blue)),
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
                        icon: const Icon(Icons.close, size: 20, color: Colors.grey),
                        onPressed: () {
                          // Xóa 1 mục tìm kiếm
                          final authToken = context.read<AuthCubit>().state.token ?? '';
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
                        final userId = context.read<AuthCubit>().state.userId ?? '';
                        context.read<SearchCubit>().search(
                          token: authToken??'',
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

  // GIAO DIỆN 2: MÀN HÌNH KẾT QUẢ (BÀI VIẾT TỪ API)
  Widget _buildSearchResults() {
    return BlocBuilder<SearchCubit, SearchState>(
      builder: (context, state) {
        if (state is SearchLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (state is SearchLoaded) {
          final results = (state.results['posts'] as List<dynamic>?) ?? [];

          if (results.isEmpty) {
            return Center(
              child: Text(
                'Không tìm thấy kết quả cho "$_searchQuery"',
                style: TextStyle(color: Colors.grey[600]),
              ),
            );
          }

          return ListView.builder(
            itemCount: results.length,
            itemBuilder: (context, index) {
              final post = results[index] as Map<String, dynamic>;
              final author = post['author'] ?? {};
              
              return Card(
                elevation: 0,
                margin: const EdgeInsets.symmetric(vertical: 4.0),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.grey[300],
                            backgroundImage: author['avatar'] != null
                                ? NetworkImage(author['avatar'] as String)
                                : null,
                            child: author['avatar'] == null
                                ? const Icon(Icons.person, color: Colors.white)
                                : null,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  author['username'] ?? 'Unknown',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  post['created_at'] ?? '',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        post['described'] ?? '',
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            },
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
}