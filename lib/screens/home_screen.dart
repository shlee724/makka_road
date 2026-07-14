import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:permission_handler/permission_handler.dart';

import '../data/sample_restaurants.dart';
import '../models/restaurant.dart';
import '../services/favorites_service.dart';
import '../widgets/restaurant_search_bar.dart';
import 'favorites_screen.dart';
import 'restaurant_detail_sheet.dart';

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
    for (final restaurant in sampleRestaurants) {
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

  // 즐겨찾기 목록에서 가게를 고르면 그 가게로 카메라를 이동하고 상세 시트를 연다.
  Future<void> _openFavorites() async {
    final selected = await Navigator.push<Restaurant>(
      context,
      MaterialPageRoute(builder: (_) => const FavoritesScreen()),
    );
    if (selected == null || !mounted) return;
    await _openRestaurant(selected, moveCamera: true);
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
                  restaurants: sampleRestaurants,
                  onSelect: (restaurant) =>
                      _openRestaurant(restaurant, moveCamera: true),
                ),
              ),
            ),
          ),
          // 내 위치 FAB — 탭하면 위치 권한 요청 후 지도 이동
          Positioned(
            right: 16,
            bottom: 16,
            child: FloatingActionButton(
              heroTag: 'myLocationFab',
              onPressed: _goToMyLocation,
              child: const Icon(Icons.my_location),
            ),
          ),
          // 즐겨찾기 목록 진입 버튼 — 화면 중앙 하단의 납작한 알약 모양 버튼.
          // FloatingActionButton.extended는 높이(56dp 고정)를 줄일 수 없어서
          // Material + InkWell로 직접 만들어 높이를 낮췄다.
          Positioned(
            left: 0,
            right: 0,
            bottom: 16,
            child: Center(
              child: Material(
                elevation: 4,
                color: Theme.of(context).colorScheme.primaryContainer,
                shape: const StadiumBorder(),
                child: InkWell(
                  customBorder: const StadiumBorder(),
                  onTap: _openFavorites,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.star,
                          size: 20,
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '즐겨찾기',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
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
