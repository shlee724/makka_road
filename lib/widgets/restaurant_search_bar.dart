import 'package:flutter/material.dart';

import '../models/restaurant.dart';

// 지도 위에 떠 있는 검색창. 가게 이름으로 필터링해 결과를 아래에 목록으로 보여준다.
class RestaurantSearchBar extends StatefulWidget {
  final List<Restaurant> restaurants;
  final Future<void> Function(Restaurant restaurant) onSelect;

  const RestaurantSearchBar({
    super.key,
    required this.restaurants,
    required this.onSelect,
  });

  @override
  State<RestaurantSearchBar> createState() => _RestaurantSearchBarState();
}

class _RestaurantSearchBarState extends State<RestaurantSearchBar> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  List<Restaurant> _results = [];

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onChanged(String query) {
    final trimmed = query.trim();
    setState(() {
      _results = trimmed.isEmpty
          ? []
          : widget.restaurants
              .where((r) => r.name.contains(trimmed))
              .toList();
    });
  }

  Future<void> _select(Restaurant restaurant) async {
    _focusNode.unfocus();
    _controller.clear();
    setState(() => _results = []);

    // 상세 시트가 떠 있는 동안은 검색창이 다시 포커스를 가져가지 못하게 막는다.
    // 그렇지 않으면 시트를 닫을 때 라우트가 팝되면서 이전 포커스(검색창)가
    // 자동으로 복원되어 키보드가 다시 튀어나온다.
    _focusNode.canRequestFocus = false;
    await widget.onSelect(restaurant);
    _focusNode.canRequestFocus = true;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        Material(
          elevation: 4,
          borderRadius: BorderRadius.circular(28),
          child: TextField(
            controller: _controller,
            focusNode: _focusNode,
            onChanged: _onChanged,
            decoration: InputDecoration(
              hintText: '가게 이름 검색',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _controller.text.isEmpty
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _controller.clear();
                        _onChanged('');
                      },
                    ),
              filled: true,
              fillColor: colorScheme.surface,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(28),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        if (_results.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 8),
            constraints: const BoxConstraints(maxHeight: 240),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 2)),
              ],
            ),
            child: ListView.separated(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              itemCount: _results.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final restaurant = _results[index];
                return ListTile(
                  leading: Icon(restaurant.category.icon, color: restaurant.category.color),
                  title: Text(restaurant.name),
                  subtitle: Text(
                    restaurant.address,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: () => _select(restaurant),
                );
              },
            ),
          ),
      ],
    );
  }
}
