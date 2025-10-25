/// 음악 정보 모델
class MusicInfo {
  /// [MusicInfo] 생성자
  const MusicInfo({
    required this.title,
    required this.artist,
    this.albumArtUrl,
    this.audioUrl,
    this.albumName,
    this.releaseDate,
    this.itunesUrl,
  });

  /// JSON에서 변환 (iTunes API)
  factory MusicInfo.fromItunesJson(Map<String, dynamic> json) {
    return MusicInfo(
      title: json['trackName'] as String? ?? '',
      artist: json['artistName'] as String? ?? '',
      albumArtUrl: (json['artworkUrl100'] as String?)?.replaceAll('100x100', '600x600'),
      audioUrl: json['previewUrl'] as String?,
      albumName: json['collectionName'] as String?,
      releaseDate: json['releaseDate'] as String?,
      itunesUrl: json['trackViewUrl'] as String?,
    );
  }

  /// 곡 제목
  final String title;

  /// 아티스트
  final String artist;

  /// 앨범 아트 URL
  final String? albumArtUrl;

  /// 오디오 파일 URL
  final String? audioUrl;

  /// 앨범명
  final String? albumName;

  /// 발매일
  final String? releaseDate;

  /// iTunes 링크 URL
  final String? itunesUrl;

  /// 복사
  MusicInfo copyWith({
    String? title,
    String? artist,
    String? albumArtUrl,
    String? audioUrl,
    String? albumName,
    String? releaseDate,
    String? itunesUrl,
  }) {
    return MusicInfo(
      title: title ?? this.title,
      artist: artist ?? this.artist,
      albumArtUrl: albumArtUrl ?? this.albumArtUrl,
      audioUrl: audioUrl ?? this.audioUrl,
      albumName: albumName ?? this.albumName,
      releaseDate: releaseDate ?? this.releaseDate,
      itunesUrl: itunesUrl ?? this.itunesUrl,
    );
  }
}
