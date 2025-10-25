import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:template/features/music_player/models/music_category.dart';
import 'package:template/features/music_player/models/music_feedback.dart';
import 'package:template/features/music_player/repositories/music_search_repository.dart';

/// 음악 플레이어 상태
class MusicPlayerState {
  /// [MusicPlayerState] 생성자
  const MusicPlayerState({
    required this.isPlaying,
    required this.duration,
    required this.position,
    required this.currentSongTitle,
    required this.currentArtist,
    this.thumbnailUrl,
    this.videoUrl,
    this.currentFeedback,
    this.currentCategory,
    this.itunesUrl,
  });

  /// 재생 중 여부
  final bool isPlaying;

  /// 총 재생 시간
  final Duration duration;

  /// 현재 재생 위치
  final Duration position;

  /// 현재 곡 제목
  final String currentSongTitle;

  /// 현재 아티스트
  final String currentArtist;

  /// 썸네일 URL
  final String? thumbnailUrl;

  /// YouTube 비디오 URL
  final String? videoUrl;

  /// 현재 곡의 피드백
  final MusicFeedbackType? currentFeedback;

  /// 현재 곡의 카테고리
  final MusicCategory? currentCategory;

  /// iTunes 스토어 링크
  final String? itunesUrl;

  /// 상태 복사
  MusicPlayerState copyWith({
    bool? isPlaying,
    Duration? duration,
    Duration? position,
    String? currentSongTitle,
    String? currentArtist,
    String? thumbnailUrl,
    String? videoUrl,
    MusicFeedbackType? currentFeedback,
    MusicCategory? currentCategory,
    String? itunesUrl,
  }) {
    return MusicPlayerState(
      isPlaying: isPlaying ?? this.isPlaying,
      duration: duration ?? this.duration,
      position: position ?? this.position,
      currentSongTitle: currentSongTitle ?? this.currentSongTitle,
      currentArtist: currentArtist ?? this.currentArtist,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      videoUrl: videoUrl ?? this.videoUrl,
      currentFeedback: currentFeedback ?? this.currentFeedback,
      currentCategory: currentCategory ?? this.currentCategory,
      itunesUrl: itunesUrl ?? this.itunesUrl,
    );
  }

  /// 진행률 계산 (0.0 ~ 1.0)
  double get progress {
    if (duration.inMilliseconds == 0) {
      return 0;
    }
    return position.inMilliseconds / duration.inMilliseconds;
  }

  /// 남은 시간 포맷 (mm:ss)
  String get formattedPosition {
    final minutes = position.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = position.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}

/// 음악 플레이어 Provider
final musicPlayerProvider =
    NotifierProvider<MusicPlayerController, MusicPlayerState>(
  MusicPlayerController.new,
);

/// 음악 플레이어 컨트롤러
class MusicPlayerController extends Notifier<MusicPlayerState> {
  late AudioPlayer _audioPlayer;
  final _musicSearchRepository = MusicSearchRepository();

  /// 사용자 피드백 히스토리
  final List<MusicFeedback> _feedbackHistory = [];

  /// 재생된 곡 히스토리 (중복 방지용)
  final Set<String> _playedSongs = {};

  /// 음악 재생 목록 (아티스트, 곡 제목, 카테고리)
  final _musicPlaylist = [
    {'artist': 'Dua Lipa', 'title': 'Levitating', 'category': MusicCategory.pop},
    {'artist': 'The Weeknd', 'title': 'Blinding Lights', 'category': MusicCategory.pop},
    {'artist': 'Bruno Mars', 'title': 'Just The Way You Are', 'category': MusicCategory.pop},
    {'artist': 'Ed Sheeran', 'title': 'Shape of You', 'category': MusicCategory.pop},
    {'artist': 'Ariana Grande', 'title': 'thank u, next', 'category': MusicCategory.pop},
    {'artist': 'Taylor Swift', 'title': 'Shake It Off', 'category': MusicCategory.pop},
    {'artist': 'Dua Lipa', 'title': 'Don\'t Start Now', 'category': MusicCategory.dance},
    {'artist': 'Calvin Harris', 'title': 'Summer', 'category': MusicCategory.dance},
    {'artist': 'The Chainsmokers', 'title': 'Closer', 'category': MusicCategory.dance},
    {'artist': 'Billie Eilish', 'title': 'bad guy', 'category': MusicCategory.indie},
    {'artist': 'Lauv', 'title': 'I Like Me Better', 'category': MusicCategory.indie},
    {'artist': 'LANY', 'title': 'ILYSB', 'category': MusicCategory.indie},
    {'artist': 'The Weeknd', 'title': 'Die For You', 'category': MusicCategory.rnb},
    {'artist': 'SZA', 'title': 'Kill Bill', 'category': MusicCategory.rnb},
    {'artist': 'Post Malone', 'title': 'Circles', 'category': MusicCategory.rnb},
    {'artist': 'Olivia Rodrigo', 'title': 'good 4 u', 'category': MusicCategory.rock},
    {'artist': 'Imagine Dragons', 'title': 'Believer', 'category': MusicCategory.rock},
    {'artist': 'Coldplay', 'title': 'Fix You', 'category': MusicCategory.ballad},
    {'artist': 'Adele', 'title': 'Someone Like You', 'category': MusicCategory.ballad},
    {'artist': 'Sam Smith', 'title': 'Stay With Me', 'category': MusicCategory.ballad},
  ];

  @override
  MusicPlayerState build() {
    _audioPlayer = AudioPlayer();

    // 오디오 설정 최적화 (끊김 방지)
    _audioPlayer.setVolume(1.0);

    // 재생 위치 스트림 구독 (250ms 간격으로 throttle하여 성능 개선)
    Duration? lastPosition;
    _audioPlayer.positionStream.listen((position) {
      // 250ms 이상 차이날 때만 업데이트 (UI 렌더링 최적화)
      if (lastPosition == null ||
          (position - lastPosition!).inMilliseconds.abs() >= 250) {
        lastPosition = position;
        state = state.copyWith(position: position);
      }
    });

    // 재생 시간 스트림 구독
    _audioPlayer.durationStream.listen((duration) {
      if (duration != null) {
        state = state.copyWith(duration: duration);
      }
    });

    // 재생 상태 스트림 구독
    _audioPlayer.playerStateStream.listen((playerState) {
      state = state.copyWith(
        isPlaying: playerState.playing,
      );

      // 재생 완료 시 처리
      if (playerState.processingState == ProcessingState.completed) {
        _audioPlayer.seek(Duration.zero);
        _audioPlayer.pause();
      }
    });

    // 앱 종료 시 리소스 정리
    ref.onDispose(() {
      _audioPlayer.dispose();
    });

    return const MusicPlayerState(
      isPlaying: false,
      duration: Duration.zero,
      position: Duration.zero,
      currentSongTitle: 'City Lights',
      currentArtist: 'Urban Groove',
    );
  }

  /// 음악 로드 (URL 또는 asset)
  Future<void> loadAudio(String url) async {
    try {
      // URL이면 네트워크에서, asset이면 로컬에서 로드
      if (url.startsWith('http')) {
        await _audioPlayer.setUrl(url);
      } else {
        await _audioPlayer.setAsset(url);
      }
    } catch (e) {
      // 에러 처리
      throw Exception('Failed to load audio: $e');
    }
  }

  /// YouTube URL에서 음악 로드
  Future<void> loadYouTube(String youtubeUrl) async {
    try {
      final yt = YoutubeExplode();

      // YouTube URL에서 비디오 ID 추출
      final videoId = VideoId(youtubeUrl);

      // 비디오 정보 먼저 가져오기
      final video = await yt.videos.get(videoId);

      // 썸네일 URL 가져오기 (최고 해상도)
      final thumbnailUrl = video.thumbnails.highResUrl;

      // 스트림 매니페스트 가져오기
      final manifest = await yt.videos.streamsClient.getManifest(videoId);

      // 오디오만 가져오기 (최고 품질)
      final audioStream = manifest.audioOnly.withHighestBitrate();

      // 오디오 URL 설정
      await _audioPlayer.setUrl(audioStream.url.toString());

      // 상태 업데이트 (썸네일, 제목, 아티스트 정보 포함)
      state = state.copyWith(
        currentSongTitle: video.title,
        currentArtist: video.author,
        thumbnailUrl: thumbnailUrl,
        videoUrl: youtubeUrl,
      );

      yt.close();
    } catch (e) {
      throw Exception('Failed to load YouTube video: $e');
    }
  }

  /// 음악 로드 (iTunes API로 앨범 아트 및 30초 미리듣기 가져오기)
  Future<void> loadMusicWithAlbumArt({
    required String artist,
    required String title,
  }) async {
    try {
      debugPrint('🎵 음악 정보 요청: $artist - $title');

      // 1. iTunes API로 음악 정보 가져오기 (앨범 아트, 30초 미리듣기 URL 포함)
      final musicInfo = await _musicSearchRepository.getMusicInfo(
        artist: artist,
        title: title,
      );

      debugPrint('🎵 iTunes API 응답: $musicInfo');

      if (musicInfo == null) {
        debugPrint('❌ 음악 정보를 찾을 수 없습니다');
        throw Exception('음악 정보를 찾을 수 없습니다');
      }

      debugPrint('✅ 제목: ${musicInfo.title}');
      debugPrint('✅ 아티스트: ${musicInfo.artist}');
      debugPrint('✅ 앨범 아트: ${musicInfo.albumArtUrl}');
      debugPrint('✅ 미리듣기 URL: ${musicInfo.audioUrl}');

      if (musicInfo.audioUrl == null) {
        debugPrint('❌ 미리듣기 URL이 없습니다');
        throw Exception('미리듣기 URL이 없습니다');
      }

      // 2. 30초 미리듣기 오디오 로드
      await _audioPlayer.setUrl(musicInfo.audioUrl!);

      // 3. 상태 업데이트 (iTunes URL 포함)
      state = state.copyWith(
        currentSongTitle: musicInfo.title,
        currentArtist: musicInfo.artist,
        thumbnailUrl: musicInfo.albumArtUrl,
        videoUrl: musicInfo.audioUrl,
        itunesUrl: musicInfo.itunesUrl,
      );

      debugPrint('✅ 상태 업데이트 완료 - thumbnailUrl: ${state.thumbnailUrl}');
    } catch (e) {
      debugPrint('❌ 음악 로드 실패: $e');
      throw Exception('Failed to load music with album art: $e');
    }
  }

  /// 재생/일시정지 토글
  Future<void> togglePlayPause() async {
    if (state.isPlaying) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.play();
    }
  }

  /// 재생
  Future<void> play() async {
    await _audioPlayer.play();
  }

  /// 일시정지
  Future<void> pause() async {
    await _audioPlayer.pause();
  }

  /// 특정 위치로 이동
  Future<void> seek(Duration position) async {
    await _audioPlayer.seek(position);
  }

  /// 이전 곡
  Future<void> previous() async {
    // TODO: 이전 곡 로직 구현
    await _audioPlayer.seek(Duration.zero);
  }

  /// 다음 곡 (피드백 기반 스마트 추천)
  Future<void> next() async {
    debugPrint('🎲 다음 곡 재생 (카테고리 기반 스마트 추천)');

    // 피드백 기반으로 다음 곡 선택
    final nextSong = _getNextSongWithFeedback();

    final artist = nextSong['artist']! as String;
    final title = nextSong['title']! as String;
    final category = nextSong['category']! as MusicCategory;

    debugPrint('🎲 선택된 곡: $artist - $title [${category.displayName}]');

    // 재생 히스토리에 추가
    final songKey = '$artist-$title';
    _playedSongs.add(songKey);
    debugPrint('📝 재생 히스토리: ${_playedSongs.length}/${_musicPlaylist.length}');

    // 곡 로드
    await loadMusicWithAlbumArt(
      artist: artist,
      title: title,
    );

    // 새 곡이므로 피드백 초기화, 카테고리 설정
    state = state.copyWith(
      currentFeedback: null,
      currentCategory: category,
    );

    // 자동 재생
    await play();
  }

  /// 정지
  Future<void> stop() async {
    await _audioPlayer.stop();
  }

  /// 현재 곡에 대한 피드백 설정
  void setFeedback(MusicFeedbackType feedbackType) {
    // 피드백 히스토리에 추가
    final feedback = MusicFeedback(
      artist: state.currentArtist,
      title: state.currentSongTitle,
      feedbackType: feedbackType,
      timestamp: DateTime.now(),
    );
    _feedbackHistory.add(feedback);

    // 상태 업데이트
    state = state.copyWith(currentFeedback: feedbackType);

    debugPrint(
      '👍 피드백 저장: ${feedback.artist} - ${feedback.title} = ${feedbackType.name}',
    );
  }

  /// 다음 곡 선택 시 카테고리 기반 스마트 추천
  Map<String, dynamic> _getNextSongWithFeedback() {
    // 1. 재생하지 않은 곡만 필터링
    final unplayedSongs = _musicPlaylist.where((song) {
      final songKey = '${song['artist']}-${song['title']}';
      return !_playedSongs.contains(songKey);
    }).toList();

    // 모든 곡을 재생했으면 히스토리 초기화하고 다시 시작
    if (unplayedSongs.isEmpty) {
      debugPrint('🔄 모든 곡 재생 완료! 히스토리 초기화');
      _playedSongs.clear();
      return _getNextSongWithFeedback();
    }

    // 2. 피드백이 없으면 랜덤 선택
    if (_feedbackHistory.isEmpty) {
      final randomSong = unplayedSongs[Random().nextInt(unplayedSongs.length)];
      return randomSong;
    }

    // 3. 카테고리별 피드백 점수 계산
    final categoryScores = <MusicCategory, int>{};
    for (final feedback in _feedbackHistory) {
      // 피드백을 남긴 곡의 카테고리 찾기
      Map<String, dynamic>? feedbackSong;
      try {
        feedbackSong = _musicPlaylist.firstWhere(
          (song) =>
              song['artist'] == feedback.artist &&
              song['title'] == feedback.title,
        );
      } catch (e) {
        // 곡을 찾지 못한 경우 스킵
        continue;
      }

      final category = feedbackSong['category']! as MusicCategory;
      categoryScores[category] = categoryScores[category] ?? 0;

      // 좋아요: +3점, 보통: +1점, 싫어요: -2점
      switch (feedback.feedbackType) {
        case MusicFeedbackType.like:
          categoryScores[category] = categoryScores[category]! + 3;
        case MusicFeedbackType.neutral:
          categoryScores[category] = categoryScores[category]! + 1;
        case MusicFeedbackType.dislike:
          categoryScores[category] = categoryScores[category]! - 2;
      }
    }

    debugPrint('📊 카테고리 점수: $categoryScores');

    // 4. 점수 기반 가중치 추천
    // 점수가 높은 카테고리는 더 자주 추천
    final weightedSongs = <Map<String, dynamic>>[];
    for (final song in unplayedSongs) {
      final category = song['category'] as MusicCategory;
      final score = categoryScores[category] ?? 0;

      // 점수가 음수인 카테고리는 20% 확률로만 추가
      if (score < 0 && Random().nextDouble() > 0.2) {
        continue;
      }

      // 점수에 비례해서 목록에 추가 (점수가 높을수록 선택 확률 증가)
      final weight = (score > 0 ? score : 1).clamp(1, 5);
      for (var i = 0; i < weight; i++) {
        weightedSongs.add(song);
      }
    }

    // 가중치 목록이 비어있으면 재생하지 않은 곡에서 랜덤 선택
    if (weightedSongs.isEmpty) {
      return unplayedSongs[Random().nextInt(unplayedSongs.length)];
    }

    return weightedSongs[Random().nextInt(weightedSongs.length)];
  }
}
