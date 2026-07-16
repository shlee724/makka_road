import 'package:flutter/material.dart';

import '../models/restaurant.dart';
import '../utils/view_count_format.dart';

enum _SortOrder { viewCount, latest }

// '목록' 버튼으로 여는 시트. 지도에 현재 필터로 걸러진 가게들을 정렬해서 보여주고,
// 항목을 탭하면 시트를 닫고 그 가게로 이동시킨다 (즐겨찾기 목록과 같은 흐름).
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
  _SortOrder _sortOrder = _SortOrder.viewCount;

  List<Restaurant> get _sortedRestaurants {
    final sorted = [...widget.restaurants];
    switch (_sortOrder) {
      case _SortOrder.viewCount:
        sorted.sort((a, b) => b.viewCount.compareTo(a.viewCount));
      case _SortOrder.latest:
        sorted.sort((a, b) => b.publishedAt.compareTo(a.publishedAt));
    }
    return sorted;
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        final restaurants = _sortedRestaurants;
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
                  child: Row(
                    children: [
                      ChoiceChip(
                        label: const Text('조회수순'),
                        selected: _sortOrder == _SortOrder.viewCount,
                        onSelected: (_) =>
                            setState(() => _sortOrder = _SortOrder.viewCount),
                      ),
                      const SizedBox(width: 8),
                      ChoiceChip(
                        label: const Text('최신순'),
                        selected: _sortOrder == _SortOrder.latest,
                        onSelected: (_) =>
                            setState(() => _sortOrder = _SortOrder.latest),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 17),
                Expanded(
                  child: restaurants.isEmpty
                      ? const Center(child: Text('조건에 맞는 맛집이 없어요'))
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
                                _sortOrder == _SortOrder.viewCount
                                    ? viewCountLabel(restaurant.viewCount)
                                    : restaurant.address,
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
