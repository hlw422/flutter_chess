import 'package:flutter/material.dart';
import '../core/enums/game_mode.dart';
import 'game_setup_screen.dart';

/// 主页
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1A1A2E), Color(0xFF0F3460)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 40),
              _buildHeader(),
              const SizedBox(height: 50),
              Expanded(child: _buildGameCards(context)),
              _buildFooter(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [Color(0xFFD4A574), Color(0xFF8B6914)],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFD4A574).withValues(alpha: 0.4),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(
            Icons.grid_view,
            size: 50,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          '棋艺大师',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 4,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Classic Chess Games',
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFFB0B0B0),
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }

  Widget _buildGameCards(BuildContext context) {
    final games = [
      _GameCardData(
        type: GameType.gomoku,
        icon: Icons.circle_outlined,
        gradient: const [Color(0xFFD4A574), Color(0xFF8B6914)],
        available: true,
      ),
      _GameCardData(
        type: GameType.chineseChess,
        icon: Icons.castle,
        gradient: const [Color(0xFFE57373), Color(0xFFC62828)],
        available: false,
      ),
      _GameCardData(
        type: GameType.internationalChess,
        icon: Icons.sports_esports,
        gradient: const [Color(0xFF64B5F6), Color(0xFF1565C0)],
        available: false,
      ),
    ];

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: games.length,
      itemBuilder: (context, index) => _buildGameCard(context, games[index]),
    );
  }

  Widget _buildGameCard(BuildContext context, _GameCardData data) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GestureDetector(
        onTap: data.available
            ? () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => GameSetupScreen(gameType: data.type),
                  ),
                )
            : null,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: data.available
                  ? data.gradient
                  : [Colors.grey[800]!, Colors.grey[900]!],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: data.available
                ? [
                    BoxShadow(
                      color: data.gradient[0].withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(data.icon, size: 32, color: Colors.white),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.type.label,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      data.available ? data.type.description : '即将推出',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
              if (data.available)
                const Icon(Icons.arrow_forward_ios, color: Colors.white70, size: 20)
              else
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    '敬请期待',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return const Text(
      'v1.0.0',
      style: TextStyle(color: Color(0xFF666666), fontSize: 12),
    );
  }
}

class _GameCardData {
  final GameType type;
  final IconData icon;
  final List<Color> gradient;
  final bool available;

  const _GameCardData({
    required this.type,
    required this.icon,
    required this.gradient,
    required this.available,
  });
}
