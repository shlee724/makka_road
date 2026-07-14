import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:permission_handler/permission_handler.dart';

// 하드코딩된 샘플 맛집 3개 (나중에 Firestore로 교체)
class _Restaurant {
  final String name;
  final double lat;
  final double lng;

  const _Restaurant({required this.name, required this.lat, required this.lng});
}

const _sampleRestaurants = [
  _Restaurant(name: '진앤키노', lat: 36.3519, lng: 127.4250),
  _Restaurant(name: '목수정', lat: 36.3226, lng: 127.4086),
  _Restaurant(name: '성심당', lat: 36.3286, lng: 127.4276),
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

    // 마커 3개 생성 후 지도에 추가
    final Set<NAddableOverlay> overlays = {};
    for (final restaurant in _sampleRestaurants) {
      final marker = NMarker(
        id: restaurant.name,
        position: NLatLng(restaurant.lat, restaurant.lng),
      );
      marker.setOnTapListener((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(restaurant.name),
            duration: const Duration(seconds: 1),
          ),
        );
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
