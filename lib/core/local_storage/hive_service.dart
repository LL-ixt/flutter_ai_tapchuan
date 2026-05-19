import 'package:hive_flutter/hive_flutter.dart';

class HiveService {
  static const String cachedPostsBox = 'cached_posts';
  static const String searchHistoryBox = 'search_history';

  static Future<void> initHive() async {
    await Hive.initFlutter();
    await Hive.openBox(cachedPostsBox);
    await Hive.openBox(searchHistoryBox);
  }
}
