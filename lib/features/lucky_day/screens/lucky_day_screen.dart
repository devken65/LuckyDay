import 'package:flutter/material.dart';
import 'package:template/features/lucky_day/widgets/lucky_day_logo.dart';
import 'package:template/features/music_player/screens/music_player_screen.dart';
import 'package:template/features/wishlist/screens/wishlist_screen.dart';

/// Lucky Day 메인 화면
///
/// 음악으로 하루를 특별하게 만들어주는 웰컴 스크린입니다.
class LuckyDayScreen extends StatefulWidget {
  /// [LuckyDayScreen] 생성자
  const LuckyDayScreen({super.key});

  @override
  State<LuckyDayScreen> createState() => _LuckyDayScreenState();
}

class _LuckyDayScreenState extends State<LuckyDayScreen> {
  bool _isWishlistButtonPressed = false;

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: SizedBox.expand(
        child: DecoratedBox(
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
              // Header - 익명 사용자 표시
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFFBFE6A8).withValues(alpha: 0.3),
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.person_outline,
                            size: 16,
                            color: Color(0xFF2B2B2B),
                          ),
                          SizedBox(width: 6),
                          Text(
                            '익명 사용자',
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF2B2B2B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Spacer
              const Spacer(),

              // Lucky Day Logo (탭하면 음악 추천 화면으로 이동)
              LuckyDayLogo(
                onPressed: () {
                  // 페이지 전환 애니메이션과 함께 이동
                  Navigator.push(
                    context,
                    PageRouteBuilder<void>(
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          const MusicPlayerScreen(),
                      transitionsBuilder:
                          (context, animation, secondaryAnimation, child) {
                        const begin = Offset(0, 1);
                        const end = Offset.zero;
                        const curve = Curves.easeInOutCubic;

                        final tween = Tween(begin: begin, end: end)
                            .chain(CurveTween(curve: curve));
                        final offsetAnimation = animation.drive(tween);

                        return SlideTransition(
                          position: offsetAnimation,
                          child: FadeTransition(
                            opacity: animation,
                            child: child,
                          ),
                        );
                      },
                      transitionDuration: const Duration(milliseconds: 500),
                    ),
                  );
                },
              ),

              const SizedBox(height: 49),

              // Description Text
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  '당신의 하루를 음악으로\n조금 더 특별하게 만들어주는 순간',
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    height: 1.5,
                    color: Color(0xFF2B2B2B),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              const Spacer(),

              // Footer Button (내 위시리스트)
              GestureDetector(
                onTapDown: (_) {
                  setState(() {
                    _isWishlistButtonPressed = true;
                  });
                },
                onTapUp: (_) {
                  setState(() {
                    _isWishlistButtonPressed = false;
                  });
                  // 위시리스트 화면으로 이동
                  Navigator.push(
                    context,
                    PageRouteBuilder<void>(
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          const WishlistScreen(),
                      transitionsBuilder:
                          (context, animation, secondaryAnimation, child) {
                        const begin = Offset(1, 0);
                        const end = Offset.zero;
                        const curve = Curves.easeInOutCubic;

                        final tween = Tween(begin: begin, end: end)
                            .chain(CurveTween(curve: curve));
                        final offsetAnimation = animation.drive(tween);

                        return SlideTransition(
                          position: offsetAnimation,
                          child: FadeTransition(
                            opacity: animation,
                            child: child,
                          ),
                        );
                      },
                      transitionDuration: const Duration(milliseconds: 400),
                    ),
                  );
                },
                onTapCancel: () {
                  setState(() {
                    _isWishlistButtonPressed = false;
                  });
                },
                child: AnimatedScale(
                  scale: _isWishlistButtonPressed ? 0.95 : 1.0,
                  duration: const Duration(milliseconds: 150),
                  curve: Curves.easeInOut,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: _isWishlistButtonPressed
                            ? [
                                const Color(0xFFBFE6A8),
                                const Color(0xFFA8D68F),
                              ]
                            : [
                                const Color(0xFFBFE6A8),
                                const Color(0xFFBFE6A8),
                              ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFBFE6A8).withValues(alpha: 0.4),
                          offset: const Offset(0, 4),
                          blurRadius: _isWishlistButtonPressed ? 8 : 12,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.favorite,
                          size: 22,
                          color: _isWishlistButtonPressed
                              ? Colors.white
                              : const Color(0xFF2B2B2B),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          '내 위시리스트',
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: _isWishlistButtonPressed
                                ? Colors.white
                                : const Color(0xFF2B2B2B),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
