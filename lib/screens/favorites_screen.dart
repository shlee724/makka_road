import 'package:flutter/material.dart';

import '../data/sample_restaurants.dart';
import '../models/restaurant.dart';
import '../services/favorites_service.dart';

// 즐겨찾기한 맛집 목록. 항목을 탭하면 그 가게를 Navigator.pop으로 반환해서,
// 호출한 화면(지도)이 해당 마커로 이동시키도록 한다.
class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<Restaurant> _favorites = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final favoriteIds = await FavoritesService.getFavoriteIds();
    if (!mounted) return;
    setState(() {
      _favorites =
          sampleRestaurants.where((r) => favoriteIds.contains(r.id)).toList();
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('즐겨찾기')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _favorites.isEmpty
              ? const Center(child: Text('즐겨찾기한 맛집이 없어요'))
              : ListView.separated(
                  itemCount: _favorites.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final restaurant = _favorites[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: restaurant.category.color,
                        foregroundColor: Colors.white,
                        child: Icon(restaurant.category.icon),
                      ),
                      title: Text(restaurant.name),
                      subtitle: Text(
                        restaurant.address,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => Navigator.pop(context, restaurant),
                    );
                  },
                ),
    );
  }
}
