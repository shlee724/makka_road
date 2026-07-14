# 맠카로드(코드명: makkaroad) — Claude Code 작업 규칙

이 프로젝트의 전체 기획은 docs/기획서.md 에 있다. 큰 방향이 궁금하면 그 파일을 읽어라.

## 개발자 컨텍스트
- 개발자는 프로그래밍 비전공자다. 코드를 작성한 뒤에는 반드시 "무엇을 왜 그렇게 했는지" 한국어로 짧게 설명하라.
- 한 번에 하나의 기능만 구현한다. 요청하지 않은 기능을 미리 만들지 마라.
- 복잡한 아키텍처(BLoC, clean architecture 등)를 도입하지 마라. setState와 필요 시 Provider 수준까지만 사용한다.

## 프로젝트 정의
대전 맛집 유튜버의 방문 맛집을 지도에 모아 보여주는 Flutter 앱 (Android 우선, MVP).

## 기술 스택 (변경 금지 — 변경이 필요하면 먼저 이유를 설명하고 허락을 받아라)
- 지도: flutter_naver_map
- 유튜브 임베디드 재생: youtube_player_iframe
- DB: Cloud Firestore (읽기 전용, restaurants 컬렉션)
- 즐겨찾기: shared_preferences (로컬 저장. 서버 저장 금지, 로그인 기능 금지)
- 광고: google_mobile_ads (배너만, 기본 비활성화 상태로 구현)
- 상태관리: setState 우선

## Firestore 스키마 (restaurants 컬렉션)
name, address, lat, lng, phone, hours, menu, videoId, publishedAt, viewCount, viewCountAt, category

category: 장소 유형 — restaurant(식당) / cafeDessert(카페·디저트) / attraction(관광명소). 지도 마커의 색상·아이콘 구분에 사용.

## 테마 색상
맠카님 테마 색상 #00887A를 앱 기본 시드 컬러로 사용한다 (`ColorScheme.fromSeed`). 임의로 다른 색으로 바꾸지 말 것.

## MVP 화면 구성
1. 메인 지도: NaverMap 전체 배경 + Stack/Positioned로 Floating 검색창 + 마커 + 내위치 FAB + 하단 배너 자리
2. 맛집 상세: DraggableScrollableSheet. 가게명/즐겨찾기별/조회수/주소(탭=복사)/전화(탭=걸기)/영업시간/추천메뉴/길찾기(네이버·카카오 딥링크)/공유/임베디드 영상+유튜브에서 보기 버튼
3. 즐겨찾기 목록: 로컬 즐겨찾기 ListView → 탭하면 지도의 해당 마커로 이동

## 만들지 않는 것 (제안도 하지 마라)
로그인/회원가입, 유저 평점·리뷰, 조회수 percent 순위, 전면광고, 네이버·카카오 평점 크롤링, iOS 대응 코드

## 코딩 규칙
- 파일이 300줄을 넘으면 위젯을 별도 파일로 분리하라.
- API 키(네이버맵 클라이언트 ID 등)는 코드에 하드코딩하지 말고 별도 파일로 분리하고 .gitignore에 추가하라.
- 기능 하나가 끝날 때마다 "지금 실기기/에뮬레이터에서 확인할 것" 체크리스트를 알려줘라.
- 빌드 확인: flutter analyze 를 통과해야 작업 완료다.