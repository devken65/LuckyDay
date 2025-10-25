import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
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

  /// 상태 복사
  MusicPlayerState copyWith({
    bool? isPlaying,
    Duration? duration,
    Duration? position,
    String? currentSongTitle,
    String? currentArtist,
    String? thumbnailUrl,
    String? videoUrl,
  }) {
    return MusicPlayerState(
      isPlaying: isPlaying ?? this.isPlaying,
      duration: duration ?? this.duration,
      position: position ?? this.position,
      currentSongTitle: currentSongTitle ?? this.currentSongTitle,
      currentArtist: currentArtist ?? this.currentArtist,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      videoUrl: videoUrl ?? this.videoUrl,
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

  /// 랜덤 재생 목록 (아티스트, 곡 제목)
  final List<Map<String, String>> _randomPlaylist = [
    {'artist': 'Dua Lipa', 'title': 'Levitating'},
    {'artist': 'The Weeknd', 'title': 'Blinding Lights'},
    {'artist': 'Bruno Mars', 'title': 'Just The Way You Are'},
    {'artist': 'Ed Sheeran', 'title': 'Shape of You'},
    {'artist': 'Ariana Grande', 'title': 'thank u, next'},
    {'artist': 'Taylor Swift', 'title': 'Shake It Off'},
    {'artist': 'Billie Eilish', 'title': 'bad guy'},
    {'artist': 'Post Malone', 'title': 'Circles'},
    {'artist': 'Olivia Rodrigo', 'title': 'good 4 u'},
    {'artist': 'Justin Bieber', 'title': 'Peaches'},
  ];

  @override
  MusicPlayerState build() {
    _audioPlayer = AudioPlayer();

    // 재생 위치 스트림 구독
    _audioPlayer.positionStream.listen((position) {
      state = state.copyWith(position: position);
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

      // 3. 상태 업데이트
      state = state.copyWith(
        currentSongTitle: musicInfo.title,
        currentArtist: musicInfo.artist,
        thumbnailUrl: musicInfo.albumArtUrl,
        videoUrl: musicInfo.audioUrl,
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

  /// 다음 곡 (랜덤)
  Future<void> next() async {
    debugPrint('🎲 다음 곡 재생 (랜덤)');

    // 랜덤 인덱스 선택
    final random = Random();
    final randomIndex = random.nextInt(_randomPlaylist.length);
    final randomSong = _randomPlaylist[randomIndex];

    debugPrint('🎲 선택된 곡: ${randomSong['artist']} - ${randomSong['title']}');

    // 랜덤 곡 로드
    await loadMusicWithAlbumArt(
      artist: randomSong['artist']!,
      title: randomSong['title']!,
    );

    // 자동 재생
    await play();
  }

  /// 정지
  Future<void> stop() async {
    await _audioPlayer.stop();
  }
}
