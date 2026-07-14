import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/restaurant.dart';

// 상세 화면에서 쓰는 외부 연동(전화, 지도 딥링크, 공유, 클립보드)을 모아둔 서비스.
class ExternalLinksService {
  static const _naverAppName = 'com.example.makka_road';

  static Future<void> copyAddress(String address) async {
    await Clipboard.setData(ClipboardData(text: address));
  }

  static Future<void> callPhone(String phone) async {
    final uri = Uri(scheme: 'tel', path: phone);
    await launchUrl(uri);
  }

  // 네이버 지도 앱이 있으면 앱 길찾기로, 없으면 웹 지도로 연다.
  static Future<void> openNaverMapDirections(Restaurant restaurant) async {
    final appUri = Uri.parse(
      'nmap://route/car?dlat=${restaurant.lat}&dlng=${restaurant.lng}'
      '&dname=${Uri.encodeComponent(restaurant.name)}&appname=$_naverAppName',
    );
    final webUri = Uri.parse(
      'https://map.naver.com/p/search/${Uri.encodeComponent(restaurant.name)}',
    );
    await _launchAppOrWeb(appUri, webUri);
  }

  // 카카오맵 앱이 있으면 앱 길찾기로, 없으면 웹 지도로 연다.
  static Future<void> openKakaoMapDirections(Restaurant restaurant) async {
    final appUri = Uri.parse(
      'kakaomap://route?ep=${restaurant.lat},${restaurant.lng}&by=CAR',
    );
    final webUri = Uri.parse(
      'https://map.kakao.com/link/to/'
      '${Uri.encodeComponent(restaurant.name)},${restaurant.lat},${restaurant.lng}',
    );
    await _launchAppOrWeb(appUri, webUri);
  }

  static Future<void> openYoutubeVideo(String videoId) async {
    final uri = Uri.parse('https://www.youtube.com/watch?v=$videoId');
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  static Future<void> shareRestaurant(Restaurant restaurant) async {
    await SharePlus.instance.share(
      ShareParams(
        text: '${restaurant.name}\n${restaurant.address}\n'
            'https://www.youtube.com/watch?v=${restaurant.videoId}',
      ),
    );
  }

  static Future<void> _launchAppOrWeb(Uri appUri, Uri webUri) async {
    if (await canLaunchUrl(appUri)) {
      await launchUrl(appUri);
    } else {
      await launchUrl(webUri, mode: LaunchMode.externalApplication);
    }
  }
}
