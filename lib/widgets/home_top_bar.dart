import 'package:flutter/material.dart';

import '../models/restaurant.dart';
import 'filter_button.dart';
import 'map_filter_chips.dart';
import 'restaurant_search_bar.dart';

// 지도 위에 떠 있는 검색창 + 카테고리 필터 버튼 + 즐겨찾기/조회수 필터칩 묶음.
class HomeTopBar extends StatelessWidget {
  final List<Restaurant> restaurants;
  final Future<void> Function(Restaurant restaurant) onSelectRestaurant;
  final bool isCategoryFilterActive;
  final VoidCallback onCategoryFilterTap;
  final bool favoritesOnly;
  final ValueChanged<bool> onFavoritesChanged;
  final int? selectedThreshold;
  final ValueChanged<int?> onThresholdChanged;

  const HomeTopBar({
    super.key,
    required this.restaurants,
    required this.onSelectRestaurant,
    required this.isCategoryFilterActive,
    required this.onCategoryFilterTap,
    required this.favoritesOnly,
    required this.onFavoritesChanged,
    required this.selectedThreshold,
    required this.onThresholdChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: RestaurantSearchBar(
                    restaurants: restaurants,
                    onSelect: onSelectRestaurant,
                  ),
                ),
                const SizedBox(width: 8),
                FilterButton(
                  isActive: isCategoryFilterActive,
                  onPressed: onCategoryFilterTap,
                ),
              ],
            ),
            const SizedBox(height: 8),
            MapFilterChips(
              favoritesOnly: favoritesOnly,
              onFavoritesChanged: onFavoritesChanged,
              selectedThreshold: selectedThreshold,
              onThresholdChanged: onThresholdChanged,
            ),
          ],
        ),
      ),
    );
  }
}
