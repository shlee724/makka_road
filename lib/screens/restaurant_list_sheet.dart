import 'package:flutter/material.dart';

import '../models/restaurant.dart';
import '../services/favorites_service.dart';
import '../utils/view_count_format.dart';

enum _ListMode { viewCount, latest, favorites }

// '목록' 버튼으로 여는 시트. 지도에 현재 필터로 걸러진 가게들을 조회수순/최신순으로
// 정렬해서 보여주거나, '즐겨찾기' 탭으로 즐겨찾기한 가게만 보여준다.
// 항목을 탭하면 시트를 닫고 그 가게로 이동시킨다.
Future<void> showRestaurantListSheet(
  BuildContext context, {
  required List<Restaurant> restaurants,
  required ValueChanged<Restaurant> onSelect,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _RestaurantListSheetContent(
      restaurants: restaurants,
      onSelect: onSelect,
    ),
  );
}

class _RestaurantListSheetContent extends StatefulWidget {
  final List<Restaurant> restaurants;
  final ValueChanged<Restaurant> onSelect;

  const _RestaurantListSheetContent({
    required this.restaurants,
    required this.onSelect,
  });

  @override
  State<_RestaurantListSheetContent> createState() =>
      _RestaurantListSheetContentState();
}

class _RestaurantListSheetContentState
    extends State<_RestaurantListSheetContent> {
  _ListMode _mode = _ListMode.viewCount;
  Set<String> _favoriteIds = {};

  @override
  void initState() {
    super.initState();
    _loadFavoriteIds();
  }

  Future<void> _loadFavoriteIds() async {
    final ids = await FavoritesService.getFavoriteIds();
    if (mounted) setState(() => _favoriteIds = ids);
  }

  List<Restaurant> get _displayedRestaurants {
    if (_mode == _ListMode.favorites) {
      return widget.restaurants
          .where((r) => _favoriteIds.contains(r.id))
          .toList();
    }
    final sorted = [...widget.restaurants];
    if (_mode == _ListMode.viewCount) {
      sorted.sort((a, b) => b.viewCount.compareTo(a.viewCount));
    } else {
      sorted.sort((a, b) => b.publishedAt.compareTo(a.publishedAt));
    }
    return sorted;
  }

  // 조회수순/최신순은 각각 조회수·주소를 보여주고, 즐겨찾기는 추천메뉴를 보여준다.
  // 관광명소 등 메뉴가 없는 곳은 주소로 대신한다.
  String _subtitleFor(Restaurant restaurant) {
    switch (_mode) {
      case _ListMode.viewCount:
        return viewCountLabel(restaurant.viewCount);
      case _ListMode.latest:
        return restaurant.address;
      case _ListMode.favorites:
        return restaurant.menu.isEmpty ? restaurant.address : restaurant.menu;
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        final restaurants = _displayedRestaurants;
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: Row(
                    children: [
                      const Text(
                        '맛집 목록',
                        style:
                            TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${restaurants.length}곳',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        ChoiceChip(
                          label: const Text('조회수순'),
                          selected: _mode == _ListMode.viewCount,
                          onSelected: (_) =>
                              setState(() => _mode = _ListMode.viewCount),
                        ),
                        const SizedBox(width: 8),
                        ChoiceChip(
                          label: const Text('최신순'),
                          selected: _mode == _ListMode.latest,
                          onSelected: (_) =>
                              setState(() => _mode = _ListMode.latest),
                        ),
                        const SizedBox(width: 8),
                        ChoiceChip(
                          avatar: const Icon(Icons.star, size: 18),
                          label: const Text('즐겨찾기'),
                          selected: _mode == _ListMode.favorites,
                          onSelected: (_) =>
                              setState(() => _mode = _ListMode.favorites),
                        ),
                      ],
                    ),
                  ),
                ),
                const Divider(height: 17),
                Expanded(
                  child: restaurants.isEmpty
                      ? Center(
                          child: Text(
                            _mode == _ListMode.favorites
                                ? '즐겨찾기한 맛집이 없어요'
                                : '조건에 맞는 맛집이 없어요',
                          ),
                        )
                      : ListView.separated(
                          controller: scrollController,
                          itemCount: restaurants.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final restaurant = restaurants[index];
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor: restaurant.category.color,
                                foregroundColor: Colors.white,
                                child: Icon(restaurant.category.icon),
                              ),
                              title: Text(restaurant.name),
                              subtitle: Text(
                                _subtitleFor(restaurant),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () {
                                Navigator.pop(context);
                                widget.onSelect(restaurant);
                              },
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
