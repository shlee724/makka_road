import 'package:flutter/material.dart';

// 조회수 임계값 필터칩(100만/50만/10만 이상). 라디오처럼 하나만 선택되고,
// 선택된 칩을 다시 누르면 임계값이 해제되어 전체 가게가 다시 보인다.
class ViewCountFilterChips extends StatelessWidget {
  final int? selectedThreshold;
  final ValueChanged<int?> onChanged;

  const ViewCountFilterChips({
    super.key,
    required this.selectedThreshold,
    required this.onChanged,
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
            for (final threshold in thresholds)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text('${threshold ~/ 10000}만 이상'),
                  selected: selectedThreshold == threshold,
                  onSelected: (selected) =>
                      onChanged(selected ? threshold : null),
                  showCheckmark: false,
                  backgroundColor: Colors.white,
                  selectedColor: colorScheme.primary,
                  labelStyle: TextStyle(
                    color: selectedThreshold == threshold
                        ? colorScheme.onPrimary
                        : Colors.black87,
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
