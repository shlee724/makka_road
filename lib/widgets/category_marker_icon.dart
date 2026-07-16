import 'package:flutter/material.dart';

import '../models/restaurant.dart';

// 즐겨찾기 마커 테두리: 금색보다 눈에 잘 띄는 형광 라임색.
const favoriteBorderColor = Color(0xFF39FF14);

// 마커 아이콘: 카테고리 색상 원 안에 카테고리 아이콘.
// 즐겨찾기한 곳은 테두리를 금색으로 바꾸고 우측 상단에 별 배지를 붙인다.
class CategoryMarkerIcon extends StatelessWidget {
  final RestaurantCategory category;
  final bool isFavorite;

  const CategoryMarkerIcon({
    super.key,
    required this.category,
    required this.isFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: category.color,
            shape: BoxShape.circle,
            border: Border.all(
              color: isFavorite ? favoriteBorderColor : Colors.white,
              width: isFavorite ? 3 : 2,
            ),
          ),
          child: Icon(category.icon, color: Colors.white, size: category.iconSize),
        ),
        if (isFavorite)
          const Positioned(
            top: 0,
            right: 0,
            child: Icon(
              Icons.star,
              color: Colors.amber,
              size: 14,
              shadows: [Shadow(color: Colors.black54, blurRadius: 2)],
            ),
          ),
      ],
    );
  }
}
