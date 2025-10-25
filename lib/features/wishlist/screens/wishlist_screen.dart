import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:uuid/uuid.dart';
import 'package:template/features/music_player/controllers/music_player_controller.dart';
import 'package:template/features/wishlist/controllers/wishlist_controller.dart';
import 'package:template/features/wishlist/models/wishlist_item.dart';

/// 정렬 옵션
enum SortOption {
  recent('최근 추가순'),
  title('제목순'),
  artist('아티스트순');

  const SortOption(this.label);
  final String label;
}

/// 위시리스트 화면
class WishlistScreen extends ConsumerStatefulWidget {
  /// [WishlistScreen] 생성자
  const WishlistScreen({super.key});

  @override
  ConsumerState<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends ConsumerState<WishlistScreen> {
  SortOption _currentSort = SortOption.recent;

  @override
  Widget build(BuildContext context) {
    final wishlist = ref.watch(wishlistProvider);

    // 정렬 적용
    final sortedWishlist = _sortWishlist(wishlist);

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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
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
                        const Expanded(
                          child: Text(
                            '위시리스트',
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontWeight: FontWeight.w700,
                              fontSize: 24,
                              color: Color(0xFF2B2B2B),
                            ),
                          ),
                        ),
                        // 키로 보기 버튼
                        IconButton(
                          onPressed: _showViewByKeyDialog,
                          icon: const Icon(
                            Icons.key,
                            color: Color(0xFF2B2B2B),
                          ),
                          tooltip: '키로 보기',
                        ),
                        // 키로 공유 버튼
                        IconButton(
                          onPressed: _shareWithKey,
                          icon: const Icon(
                            Icons.share_outlined,
                            color: Color(0xFF2B2B2B),
                          ),
                          tooltip: '키로 공유',
                        ),
                      ],
                    ),
                    if (wishlist.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      // 카테고리 통계
                      _buildCategoryStats(),
                      const SizedBox(height: 16),
                      // 정렬 필터
                      _buildSortFilter(),
                    ],
                  ],
                ),
              ),

              // 위시리스트 목록
              Expanded(
                child: sortedWishlist.isEmpty
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
                        itemCount: sortedWishlist.length,
                        itemBuilder: (context, index) {
                          final item = sortedWishlist[index];
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
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          child: item.albumArtUrl != null
                                              ? Image.network(
                                                  item.albumArtUrl!,
                                                  width: 60,
                                                  height: 60,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (context,
                                                      error, stackTrace) {
                                                    return const ColoredBox(
                                                      color: Color(0xFFE5E7EB),
                                                      child: SizedBox(
                                                        width: 60,
                                                        height: 60,
                                                        child: Icon(
                                                          Icons.music_note,
                                                          color:
                                                              Color(0xFF9CA3AF),
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
                                              Row(
                                                children: [
                                                  Flexible(
                                                    child: Text(
                                                      item.artist,
                                                      style: const TextStyle(
                                                        fontFamily:
                                                            'Plus Jakarta Sans',
                                                        fontSize: 14,
                                                        color: Color(0xB32B2B2B),
                                                      ),
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                  if (item.category != null) ...[
                                                    const SizedBox(width: 8),
                                                    Container(
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                        horizontal: 6,
                                                        vertical: 2,
                                                      ),
                                                      decoration: BoxDecoration(
                                                        color:
                                                            const Color(0xFFBFE6A8),
                                                        borderRadius:
                                                            BorderRadius.circular(8),
                                                      ),
                                                      child: Row(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          Text(
                                                            item.category!.emoji,
                                                            style: const TextStyle(
                                                                fontSize: 10),
                                                          ),
                                                          const SizedBox(width: 2),
                                                          Text(
                                                            item.category!
                                                                .displayName,
                                                            style: const TextStyle(
                                                              fontFamily:
                                                                  'Plus Jakarta Sans',
                                                              fontWeight:
                                                                  FontWeight.w600,
                                                              fontSize: 10,
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

  /// 위시리스트 정렬
  List<WishlistItem> _sortWishlist(List<WishlistItem> items) {
    final sorted = List<WishlistItem>.from(items);

    switch (_currentSort) {
      case SortOption.recent:
        sorted.sort((a, b) => b.addedAt.compareTo(a.addedAt)); // 최근순
      case SortOption.title:
        sorted.sort((a, b) => a.title.compareTo(b.title)); // 제목순
      case SortOption.artist:
        sorted.sort((a, b) => a.artist.compareTo(b.artist)); // 아티스트순
    }

    return sorted;
  }

  /// 카테고리 통계 UI
  Widget _buildCategoryStats() {
    final stats = ref.read(wishlistProvider.notifier).getCategoryStatistics();

    if (stats.isEmpty) {
      return const SizedBox.shrink();
    }

    // 상위 3개 카테고리만 표시
    final sortedStats = stats.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topStats = sortedStats.take(3);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF9F1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFBFE6A8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.bar_chart, size: 16, color: Color(0xFF2B2B2B)),
              SizedBox(width: 8),
              Text(
                '내가 좋아하는 장르',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: Color(0xFF2B2B2B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: topStats.map((entry) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFBFE6A8),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '${entry.key.emoji} ${entry.key.displayName} ${entry.value.toStringAsFixed(0)}%',
                  style: const TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    color: Color(0xFF2B2B2B),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  /// 정렬 필터 UI
  Widget _buildSortFilter() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: SortOption.values.map((option) {
          final isSelected = _currentSort == option;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(option.label),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _currentSort = option;
                  });
                }
              },
              backgroundColor: Colors.white,
              selectedColor: const Color(0xFFBFE6A8),
              labelStyle: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontWeight: FontWeight.w600,
                fontSize: 12,
                color: isSelected
                    ? const Color(0xFF2B2B2B)
                    : const Color(0xB32B2B2B),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: isSelected
                      ? const Color(0xFFBFE6A8)
                      : const Color(0xFFE0E0E0),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  /// 키로 공유하기
  Future<void> _shareWithKey() async {
    final wishlist = ref.read(wishlistProvider);

    if (wishlist.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('공유할 곡이 없습니다')),
      );
      return;
    }

    // UUID로 고유 키 생성
    const uuid = Uuid();
    final shareKey = uuid.v4().substring(0, 8).toUpperCase();

    // 위시리스트를 JSON 형태로 인코딩 (간단한 형태)
    final buffer = StringBuffer();
    for (var i = 0; i < wishlist.length; i++) {
      final item = wishlist[i];
      final categoryCode = item.category?.name ?? '';
      buffer.write('${item.title}|${item.artist}|$categoryCode');
      if (i < wishlist.length - 1) {
        buffer.write(';');
      }
    }

    if (!mounted) return;

    // 키와 함께 안내 메시지 표시
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('위시리스트 공유 키'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '이 키를 친구에게 공유하세요!\n친구가 키를 입력하면 당신의 위시리스트를 볼 수 있습니다.',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF9F1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFBFE6A8)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    shareKey,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'monospace',
                      color: Color(0xFF2B2B2B),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: shareKey));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('키가 복사되었습니다')),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '⚠️ 이 키는 현재 위시리스트 상태를 공유합니다.\n(데모 버전: 실제로는 서버에 저장되어야 합니다)',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('닫기'),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              Navigator.pop(context);
              await SharePlus.instance.share(
                ShareParams(
                  text: '🎵 나의 위시리스트를 공유합니다!\n\n'
                      'Lucky Day 앱에서 이 키를 입력하세요:\n$shareKey\n\n'
                      '(키로 보기 버튼 → 키 입력)',
                  subject: '위시리스트 공유',
                ),
              );
            },
            icon: const Icon(Icons.share),
            label: const Text('키 공유하기'),
          ),
        ],
      ),
    );
  }

  /// 키로 위시리스트 보기
  Future<void> _showViewByKeyDialog() async {
    final keyController = TextEditingController();

    if (!mounted) return;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('키로 위시리스트 보기'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '친구가 공유한 키를 입력하세요:',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: keyController,
              decoration: const InputDecoration(
                hintText: '예: ABC12345',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.vpn_key),
              ),
              textCapitalization: TextCapitalization.characters,
              maxLength: 8,
            ),
            const SizedBox(height: 8),
            Text(
              '⚠️ 데모 버전: 실제로는 서버에서 위시리스트를 가져와야 합니다',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              if (keyController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('키를 입력해주세요')),
                );
                return;
              }
              Navigator.pop(context, true);
            },
            child: const Text('확인'),
          ),
        ],
      ),
    );

    if (result == true && mounted) {
      // 데모용: 키가 유효하다고 가정하고 안내 메시지만 표시
      showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('읽기 전용 위시리스트'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.info_outline,
                size: 64,
                color: Color(0xFFBFE6A8),
              ),
              const SizedBox(height: 16),
              Text(
                '입력한 키: ${keyController.text.toUpperCase()}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                '실제 서비스에서는 서버에서 해당 키의\n위시리스트를 가져와 읽기 전용으로 표시됩니다.\n\n'
                '• 곡 추가/삭제 불가\n'
                '• 정렬만 가능\n'
                '• 친구의 음악 취향 확인 가능',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('확인'),
            ),
          ],
        ),
      );
    }

    keyController.dispose();
  }
}
