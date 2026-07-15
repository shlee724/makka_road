import 'package:cloud_firestore/cloud_firestore.dart';
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

  // upload_to_firestore.py가 videoId를 문서 ID로 사용해 업로드하므로 doc.id와 일치한다.
  factory Restaurant.fromFirestore(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();
    return Restaurant(
      id: doc.id,
      name: data['name'] as String,
      address: data['address'] as String,
      lat: (data['lat'] as num).toDouble(),
      lng: (data['lng'] as num).toDouble(),
      // 관광명소 등은 전화/영업시간/메뉴가 없을 수 있어 비워둔 값을 허용한다.
      phone: data['phone'] as String? ?? '',
      hours: data['hours'] as String? ?? '',
      menu: data['menu'] as String? ?? '',
      videoId: data['videoId'] as String,
      viewCount: (data['viewCount'] as num).toInt(),
      category: RestaurantCategory.values.byName(data['category'] as String),
    );
  }
}
