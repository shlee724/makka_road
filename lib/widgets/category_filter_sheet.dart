import 'package:flutter/material.dart';

import '../models/restaurant.dart';

// 카테고리 체크리스트 필터 바텀시트. 체크할 때마다 즉시 onChanged로 알려서
// 지도 마커가 실시간으로 필터링되고, '완료'를 누르면 시트만 닫는다.
Future<void> showCategoryFilterSheet(
  BuildContext context, {
  required Set<RestaurantCategory> selected,
  required ValueChanged<Set<RestaurantCategory>> onChanged,
}) {
  return showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => _CategoryFilterSheetContent(
      selected: selected,
      onChanged: onChanged,
    ),
  );
}

class _CategoryFilterSheetContent extends StatefulWidget {
  final Set<RestaurantCategory> selected;
  final ValueChanged<Set<RestaurantCategory>> onChanged;

  const _CategoryFilterSheetContent({
    required this.selected,
    required this.onChanged,
  });

  @override
  State<_CategoryFilterSheetContent> createState() =>
      _CategoryFilterSheetContentState();
}

class _CategoryFilterSheetContentState
    extends State<_CategoryFilterSheetContent> {
  final Set<RestaurantCategory> _selected = {};

  @override
  void initState() {
    super.initState();
    _selected.addAll(widget.selected);
  }

  void _toggle(RestaurantCategory category, bool checked) {
    setState(() {
      if (checked) {
        _selected.add(category);
      } else {
        _selected.remove(category);
      }
    });
    widget.onChanged(_selected);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 16, 20, 4),
            child: Row(
              children: [
                Text(
                  '카테고리 필터',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          for (final category in RestaurantCategory.values)
            CheckboxListTile(
              value: _selected.contains(category),
              onChanged: (checked) => _toggle(category, checked ?? false),
              title: Text('${category.label}만'),
              secondary: Icon(category.icon, color: category.color),
              controlAffinity: ListTileControlAffinity.leading,
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('완료'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
