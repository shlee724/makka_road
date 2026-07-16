import 'package:flutter/material.dart';

// 화면 중앙 하단의 납작한 알약 모양 버튼들(즐겨찾기·목록).
// FloatingActionButton.extended는 높이(56dp 고정)를 줄일 수 없어서
// Material + InkWell로 직접 만들어 높이를 낮췄다.
class PillActionBar extends StatelessWidget {
  final VoidCallback onFavoritesTap;
  final VoidCallback onListTap;

  const PillActionBar({
    super.key,
    required this.onFavoritesTap,
    required this.onListTap,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _PillButton(icon: Icons.star, label: '즐겨찾기', onTap: onFavoritesTap),
          const SizedBox(width: 12),
          _PillButton(icon: Icons.list, label: '목록', onTap: onListTap),
        ],
      ),
    );
  }
}

class _PillButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _PillButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Material(
      elevation: 4,
      color: colorScheme.primaryContainer,
      shape: const StadiumBorder(),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 20, color: colorScheme.onPrimaryContainer),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
