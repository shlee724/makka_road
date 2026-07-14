import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:permission_handler/permission_handler.dart';

import '../models/restaurant.dart';
import '../services/favorites_service.dart';
import '../widgets/restaurant_search_bar.dart';
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
  final Map<String, NMarker> _markersById = {};
  Map<String, NOverlayImage> _markerIcons = {};

  Future<void> _onMapReady(NaverMapController controller) async {
    _mapController = controller;

    final favoriteIds = await FavoritesService.getFavoriteIds();

    // (카테고리, 즐겨찾기 여부) 조합별 마커 아이콘을 한 번씩만 만들어서 재사용한다.
    final markerIcons = <String, NOverlayImage>{};
    for (final category in RestaurantCategory.values) {
      for (final isFavorite in [false, true]) {
        if (!mounted) return;
        markerIcons[_markerIconKey(category, isFavorite)] =
            await NOverlayImage.fromWidget(
          context: context,
          size: const Size(36, 36),
          widget: _CategoryMarkerIcon(category: category, isFavorite: isFavorite),
        );
      }
    }
    _markerIcons = markerIcons;

    // 마커 3개 생성 후 지도에 추가
    final Set<NAddableOverlay> overlays = {};
    for (final restaurant in _sampleRestaurants) {
      final marker = NMarker(
        id: restaurant.id,
        position: NLatLng(restaurant.lat, restaurant.lng),
        icon: markerIcons[_markerIconKey(
          restaurant.category,
          favoriteIds.contains(restaurant.id),
        )],
      );
      marker.setOnTapListener((_) => _openRestaurant(restaurant));
      _markersById[restaurant.id] = marker;
      overlays.add(marker);
    }
    await controller.addOverlayAll(overlays);
  }

  // 마커 탭과 검색 결과 선택이 공통으로 쓰는 흐름: 필요하면 카메라를 이동시키고,
  // 상세 시트를 연 뒤 닫히면 즐겨찾기 변경 여부를 다시 확인해 마커 아이콘을 맞춘다.
  Future<void> _openRestaurant(Restaurant restaurant, {bool moveCamera = false}) async {
    if (moveCamera) {
      await _mapController?.updateCamera(
        NCameraUpdate.scrollAndZoomTo(
          target: NLatLng(restaurant.lat, restaurant.lng),
          zoom: 15,
        ),
      );
    }
    if (!mounted) return;

    await showRestaurantDetailSheet(context, restaurant);

    final isFavorite = await FavoritesService.isFavorite(restaurant.id);
    _markersById[restaurant.id]?.setIcon(
      _markerIcons[_markerIconKey(restaurant.category, isFavorite)],
    );
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
      // 키보드가 올라올 때 body(NaverMap)를 다시 그리면 네이티브 지도뷰가
      // 리사이즈 애니메이션을 따라가지 못해 화면이 울렁거린다. 검색창이
      // 화면 위쪽에 있어 키보드에 가려질 걱정이 없으므로 리사이즈를 끈다.
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          NaverMap(
            options: const NaverMapViewOptions(
              initialCameraPosition: NCameraPosition(
                target: NLatLng(36.3504, 127.3845), // 대전 중심
                zoom: 12,
              ),
              locationButtonEnable: false,
            ),
            onMapReady: _onMapReady,
          ),
          // Floating 검색창 — 지도 위에 떠 있는 형태 (AppBar 없이 Stack/Positioned)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: RestaurantSearchBar(
                  restaurants: _sampleRestaurants,
                  onSelect: (restaurant) =>
                      _openRestaurant(restaurant, moveCamera: true),
                ),
              ),
            ),
          ),
        ],
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

String _markerIconKey(RestaurantCategory category, bool isFavorite) =>
    '${category.name}_$isFavorite';

// 즐겨찾기 마커 테두리: 금색보다 눈에 잘 띄는 형광 라임색.
const _favoriteBorderColor = Color(0xFF39FF14);

// 마커 아이콘: 카테고리 색상 원 안에 카테고리 아이콘.
// 즐겨찾기한 곳은 테두리를 금색으로 바꾸고 우측 상단에 별 배지를 붙인다.
class _CategoryMarkerIcon extends StatelessWidget {
  final RestaurantCategory category;
  final bool isFavorite;

  const _CategoryMarkerIcon({required this.category, required this.isFavorite});

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
              color: isFavorite ? _favoriteBorderColor : Colors.white,
              width: isFavorite ? 3 : 2,
            ),
          ),
          child: Icon(category.icon, color: Colors.white, size: 18),
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
