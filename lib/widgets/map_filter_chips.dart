import 'package:flutter/material.dart';

// 지도 위 검색창 아래에 뜨는 필터칩 행.
// '즐겨찾기'는 온/오프 토글이고, 조회수 임계값(100만/50만/10만 이상) 3개는
// 라디오처럼 하나만 선택된다. 선택된 임계값 칩을 다시 누르면 해제되어
// 전체 가게가 다시 보인다.
class MapFilterChips extends StatelessWidget {
  final bool favoritesOnly;
  final ValueChanged<bool> onFavoritesChanged;
  final int? selectedThreshold;
  final ValueChanged<int?> onThresholdChanged;

  const MapFilterChips({
    super.key,
    required this.favoritesOnly,
    required this.onFavoritesChanged,
    required this.selectedThreshold,
    required this.onThresholdChanged,
  });

  static const List<int> thresholds = [1000000, 500000, 100000];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    // SingleChildScrollView(horizontal)는 세로 크기를 부모(Column)로부터
    // 명확히 받지 못하면 레이아웃 에러가 나서 높이를 SizedBox로 고정한다.
    return SizedBox(
      height: 36,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                avatar: Icon(
                  Icons.star,
                  size: 18,
                  color: favoritesOnly ? colorScheme.onPrimary : null,
                ),
                label: const Text('즐겨찾기'),
                selected: favoritesOnly,
                onSelected: onFavoritesChanged,
                showCheckmark: false,
                backgroundColor: colorScheme.surface,
                selectedColor: colorScheme.primary,
                labelStyle: TextStyle(
                  color: favoritesOnly
                      ? colorScheme.onPrimary
                      : colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
                side: BorderSide.none,
              ),
            ),
            for (final threshold in thresholds)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text('${threshold ~/ 10000}만 이상'),
                  selected: selectedThreshold == threshold,
                  onSelected: (selected) =>
                      onThresholdChanged(selected ? threshold : null),
                  showCheckmark: false,
                  backgroundColor: colorScheme.surface,
                  selectedColor: colorScheme.primary,
                  labelStyle: TextStyle(
                    color: selectedThreshold == threshold
                        ? colorScheme.onPrimary
                        : colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                  side: BorderSide.none,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
