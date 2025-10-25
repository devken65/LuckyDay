import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:marquee/marquee.dart';
import 'package:share_plus/share_plus.dart';
import 'package:template/features/music_player/controllers/music_player_controller.dart';
import 'package:template/features/music_player/models/music_feedback.dart';
import 'package:template/features/wishlist/controllers/wishlist_controller.dart';
import 'package:template/features/wishlist/screens/wishlist_screen.dart';

/// 음악 플레이어 화면
///
/// 현재 재생 중인 곡 정보와 플레이어 컨트롤을 표시합니다.
class MusicPlayerScreen extends ConsumerStatefulWidget {
  /// [MusicPlayerScreen] 생성자
  const MusicPlayerScreen({super.key});

  @override
  ConsumerState<MusicPlayerScreen> createState() => _MusicPlayerScreenState();
}

class _MusicPlayerScreenState extends ConsumerState<MusicPlayerScreen> {
  @override
  void initState() {
    super.initState();
    // 화면 로드 시 랜덤 음악 재생
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(musicPlayerProvider.notifier).next();
    });
  }

  @override
  Widget build(BuildContext context) {
    final playerState = ref.watch(musicPlayerProvider);

    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFFF9F1),
              Color(0xFFFFFFFF),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 24),

              // 앨범 아트 (썸네일)
              Center(
                child: Container(
                  width: 342,
                  height: 342,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x12000000),
                        offset: Offset(0, 4),
                        blurRadius: 12,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: playerState.thumbnailUrl != null
                        ? Image.network(
                            playerState.thumbnailUrl!,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) {
                                return child;
                              }
                              return const ColoredBox(
                                color: Color(0xFFE5E7EB),
                                child: Center(
                                  child: CircularProgressIndicator(
                                    color: Color(0xFF2B2B2B),
                                  ),
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return const ColoredBox(
                                color: Color(0xFFE5E7EB),
                                child: Center(
                                  child: Icon(
                                    Icons.music_note,
                                    size: 80,
                                    color: Color(0xFF9CA3AF),
                                  ),
                                ),
                              );
                            },
                          )
                        : const ColoredBox(
                            color: Color(0xFFE5E7EB),
                            child: Center(
                              child: Icon(
                                Icons.music_note,
                                size: 80,
                                color: Color(0xFF9CA3AF),
                              ),
                            ),
                          ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // 곡 제목과 아티스트
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 음악 제목 (스크롤 애니메이션 - 1줄)
                          SizedBox(
                            height: 38, // 1줄 높이 (30px * 1.25 line-height)
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                // 텍스트가 한 줄에 들어가는지 확인
                                final textPainter = TextPainter(
                                  text: TextSpan(
                                    text: playerState.currentSongTitle,
                                    style: const TextStyle(
                                      fontFamily: 'Plus Jakarta Sans',
                                      fontWeight: FontWeight.w700,
                                      fontSize: 30,
                                      height: 1.25,
                                      letterSpacing: -0.75,
                                      color: Color(0xFF2B2B2B),
                                    ),
                                  ),
                                  maxLines: 1,
                                  textDirection: TextDirection.ltr,
                                )..layout(maxWidth: constraints.maxWidth);

                                final isOverflowing = textPainter.didExceedMaxLines;

                                // 오버플로우되면 Marquee, 아니면 일반 Text
                                if (isOverflowing) {
                                  return Marquee(
                                    text: playerState.currentSongTitle,
                                    style: const TextStyle(
                                      fontFamily: 'Plus Jakarta Sans',
                                      fontWeight: FontWeight.w700,
                                      fontSize: 30,
                                      height: 1.25,
                                      letterSpacing: -0.75,
                                      color: Color(0xFF2B2B2B),
                                    ),
                                    blankSpace: 40,
                                    velocity: 30,
                                    pauseAfterRound: const Duration(seconds: 1),
                                    accelerationDuration: const Duration(seconds: 1),
                                    decelerationDuration: const Duration(milliseconds: 500),
                                    decelerationCurve: Curves.easeOut,
                                  );
                                }

                                return Text(
                                  playerState.currentSongTitle,
                                  style: const TextStyle(
                                    fontFamily: 'Plus Jakarta Sans',
                                    fontWeight: FontWeight.w700,
                                    fontSize: 30,
                                    height: 1.25,
                                    letterSpacing: -0.75,
                                    color: Color(0xFF2B2B2B),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Text(
                                playerState.currentArtist,
                                style: const TextStyle(
                                  fontFamily: 'Plus Jakarta Sans',
                                  fontWeight: FontWeight.w400,
                                  fontSize: 18,
                                  height: 1.5,
                                  color: Color(0xB32B2B2B),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (playerState.currentCategory != null) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFBFE6A8),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        playerState.currentCategory!.emoji,
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        playerState.currentCategory!.displayName,
                                        style: const TextStyle(
                                          fontFamily: 'Plus Jakarta Sans',
                                          fontWeight: FontWeight.w600,
                                          fontSize: 12,
                                          color: Color(0xFF2B2B2B),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Row(
                      children: [
                        // 위시리스트 추가/제거 버튼
                        Consumer(
                          builder: (context, ref, child) {
                            final wishlist = ref.watch(wishlistProvider);
                            final isInWishlist = wishlist.any(
                              (item) =>
                                  item.title == playerState.currentSongTitle &&
                                  item.artist == playerState.currentArtist,
                            );

                            return GestureDetector(
                              onTap: () {
                                if (isInWishlist) {
                                  // 위시리스트에서 제거
                                  final item = wishlist.firstWhere(
                                    (item) =>
                                        item.title ==
                                            playerState.currentSongTitle &&
                                        item.artist ==
                                            playerState.currentArtist,
                                  );
                                  ref
                                      .read(wishlistProvider.notifier)
                                      .removeFromWishlist(item.id);
                                } else {
                                  // 위시리스트에 추가 (카테고리 포함)
                                  ref
                                      .read(wishlistProvider.notifier)
                                      .addToWishlist(
                                        title: playerState.currentSongTitle,
                                        artist: playerState.currentArtist,
                                        albumArtUrl: playerState.thumbnailUrl,
                                        previewUrl: playerState.videoUrl,
                                        category: playerState.currentCategory,
                                      );
                                }
                              },
                              child: _buildIconButton(
                                isInWishlist
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () async {
                            // iTunes 링크로 음악 공유
                            final itunesUrl = playerState.itunesUrl;
                            if (itunesUrl != null) {
                              await SharePlus.instance.share(
                                ShareParams(
                                  text: '🎵 ${playerState.currentSongTitle} - ${playerState.currentArtist}\n\niTunes에서 들어보세요:\n$itunesUrl',
                                  subject: '음악 공유',
                                ),
                              );
                            } else {
                              // iTunes 링크가 없으면 기본 정보 공유
                              await SharePlus.instance.share(
                                ShareParams(
                                  text: '🎵 ${playerState.currentSongTitle} - ${playerState.currentArtist}',
                                  subject: '음악 공유',
                                ),
                              );
                            }
                          },
                          child: _buildIconButton(Icons.share_outlined),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 재생 컨트롤
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    // 재생 바와 재생/일시정지 버튼
                    Row(
                      children: [
                        Consumer(
                          builder: (context, ref, child) {
                            final isPlaying =
                                ref.watch(musicPlayerProvider.select((s) => s.isPlaying));
                            return GestureDetector(
                              onTap: () {
                                ref.read(musicPlayerProvider.notifier).togglePlayPause();
                              },
                              child: _buildPlayPauseButton(isPlaying),
                            );
                          },
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Consumer(
                            builder: (context, ref, child) {
                              final progress =
                                  ref.watch(musicPlayerProvider.select((s) => s.progress));
                              final duration =
                                  ref.watch(musicPlayerProvider.select((s) => s.duration));

                              return GestureDetector(
                                onTapDown: (details) {
                                  final box = context.findRenderObject() as RenderBox?;
                                  if (box == null) {
                                    return;
                                  }
                                  final localPosition = details.localPosition;
                                  final tapProgress = localPosition.dx / box.size.width;
                                  final position = duration * tapProgress;
                                  ref.read(musicPlayerProvider.notifier).seek(position);
                                },
                                child: Container(
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE5E7EB),
                                    borderRadius: BorderRadius.circular(9999),
                                  ),
                                  child: LayoutBuilder(
                                    builder: (context, constraints) {
                                      return Align(
                                        alignment: Alignment.centerLeft,
                                        child: Container(
                                          width: constraints.maxWidth * progress,
                                          height: 8,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF2B2B2B),
                                            borderRadius: BorderRadius.circular(9999),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Consumer(
                          builder: (context, ref, child) {
                            final formattedPosition = ref.watch(
                                musicPlayerProvider.select((s) => s.formattedPosition));
                            return Text(
                              formattedPosition,
                              style: const TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontWeight: FontWeight.w400,
                                fontSize: 12,
                                height: 1.33,
                                color: Color(0x802B2B2B),
                              ),
                            );
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 40),

                    // 이모지 반응 버튼들
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildEmojiButton(
                          '👍',
                          MusicFeedbackType.like,
                          playerState.currentFeedback == MusicFeedbackType.like,
                        ),
                        const SizedBox(width: 24),
                        _buildEmojiButton(
                          '🤔',
                          MusicFeedbackType.neutral,
                          playerState.currentFeedback == MusicFeedbackType.neutral,
                        ),
                        const SizedBox(width: 24),
                        _buildEmojiButton(
                          '👎',
                          MusicFeedbackType.dislike,
                          playerState.currentFeedback == MusicFeedbackType.dislike,
                        ),
                      ],
                    ),

                    const SizedBox(height: 40),

                    // 다음 노래 버튼
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () {
                          ref.read(musicPlayerProvider.notifier).next();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFBFE6A8),
                          foregroundColor: const Color(0xFF2B2B2B),
                          elevation: 0,
                          shadowColor: const Color(0x12000000),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: const Text(
                          '다음 노래',
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // 하단 위시리스트 버튼
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  color: Color(0xCCFFF9F1),
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // 위시리스트 화면으로 이동
                      Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (context) => const WishlistScreen(),
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.favorite_border,
                      size: 24,
                    ),
                    label: const Text(
                      '위시리스트 보기',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                        height: 1.5,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFBFE6A8),
                      foregroundColor: const Color(0xFF2B2B2B),
                      elevation: 0,
                      shadowColor: const Color(0x12000000),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIconButton(IconData icon) {
    return Container(
      width: 48,
      height: 48,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Color(0x12000000),
            offset: Offset(0, 4),
            blurRadius: 12,
          ),
        ],
      ),
      child: Icon(
        icon,
        size: 24,
        color: const Color(0xFF2B2B2B),
      ),
    );
  }

  Widget _buildPlayPauseButton(bool isPlaying) {
    return Container(
      width: 48,
      height: 48,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Color(0x12000000),
            offset: Offset(0, 4),
            blurRadius: 12,
          ),
        ],
      ),
      child: Icon(
        isPlaying ? Icons.pause : Icons.play_arrow,
        size: 24,
        color: const Color(0xFF2B2B2B),
      ),
    );
  }

  Widget _buildEmojiButton(
    String emoji,
    MusicFeedbackType feedbackType,
    bool isSelected,
  ) {
    return GestureDetector(
      onTap: () {
        ref.read(musicPlayerProvider.notifier).setFeedback(feedbackType);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFBFE6A8) : Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: const Color(0x12000000),
              offset: const Offset(0, 4),
              blurRadius: isSelected ? 16 : 12,
            ),
          ],
          border: isSelected
              ? Border.all(
                  color: const Color(0xFF2B2B2B),
                  width: 2,
                )
              : null,
        ),
        child: Center(
          child: Text(
            emoji,
            style: TextStyle(
              fontSize: isSelected ? 34 : 30,
              height: 1.2,
            ),
          ),
        ),
      ),
    );
  }
}
