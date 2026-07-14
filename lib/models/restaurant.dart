import 'package:flutter/material.dart';

// 장소 유형. 지도 마커의 색상/아이콘 구분에 사용한다.
enum RestaurantCategory {
  restaurant,
  cafeDessert,
  attraction;

  String get label => switch (this) {
        RestaurantCategory.restaurant => '식당',
        RestaurantCategory.cafeDessert => '카페·디저트',
        RestaurantCategory.attraction => '관광명소',
      };

  IconData get icon => switch (this) {
        RestaurantCategory.restaurant => Icons.restaurant,
        RestaurantCategory.cafeDessert => Icons.local_cafe,
        RestaurantCategory.attraction => Icons.photo_camera,
      };

  // 맠카님 테마 색상(#00887A)을 기준으로 잡은 카테고리별 마커 색상.
  Color get color => switch (this) {
        RestaurantCategory.restaurant => const Color(0xFF00887A),
        RestaurantCategory.cafeDessert => const Color(0xFFC2740A),
        RestaurantCategory.attraction => const Color(0xFF6B5CE0),
      };
}

// Firestore restaurants 컬렉션과 매핑될 맛집 모델.
// 아직 Firestore 연동 전이라 home_screen.dart에서 더미 데이터로 생성해 사용한다.
class Restaurant {
  final String id;
  final String name;
  final String address;
  final double lat;
  final double lng;
  final String phone;
  final String hours;
  final String menu;
  final String videoId;
  final int viewCount;
  final RestaurantCategory category;

  const Restaurant({
    required this.id,
    required this.name,
    required this.address,
    required this.lat,
    required this.lng,
    required this.phone,
    required this.hours,
    required this.menu,
    required this.videoId,
    required this.viewCount,
    required this.category,
  });
}
