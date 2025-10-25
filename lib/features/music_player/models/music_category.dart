/// 음악 카테고리 타입
enum MusicCategory {
  /// 팝 음악
  pop('팝', '🎵'),

  /// 댄스/일렉트로닉
  dance('댄스', '💃'),

  /// R&B/소울
  rnb('R&B', '🎤'),

  /// 록
  rock('록', '🎸'),

  /// 발라드
  ballad('발라드', '❤️'),

  /// 힙합
  hiphop('힙합', '🎧'),

  /// 인디
  indie('인디', '🎹');

  const MusicCategory(this.displayName, this.emoji);

  /// 카테고리 표시 이름
  final String displayName;

  /// 카테고리 이모지
  final String emoji;
}
