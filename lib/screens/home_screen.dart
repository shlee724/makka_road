import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:permission_handler/permission_handler.dart';

import '../models/restaurant.dart';
import '../services/favorites_service.dart';
import '../widgets/category_filter_sheet.dart';
import '../widgets/category_marker_icon.dart';
import '../widgets/filter_button.dart';
import '../widgets/pill_button.dart';
import '../widgets/restaurant_search_bar.dart';
import '../widgets/view_count_filter_chips.dart';
import 'restaurant_detail_sheet.dart';
import 'restaurant_list_sheet.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  NaverMapController? _mapController;
  final Map<String, NMarker> _markersById = {};
  Map<String, NOverlayImage> _markerIcons = {};
  List<Restaurant> _restaurants = [];
  late final Future<List<Restaurant>> _restaurantsFuture;
  Set<RestaurantCategory> _selectedCategories = {...RestaurantCategory.values};
  int? _minViewCount;

  @override
  void initState() {
    super.initState();
    _restaurantsFuture = _fetchRestaurants();
  }

  // 검색창은 지도가 준비되기 전에도 목록이 필요해서 setState로 별도 반영하고,
  // _onMapReady는 같은 Future를 await해 마커를 만든다 (조회는 한 번만 일어남).
  Future<List<Restaurant>> _fetchRestaurants() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('restaurants').get();
      final restaurants =
          snapshot.docs.map(Restaurant.fromFirestore).toList();
      if (mounted) setState(() => _restaurants = restaurants);
      return restaurants;
    } catch (e) {
      // 화면에는 안내 메시지만 보여주고, 실제 원인은 로그로 남겨서
      // (adb logcat / flutter run 콘솔) 재현 안 되는 문제도 추적 가능하게 한다.
      debugPrint('맛집 정보 로딩 실패: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('맛집 정보를 불러오지 못했습니다.')),
        );
      }
      return [];
    }
  }

  Future<void> _onMapReady(NaverMapController controller) async {
    _mapController = controller;

    final restaurants = await _restaurantsFuture;
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
          widget:
              CategoryMarkerIcon(category: category, isFavorite: isFavorite),
        );
      }
    }
    _markerIcons = markerIcons;

    // 마커 3개 생성 후 지도에 추가
    final Set<NAddableOverlay> overlays = {};
    for (final restaurant in restaurants) {
      final marker = NMarker(
        id: restaurant.id,
        position: NLatLng(restaurant.lat, restaurant.lng),
        icon: markerIcons[_markerIconKey(
          restaurant.category,
          favoriteIds.contains(restaurant.id),
        )],
        // 일정 줌 레벨 이상으로 확대해야 마커 아래 가게 이름이 보이도록.
        caption:
            NOverlayCaption(text: restaurant.name, minZoom: _captionMinZoom),
      );
      marker.setOnTapListener((_) => _openRestaurant(restaurant));
      _markersById[restaurant.id] = marker;
      overlays.add(marker);
    }
    await controller.addOverlayAll(overlays);
    _applyFilters();
  }

  // 체크된 카테고리 + 조회수 임계값을 모두 만족하는 가게만 남긴다.
  // '목록' 시트도 이 결과를 그대로 받아 지도에서 보이는 가게와 목록을 일치시킨다.
  List<Restaurant> get _filteredRestaurants => _restaurants.where((restaurant) {
        final matchesCategory =
            _selectedCategories.contains(restaurant.category);
        final matchesViewCount =
            _minViewCount == null || restaurant.viewCount >= _minViewCount!;
        return matchesCategory && matchesViewCount;
      }).toList();

  // (오버레이를 지웠다 다시 그리지 않고 isVisible만 바꿔서 가볍게 처리)
  void _applyFilters() {
    final visibleIds = _filteredRestaurants.map((r) => r.id).toSet();
    for (final restaurant in _restaurants) {
      _markersById[restaurant.id]
          ?.setIsVisible(visibleIds.contains(restaurant.id));
    }
  }

  Future<void> _openCategoryFilter() {
    return showCategoryFilterSheet(
      context,
      selected: _selectedCategories,
      onChanged: (selected) {
        setState(() => _selectedCategories = selected);
        _applyFilters();
      },
    );
  }

  void _onViewCountThresholdChanged(int? threshold) {
    setState(() => _minViewCount = threshold);
    _applyFilters();
  }

  // 마커 탭과 검색 결과 선택이 공통으로 쓰는 흐름: 필요하면 카메라를 이동시키고,
  // 상세 시트를 연 뒤 닫히면 즐겨찾기 변경 여부를 다시 확인해 마커 아이콘을 맞춘다.
  Future<void> _openRestaurant(Restaurant restaurant,
      {bool moveCamera = false}) async {
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

  // '목록' 버튼: 현재 필터로 걸러진(=지도에 보이는) 가게들을 정렬해서 보여준다.
  // 즐겨찾기만 보고 싶으면 시트 안의 '즐겨찾기' 칩으로 다시 걸러볼 수 있다.
  Future<void> _openRestaurantList() {
    return showRestaurantListSheet(
      context,
      restaurants: _filteredRestaurants,
      onSelect: (restaurant) => _openRestaurant(restaurant, moveCamera: true),
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
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: RestaurantSearchBar(
                            restaurants: _restaurants,
                            onSelect: (restaurant) =>
                                _openRestaurant(restaurant, moveCamera: true),
                          ),
                        ),
                        const SizedBox(width: 8),
                        FilterButton(
                          isActive: _selectedCategories.length !=
                              RestaurantCategory.values.length,
                          onPressed: _openCategoryFilter,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ViewCountFilterChips(
                      selectedThreshold: _minViewCount,
                      onChanged: _onViewCountThresholdChanged,
                    ),
                  ],
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
          Positioned(
            left: 0,
            right: 0,
            bottom: 16,
            child: PillButton(
              icon: Icons.list,
              label: '목록',
              onTap: _openRestaurantList,
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

// 이 줌 레벨 이상으로 확대해야 마커 캡션(가게 이름)이 보인다.
const _captionMinZoom = 12.0;
