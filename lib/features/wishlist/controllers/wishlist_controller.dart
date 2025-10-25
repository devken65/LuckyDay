import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:template/features/wishlist/models/wishlist_item.dart';

/// 정렬 옵션
enum WishlistSortOption {
  /// 최근 추가순
  recentlyAdded,

  /// 제목순
  title,

  /// 아티스트순
  artist,
}

/// 위시리스트 상태
class WishlistState {
  /// [WishlistState] 생성자
  const WishlistState({
    required this.items,
    required this.sortOption,
  });

  /// 위시리스트 아이템 목록
  final List<WishlistItem> items;

  /// 정렬 옵션
  final WishlistSortOption sortOption;

  /// 복사
  WishlistState copyWith({
    List<WishlistItem>? items,
    WishlistSortOption? sortOption,
  }) {
    return WishlistState(
      items: items ?? this.items,
      sortOption: sortOption ?? this.sortOption,
    );
  }

  /// 정렬된 아이템 목록
  List<WishlistItem> get sortedItems {
    final itemsCopy = List<WishlistItem>.from(items);

    switch (sortOption) {
      case WishlistSortOption.recentlyAdded:
        itemsCopy.sort((a, b) => b.addedAt.compareTo(a.addedAt));
      case WishlistSortOption.title:
        itemsCopy.sort((a, b) => a.title.compareTo(b.title));
      case WishlistSortOption.artist:
        itemsCopy.sort((a, b) => a.artist.compareTo(b.artist));
    }

    return itemsCopy;
  }
}

/// 위시리스트 Provider
final wishlistProvider =
    NotifierProvider<WishlistController, WishlistState>(
  WishlistController.new,
);

/// 위시리스트 컨트롤러
class WishlistController extends Notifier<WishlistState> {
  @override
  WishlistState build() {
    return const WishlistState(
      items: [],
      sortOption: WishlistSortOption.recentlyAdded,
    );
  }

  /// 위시리스트에 추가
  void addToWishlist({
    required String title,
    required String artist,
    String? albumArtUrl,
    String? previewUrl,
  }) {
    final newItem = WishlistItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      artist: artist,
      albumArtUrl: albumArtUrl,
      previewUrl: previewUrl,
      addedAt: DateTime.now(),
    );

    state = state.copyWith(
      items: [...state.items, newItem],
    );
  }

  /// 위시리스트에서 제거
  void removeFromWishlist(String id) {
    state = state.copyWith(
      items: state.items.where((item) => item.id != id).toList(),
    );
  }

  /// 위시리스트에 있는지 확인
  bool isInWishlist(String title, String artist) {
    return state.items.any(
      (item) => item.title == title && item.artist == artist,
    );
  }

  /// 위시리스트 비우기
  void clearWishlist() {
    state = state.copyWith(items: []);
  }

  /// 정렬 옵션 변경
  void setSortOption(WishlistSortOption option) {
    state = state.copyWith(sortOption: option);
  }
}
