import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:template/features/music_player/models/music_category.dart';
import 'package:template/features/wishlist/models/wishlist_item.dart';

/// 위시리스트 Provider
final wishlistProvider =
    NotifierProvider<WishlistController, List<WishlistItem>>(
  WishlistController.new,
);

/// 위시리스트 컨트롤러
class WishlistController extends Notifier<List<WishlistItem>> {
  @override
  List<WishlistItem> build() {
    return [];
  }

  /// 위시리스트에 추가
  void addToWishlist({
    required String title,
    required String artist,
    String? albumArtUrl,
    String? previewUrl,
    MusicCategory? category,
  }) {
    final newItem = WishlistItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      artist: artist,
      albumArtUrl: albumArtUrl,
      previewUrl: previewUrl,
      addedAt: DateTime.now(),
      category: category,
    );

    state = [...state, newItem];
  }

  /// 위시리스트에서 제거
  void removeFromWishlist(String id) {
    state = state.where((item) => item.id != id).toList();
  }

  /// 위시리스트에 있는지 확인
  bool isInWishlist(String title, String artist) {
    return state.any(
      (item) => item.title == title && item.artist == artist,
    );
  }

  /// 위시리스트 비우기
  void clearWishlist() {
    state = [];
  }

  /// 카테고리별 통계 (백분율)
  Map<MusicCategory, double> getCategoryStatistics() {
    if (state.isEmpty) {
      return {};
    }

    // 카테고리별 곡 개수 계산
    final categoryCounts = <MusicCategory, int>{};
    var totalWithCategory = 0;

    for (final item in state) {
      if (item.category != null) {
        categoryCounts[item.category!] =
            (categoryCounts[item.category!] ?? 0) + 1;
        totalWithCategory++;
      }
    }

    // 백분율 계산
    final categoryPercentages = <MusicCategory, double>{};
    for (final entry in categoryCounts.entries) {
      categoryPercentages[entry.key] =
          (entry.value / totalWithCategory) * 100;
    }

    return categoryPercentages;
  }
}
