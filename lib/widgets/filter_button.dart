import 'package:flutter/material.dart';

// 검색창 옆 필터 버튼. 카테고리 필터가 하나라도 걸려 있으면(isActive) 강조색으로 표시한다.
class FilterButton extends StatelessWidget {
  final bool isActive;
  final VoidCallback onPressed;

  const FilterButton({
    super.key,
    required this.isActive,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Material(
      elevation: 4,
      shape: const CircleBorder(),
      color: isActive ? colorScheme.primary : Colors.white,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Icon(
            Icons.filter_list,
            color: isActive ? colorScheme.onPrimary : Colors.black87,
          ),
        ),
      ),
    );
  }
}
