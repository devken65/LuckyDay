/// 위시리스트 아이템 모델
class WishlistItem {
  /// [WishlistItem] 생성자
  const WishlistItem({
    required this.id,
    required this.title,
    required this.artist,
    this.albumArtUrl,
    this.previewUrl,
    required this.addedAt,
  });

  /// 고유 식별자
  final String id;

  /// 곡 제목
  final String title;

  /// 아티스트
  final String artist;

  /// 앨범 아트 URL
  final String? albumArtUrl;

  /// 미리듣기 URL
  final String? previewUrl;

  /// 추가된 시간
  final DateTime addedAt;

  /// 복사
  WishlistItem copyWith({
    String? id,
    String? title,
    String? artist,
    String? albumArtUrl,
    String? previewUrl,
    DateTime? addedAt,
  }) {
    return WishlistItem(
      id: id ?? this.id,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      albumArtUrl: albumArtUrl ?? this.albumArtUrl,
      previewUrl: previewUrl ?? this.previewUrl,
      addedAt: addedAt ?? this.addedAt,
    );
  }
}
