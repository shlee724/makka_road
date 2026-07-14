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
  });
}
