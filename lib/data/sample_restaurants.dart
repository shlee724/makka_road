import '../models/restaurant.dart';

// 하드코딩된 샘플 맛집 3개 (나중에 Firestore로 교체).
// address/phone/hours/menu/videoId/viewCount는 화면 2 테스트용 더미 데이터.
const sampleRestaurants = <Restaurant>[
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
