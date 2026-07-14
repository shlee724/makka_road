import 'package:shared_preferences/shared_preferences.dart';

// 즐겨찾기한 맛집 id를 기기 로컬(shared_preferences)에만 저장한다. 서버 저장/로그인 없음.
class FavoritesService {
  static const _prefsKey = 'favorite_restaurant_ids';

  static Future<Set<String>> getFavoriteIds() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_prefsKey)?.toSet() ?? {};
  }

  static Future<bool> isFavorite(String restaurantId) async {
    final ids = await getFavoriteIds();
    return ids.contains(restaurantId);
  }

  static Future<bool> toggleFavorite(String restaurantId) async {
    final prefs = await SharedPreferences.getInstance();
    final ids = prefs.getStringList(_prefsKey)?.toSet() ?? {};
    final nowFavorite = !ids.contains(restaurantId);
    if (nowFavorite) {
      ids.add(restaurantId);
    } else {
      ids.remove(restaurantId);
    }
    await prefs.setStringList(_prefsKey, ids.toList());
    return nowFavorite;
  }
}
