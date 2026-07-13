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
  _Restaurant(name: '진천식당', lat: 36.3522, lng: 127.3845),
  _Restaurant(name: '팔각도', lat: 36.3627, lng: 127.3472),
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
      body: Stack(
        children: [
          NaverMap(
            options: const NaverMapViewOptions(
              initialCameraPosition: NCameraPosition(
                target: NLatLng(36.3504, 127.3845), // 대전 중심
                zoom: 12,
              ),
              locationButtonEnable: false, // FAB으로 직접 처리
            ),
            onMapReady: _onMapReady,
          ),
          // 하단 배너 자리 (광고 허락 전까지는 빈 영역)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 50,
              color: Colors.grey[200],
            ),
          ),
        ],
      ),
      // 내 위치 FAB — 탭하면 위치 권한 요청 후 지도 이동
      floatingActionButton: FloatingActionButton(
        onPressed: _goToMyLocation,
        child: const Icon(Icons.my_location),
      ),
    );
  }
}
