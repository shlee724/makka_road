import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:permission_handler/permission_handler.dart';

import '../models/restaurant.dart';
import 'restaurant_detail_sheet.dart';

// 하드코딩된 샘플 맛집 3개 (나중에 Firestore로 교체).
// address/phone/hours/menu/videoId/viewCount는 화면 2 테스트용 더미 데이터.
const _sampleRestaurants = [
  Restaurant(
    id: '진앤키노',
    name: '진앤키노',
    address: '대전 대덕구 오정동 175-45',
    lat: 36.3519,
    lng: 127.4250,
    phone: '042-000-0001',
    hours: '매일 22:00 - 다음 날 05:00 (월, 수 정기휴무)',
    menu: '오믈렛',
    videoId: 'YHTMM5YXpQU',
    viewCount: 13600000,
    category: RestaurantCategory.restaurant,
  ),
  Restaurant(
    id: '목수정',
    name: '목수정',
    address: '대전 중구 오류동 158-3',
    lat: 36.3226,
    lng: 127.4086,
    phone: '042-522-5512',
    hours: '매일 12:00 - 22:00',
    menu: '치즈 한 모, 자몽 쥬스',
    videoId: 'Ds3DwK8fdhQ',
    viewCount: 4950000,
    category: RestaurantCategory.cafeDessert,
  ),
  Restaurant(
    id: '성심당',
    name: '성심당',
    address: '대전 중구 대종로480번길 15',
    lat: 36.3286,
    lng: 127.4276,
    phone: '042-000-0003',
    hours: '매일 08:00 - 22:00',
    menu: '튀김소보로, 부추빵',
    videoId: 'BIxmp63YnFE',
    viewCount: 2980000,
    category: RestaurantCategory.cafeDessert,
  ),
];

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  NaverMapController? _mapController;

  Future<void> _onMapReady(NaverMapController controller) async {
    _mapController = controller;

    // 카테고리별 마커 아이콘은 한 번씩만 만들어서 재사용한다.
    final categoryIcons = <RestaurantCategory, NOverlayImage>{};
    for (final category in RestaurantCategory.values) {
      categoryIcons[category] = await NOverlayImage.fromWidget(
        context: context,
        size: const Size(36, 36),
        widget: _CategoryMarkerIcon(category: category),
      );
    }

    // 마커 3개 생성 후 지도에 추가
    final Set<NAddableOverlay> overlays = {};
    for (final restaurant in _sampleRestaurants) {
      final marker = NMarker(
        id: restaurant.id,
        position: NLatLng(restaurant.lat, restaurant.lng),
        icon: categoryIcons[restaurant.category],
      );
      marker.setOnTapListener((_) {
        showRestaurantDetailSheet(context, restaurant);
      });
      overlays.add(marker);
    }
    await controller.addOverlayAll(overlays);
  }

  Future<void> _goToMyLocation() async {
    final status = await Permission.location.request();
    if (!mounted) return;

    if (status.isGranted) {
      _mapController?.setLocationTrackingMode(NLocationTrackingMode.follow);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('위치 권한이 필요합니다.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NaverMap(
        options: const NaverMapViewOptions(
          initialCameraPosition: NCameraPosition(
            target: NLatLng(36.3504, 127.3845), // 대전 중심
            zoom: 12,
          ),
          locationButtonEnable: false,
        ),
        onMapReady: _onMapReady,
      ),
      // 배너를 bottomNavigationBar 자리에 배치 — 지도 레이어 바깥이라 항상 보임
      // SafeArea로 감싸서 회색 영역이 시스템 내비게이션 바(홈/뒤로가기 컨트롤) 위로 올라오게 함.
      // 회색은 Container 전체(SafeArea 바깥 포함)에 칠해서 시스템 바 뒤까지 이어지게 하고,
      // 실제 배너 높이(50)는 컨트롤에 가리지 않는 안전 영역 안에 배치.
      bottomNavigationBar: Container(
        color: Colors.grey[200],
        child: const SafeArea(
          child: SizedBox(height: 50),
        ),
      ),
      // 내 위치 FAB — 탭하면 위치 권한 요청 후 지도 이동
      floatingActionButton: FloatingActionButton(
        onPressed: _goToMyLocation,
        child: const Icon(Icons.my_location),
      ),
    );
  }
}

// 마커 아이콘: 카테고리 색상 원 안에 카테고리 아이콘.
class _CategoryMarkerIcon extends StatelessWidget {
  final RestaurantCategory category;

  const _CategoryMarkerIcon({required this.category});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: category.color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: Icon(category.icon, color: Colors.white, size: 18),
    );
  }
}
