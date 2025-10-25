import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:template/features/music_player/controllers/music_player_controller.dart';
import 'package:template/features/wishlist/controllers/wishlist_controller.dart';

/// 위시리스트 화면
class WishlistScreen extends ConsumerWidget {
  /// [WishlistScreen] 생성자
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wishlistState = ref.watch(wishlistProvider);
    final sortedItems = wishlistState.sortedItems;

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
              // 헤더
              Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(
                        Icons.arrow_back_ios,
                        color: Color(0xFF2B2B2B),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      '위시리스트',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontWeight: FontWeight.w700,
                        fontSize: 24,
                        color: Color(0xFF2B2B2B),
                      ),
                    ),
                  ],
                ),
              ),

              // 정렬 필터
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    _buildFilterChip(
                      context,
                      ref,
                      '최근 추가순',
                      WishlistSortOption.recentlyAdded,
                      wishlistState.sortOption,
                    ),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                      context,
                      ref,
                      '제목순',
                      WishlistSortOption.title,
                      wishlistState.sortOption,
                    ),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                      context,
                      ref,
                      '아티스트순',
                      WishlistSortOption.artist,
                      wishlistState.sortOption,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // 위시리스트 목록
              Expanded(
                child: sortedItems.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.favorite_border,
                              size: 64,
                              color: Color(0xFFE0E0E0),
                            ),
                            SizedBox(height: 16),
                            Text(
                              '위시리스트가 비어있습니다',
                              style: TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: 16,
                                color: Color(0xB32B2B2B),
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        itemCount: sortedItems.length,
                        itemBuilder: (context, index) {
                          final item = sortedItems[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x0F000000),
                                    blurRadius: 10,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () {
                                    // 음악 재생
                                    if (item.previewUrl != null) {
                                      ref
                                          .read(musicPlayerProvider.notifier)
                                          .loadMusicWithAlbumArt(
                                            artist: item.artist,
                                            title: item.title,
                                          );
                                      Navigator.pop(context);
                                    }
                                  },
                                  borderRadius: BorderRadius.circular(16),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Row(
                                      children: [
                                        // 앨범 아트
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          child: item.albumArtUrl != null
                                              ? Image.network(
                                                  item.albumArtUrl!,
                                                  width: 60,
                                                  height: 60,
                                                  fit: BoxFit.cover,
                                                  errorBuilder:
                                                      (
                                                        context,
                                                        error,
                                                        stackTrace,
                                                      ) {
                                                        return const ColoredBox(
                                                          color: Color(
                                                            0xFFE5E7EB,
                                                          ),
                                                          child: SizedBox(
                                                            width: 60,
                                                            height: 60,
                                                            child: Icon(
                                                              Icons.music_note,
                                                              color: Color(
                                                                0xFF9CA3AF,
                                                              ),
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                )
                                              : const ColoredBox(
                                                  color: Color(0xFFE5E7EB),
                                                  child: SizedBox(
                                                    width: 60,
                                                    height: 60,
                                                    child: Icon(
                                                      Icons.music_note,
                                                      color: Color(0xFF9CA3AF),
                                                    ),
                                                  ),
                                                ),
                                        ),
                                        const SizedBox(width: 16),

                                        // 곡 정보
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                item.title,
                                                style: const TextStyle(
                                                  fontFamily:
                                                      'Plus Jakarta Sans',
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 16,
                                                  color: Color(0xFF2B2B2B),
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                item.artist,
                                                style: const TextStyle(
                                                  fontFamily:
                                                      'Plus Jakarta Sans',
                                                  fontSize: 14,
                                                  color: Color(0xB32B2B2B),
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                        ),

                                        // 삭제 버튼
                                        IconButton(
                                          onPressed: () {
                                            ref
                                                .read(wishlistProvider.notifier)
                                                .removeFromWishlist(item.id);
                                          },
                                          icon: const Icon(
                                            Icons.delete_outline,
                                            color: Color(0xFFEF4444),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
