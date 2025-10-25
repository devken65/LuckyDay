/// 음악 피드백 타입
enum MusicFeedbackType {
  /// 좋음 👍
  like,

  /// 보통 🤔
  neutral,

  /// 나쁨 👎
  dislike,
}

/// 음악 피드백
class MusicFeedback {
  /// [MusicFeedback] 생성자
  const MusicFeedback({
    required this.artist,
    required this.title,
    required this.feedbackType,
    required this.timestamp,
  });

  /// 아티스트
  final String artist;

  /// 곡 제목
  final String title;

  /// 피드백 타입
  final MusicFeedbackType feedbackType;

  /// 피드백 시간
  final DateTime timestamp;
}
