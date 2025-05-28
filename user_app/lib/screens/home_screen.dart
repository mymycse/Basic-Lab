import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'talk_screen.dart';

class Recommendation {
  final String title;
  final String detail;

  const Recommendation({required this.title, required this.detail});
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  final List<Recommendation> _recommendations = const [
    Recommendation(title: '오늘도 잘하고 계세요 😊', detail: '쉬엄쉬엄 해도 괜찮아요. 당신은 충분히 잘하고 있어요.'),
    Recommendation(title: '가벼운 산책 어때요?', detail: '근처 공원이나 아파트 단지를 천천히 걸어보세요. 몸도 마음도 가벼워져요.'),
    Recommendation(title: '따뜻한 차 한잔 어떠세요?', detail: '좋아하는 차를 마시며 잠시 쉬어가도 괜찮아요.'),
  ];

  @override
  Widget build(BuildContext context) {
    final random = Random();
    final recommendation = _recommendations[random.nextInt(_recommendations.length)];

    return Scaffold(
      backgroundColor: Color(0xFFf6f7f9),
      appBar: AppBar(
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: const Align(
          alignment: Alignment.center,
          child: Text(
            '말벗',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
        backgroundColor: Color(0xCC1ea698),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final totalHeight = constraints.maxHeight;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => RecommendationDetailScreen(data: recommendation),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Color(0xFFE2E5E9),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      recommendation.title,
                      style: const TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: totalHeight * 0.34,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1ea698), Color(0xFF81e0d0)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.pushNamed(context, '/talk'),
                      icon: const Icon(Icons.mic, size: 60, color: Colors.white),
                      label: const Text(
                        '대화하기',
                        style: TextStyle(fontSize: 50, color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GridView.count(
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1,
                    children: [
                      _buildFeatureCard(
                        context,
                        title: '퀴즈 풀기',
                        icon: Icons.quiz,
                        route: '',
                        color: Color(0xFFe0e8f3),
                        iconColor: Color(0xFF92acf4),
                      ),
                      _buildFeatureCard(
                        context,
                        title: '습관 확인',
                        icon: Icons.check_circle_outline,
                        route: '/routine',
                        color: Color(0xFFfaeaec),
                        iconColor: Color(0xFFf3888d),
                      ),
                      _buildFeatureCard(
                        context,
                        title: '대화 기록',
                        icon: Icons.chat_bubble_outline,
                        route: '/chatlog',
                        color: Color(0xFFf1e7f3),
                        iconColor: Color(0xFFc794de),
                      ),
                      _buildFeatureCard(
                        context,
                        title: '설정',
                        icon: Icons.settings,
                        route: '/settings',
                        color: Color(0xFFf4edde),
                        iconColor: Color(0xFFe6c58a),
                      ),
                    ],
                  ),
                ),
              )
            ],
          );
        },
      ),
    );
  }

  Widget _buildFeatureCard(BuildContext context,
      {required String title, required IconData icon, required String route, required Color color, required Color iconColor}) {
    return Card(
      color: color,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: InkWell(
        onTap: () {
          if (title == '퀴즈 풀기') {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const TalkScreen(isQuizMode: true),
              ),
            );
          } else {
            Navigator.pushNamed(context, route);
          }
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: iconColor),
              const SizedBox(height: 10),
              Text(
                title,
                style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RecommendationDetailScreen extends StatelessWidget {
  final Recommendation data;
  const RecommendationDetailScreen({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '추천 활동',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green[700],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              data.title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Text(
              data.detail,
              style: const TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}