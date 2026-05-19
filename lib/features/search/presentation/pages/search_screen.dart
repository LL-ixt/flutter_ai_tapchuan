import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/color_constants.dart';
import '../../../../core/constants/text_style_constants.dart';
import '../../../../core/widgets/post_card.dart';
import '../bloc/search_cubit.dart';
import '../bloc/search_state.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SearchCubit(),
      child: const _SearchView(),
    );
  }
}

class _SearchView extends StatefulWidget {
  const _SearchView();

  @override
  State<_SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<_SearchView> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceWhite,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Tìm kiếm trên Mercari',
            hintStyle: AppTextStyles.bodyMain.copyWith(color: AppColors.textSecondary),
            border: InputBorder.none,
          ),
          style: AppTextStyles.bodyMain,
          onSubmitted: (value) {
            if (value.trim().isNotEmpty) {
              context.read<SearchCubit>().performSearch(value);
            }
          },
          textInputAction: TextInputAction.search,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: AppColors.textSecondary, size: 20),
            onPressed: () {
              _searchController.clear();
              context.read<SearchCubit>().resetToInitial();
            },
          ),
        ],
      ),
      body: BlocBuilder<SearchCubit, SearchState>(
        builder: (context, state) {
          if (state is SearchInitial) {
            return _buildRecentSearches(context, state.recentSearches);
          } else if (state is SearchLoading) {
            return _buildSkeletonLoader();
          } else if (state is SearchSuccess) {
            return _buildSearchResults(state.results);
          } else if (state is SearchError) {
            return Center(child: Text(state.message, style: const TextStyle(color: AppColors.errorRed)));
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildRecentSearches(BuildContext context, List<String> searches) {
    if (searches.isEmpty) {
      return const Center(child: Text('Chưa có tìm kiếm gần đây', style: TextStyle(color: AppColors.textSecondary)));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Tìm kiếm gần đây', style: AppTextStyles.nameHeading),
              GestureDetector(
                onTap: () => context.read<SearchCubit>().clearAllSearches(),
                child: const Text('Xóa tất cả', style: TextStyle(color: AppColors.primaryBlue)),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: searches.length,
            itemBuilder: (context, index) {
              final keyword = searches[index];
              return ListTile(
                leading: const Icon(Icons.search, color: AppColors.textSecondary),
                title: Text(keyword, style: AppTextStyles.bodyMain),
                trailing: IconButton(
                  icon: const Icon(Icons.close, color: AppColors.textSecondary, size: 18),
                  onPressed: () => context.read<SearchCubit>().deleteSearchKeyword(keyword),
                ),
                onTap: () {
                  _searchController.text = keyword;
                  context.read<SearchCubit>().performSearch(keyword);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSkeletonLoader() {
    return ListView.builder(
      itemCount: 3,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          color: AppColors.surfaceWhite,
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(color: Colors.grey[300], shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(width: 120, height: 16, color: Colors.grey[300]),
                      const SizedBox(height: 8),
                      Container(width: 80, height: 12, color: Colors.grey[300]),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(width: double.infinity, height: 16, color: Colors.grey[300]),
              const SizedBox(height: 8),
              Container(width: 200, height: 16, color: Colors.grey[300]),
              const SizedBox(height: 16),
              Container(width: double.infinity, height: 150, color: Colors.grey[300]),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSearchResults(List<Map<String, dynamic>> results) {
    if (results.isEmpty) {
      return const Center(child: Text('Không tìm thấy kết quả nào', style: TextStyle(color: AppColors.textSecondary)));
    }
    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        return PostCard(
          postData: results[index],
          isLiked: false,
          onLikeToggle: () {}, // Giả lập nút Like trong tìm kiếm (có thể add Bloc sau)
        );
      },
    );
  }
}
