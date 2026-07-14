import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

import '../models/restaurant.dart';
import '../services/external_links_service.dart';
import '../services/favorites_service.dart';

// 마커를 탭하면 이 바텀시트를 띄운다.
// 반환되는 Future는 시트가 닫힐 때 완료되므로, 호출부에서 즐겨찾기 변경 여부를
// 다시 확인하는 용도로 쓸 수 있다.
Future<void> showRestaurantDetailSheet(BuildContext context, Restaurant restaurant) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => RestaurantDetailSheet(restaurant: restaurant),
  );
}

class RestaurantDetailSheet extends StatefulWidget {
  final Restaurant restaurant;

  const RestaurantDetailSheet({super.key, required this.restaurant});

  @override
  State<RestaurantDetailSheet> createState() => _RestaurantDetailSheetState();
}

class _RestaurantDetailSheetState extends State<RestaurantDetailSheet> {
  bool _isFavorite = false;
  late final YoutubePlayerController _youtubeController;

  @override
  void initState() {
    super.initState();
    _loadFavorite();
    _youtubeController = YoutubePlayerController.fromVideoId(
      videoId: widget.restaurant.videoId,
      autoPlay: false,
      // origin을 youtube-nocookie.com으로 지정. 기본값(youtube.com)으로는
      // 2025년 유튜브 정책 변경 이후 임베드 재생이 "Error code: 152"로 거부되는
      // 사례가 보고되어, 같은 문제를 고친 공식 패키지의 수정 방식을 따랐다.
      params: const YoutubePlayerParams(
        showControls: true,
        origin: 'https://www.youtube-nocookie.com',
      ),
    );
  }

  @override
  void dispose() {
    _youtubeController.close();
    super.dispose();
  }

  Future<void> _loadFavorite() async {
    final isFavorite = await FavoritesService.isFavorite(widget.restaurant.id);
    if (mounted) setState(() => _isFavorite = isFavorite);
  }

  Future<void> _toggleFavorite() async {
    final nowFavorite = await FavoritesService.toggleFavorite(widget.restaurant.id);
    if (mounted) setState(() => _isFavorite = nowFavorite);
  }

  Future<void> _copyAddress() async {
    await ExternalLinksService.copyAddress(widget.restaurant.address);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('주소가 복사되었습니다'), duration: Duration(seconds: 1)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final restaurant = widget.restaurant;

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.3,
      maxChildSize: 0.92,
      expand: false,
      builder: (context, scrollController) {
        return DecoratedBox(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: ListView(
            controller: scrollController,
            // 하단에 시스템 내비게이션 컨트롤 영역만큼 여백을 더해서
            // "유튜브에서 보기" 버튼이 컨트롤에 가리지 않게 한다.
            padding: EdgeInsets.fromLTRB(
              16,
              8,
              16,
              24 + MediaQuery.of(context).padding.bottom,
            ),
            children: [
              _DragHandle(),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Text(restaurant.name, style: Theme.of(context).textTheme.titleLarge),
                  ),
                  IconButton(
                    onPressed: _toggleFavorite,
                    icon: Icon(
                      _isFavorite ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                    ),
                  ),
                ],
              ),
              Text(
                _viewCountLabel(restaurant.viewCount),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: _viewCountColor(restaurant.viewCount),
                      fontWeight: restaurant.viewCount >= 10000
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
              ),
              const Divider(height: 24),
              _InfoRow(icon: Icons.location_on_outlined, text: restaurant.address, onTap: _copyAddress),
              _InfoRow(
                icon: Icons.call_outlined,
                text: restaurant.phone,
                onTap: () => ExternalLinksService.callPhone(restaurant.phone),
              ),
              _InfoRow(icon: Icons.access_time, text: restaurant.hours),
              _InfoRow(icon: Icons.restaurant_menu, text: restaurant.menu),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => ExternalLinksService.openNaverMapDirections(restaurant),
                      child: const Text('네이버지도 길찾기'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => ExternalLinksService.openKakaoMapDirections(restaurant),
                      child: const Text('카카오맵 길찾기'),
                    ),
                  ),
                  IconButton(
                    onPressed: () => ExternalLinksService.shareRestaurant(restaurant),
                    icon: const Icon(Icons.share_outlined),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              AspectRatio(
                aspectRatio: 9 / 16,
                child: YoutubePlayer(
                  controller: _youtubeController,
                  // 기본값(true)이면 영상 위 세로 드래그를 전체화면 전환
                  // 제스처로 가로채서 시트를 끌어올리고 내릴 수 없게 된다.
                  enableFullScreenOnVerticalDrag: false,
                  // 세로 드래그를 웹뷰가 독점하지 않고 바깥 시트와 경쟁하게
                  // 해서, 영상 위에서도 시트를 드래그할 수 있게 한다.
                  gestureRecognizers: {
                    Factory<VerticalDragGestureRecognizer>(
                      () => VerticalDragGestureRecognizer(),
                    ),
                  },
                ),
              ),
              Center(
                child: TextButton.icon(
                  onPressed: () => ExternalLinksService.openYoutubeVideo(restaurant.videoId),
                  icon: const Icon(Icons.open_in_new),
                  label: const Text('유튜브에서 보기'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DragHandle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback? onTap;

  const _InfoRow({required this.icon, required this.text, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 20, color: Colors.grey[700]),
            const SizedBox(width: 12),
            Expanded(child: Text(text)),
          ],
        ),
      ),
    );
  }
}

// 100만 이상: 진한 빨강 / 10만 이상: 진한 주황 / 1만 이상: 검정 굵게 / 그 미만: 검정 보통.
Color _viewCountColor(int viewCount) {
  if (viewCount >= 1000000) return Colors.red[700]!;
  if (viewCount >= 100000) return Colors.orange[900]!;
  return Colors.black;
}

String _viewCountLabel(int viewCount) {
  if (viewCount >= 10000) {
    return '조회수 ${viewCount ~/ 10000}만회';
  }
  return '조회수 ${_withThousandsComma(viewCount)}회';
}

String _withThousandsComma(int value) {
  final digits = value.toString();
  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    final remaining = digits.length - i;
    if (i != 0 && remaining % 3 == 0) buffer.write(',');
    buffer.write(digits[i]);
  }
  return buffer.toString();
}
