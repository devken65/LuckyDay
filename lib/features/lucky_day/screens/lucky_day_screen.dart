import 'package:flutter/material.dart';
import 'package:template/features/lucky_day/widgets/lucky_day_logo.dart';
import 'package:template/features/music_player/screens/music_player_screen.dart';
import 'package:template/features/wishlist/screens/wishlist_screen.dart';

/// Lucky Day 메인 화면
///
/// 음악으로 하루를 특별하게 만들어주는 웰컴 스크린입니다.
class LuckyDayScreen extends StatelessWidget {
  /// [LuckyDayScreen] 생성자
  const LuckyDayScreen({super.key});

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
              // Header 공간
              const SizedBox(height: 64),

              // Spacer
              const Spacer(),

              // Lucky Day Logo (탭하면 음악 추천 화면으로 이동)
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (context) => const MusicPlayerScreen(),
                    ),
                  );
                },
                child: const LuckyDayLogo(),
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

              // Footer Button
              GestureDetector(
                onTap: () {
                  // 위시리스트 화면으로 이동
                  Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (context) => const WishlistScreen(),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    '위시리스트 보기',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF2B2B2B),
                    ),
                    textAlign: TextAlign.center,
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
