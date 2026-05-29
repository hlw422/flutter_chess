import 'package:flutter/material.dart';
import '../core/enums/game_mode.dart';
import '../core/enums/difficulty.dart';
import '../games/gomoku/widgets/gomoku_game_screen.dart';

/// 游戏设置页面
class GameSetupScreen extends StatefulWidget {
  final GameType gameType;

  const GameSetupScreen({super.key, required this.gameType});

  @override
  State<GameSetupScreen> createState() => _GameSetupScreenState();
}

class _GameSetupScreenState extends State<GameSetupScreen> {
  GameMode _selectedMode = GameMode.pvp;
  Difficulty _selectedDifficulty = Difficulty.medium;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        title: Text('${widget.gameType.label} - 游戏设置'),
        backgroundColor: const Color(0xFF16213E),
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1A1A2E), Color(0xFF0F3460)],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('选择模式'),
              const SizedBox(height: 16),
              _buildModeSelection(),
              const SizedBox(height: 32),
              if (_selectedMode == GameMode.pve) ...[
                _buildSectionTitle('选择难度'),
                const SizedBox(height: 16),
                _buildDifficultySelection(),
                const SizedBox(height: 32),
              ],
              const Spacer(),
              _buildStartButton(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildModeSelection() {
    return Row(
      children: GameMode.values.map((mode) {
        final isSelected = _selectedMode == mode;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _selectedMode = mode),
            child: Container(
              margin: EdgeInsets.only(right: mode == GameMode.pvp ? 12 : 0, left: mode == GameMode.pve ? 12 : 0),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFFD4A574).withOpacity(0.2)
                    : const Color(0xFF16213E),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? const Color(0xFFD4A574) : const Color(0xFF2A2A4A),
                  width: 2,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    mode == GameMode.pvp ? Icons.people : Icons.computer,
                    size: 40,
                    color: isSelected ? const Color(0xFFD4A574) : const Color(0xFFB0B0B0),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    mode.label,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : const Color(0xFFB0B0B0),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    mode.description,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: isSelected
                          ? const Color(0xFFD4A574)
                          : const Color(0xFF666666),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDifficultySelection() {
    return Row(
      children: Difficulty.values.map((diff) {
        final isSelected = _selectedDifficulty == diff;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _selectedDifficulty = diff),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 6),
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              decoration: BoxDecoration(
                color: isSelected
                    ? _getDifficultyColor(diff).withOpacity(0.2)
                    : const Color(0xFF16213E),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? _getDifficultyColor(diff) : const Color(0xFF2A2A4A),
                  width: 2,
                ),
              ),
              child: Column(
                children: [
                  Text(
                    diff.label,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? _getDifficultyColor(diff) : const Color(0xFFB0B0B0),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    diff.description,
                    style: TextStyle(
                      fontSize: 11,
                      color: isSelected
                          ? _getDifficultyColor(diff).withOpacity(0.8)
                          : const Color(0xFF666666),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Color _getDifficultyColor(Difficulty diff) {
    switch (diff) {
      case Difficulty.easy:
        return const Color(0xFF4CAF50);
      case Difficulty.medium:
        return const Color(0xFFFFC107);
      case Difficulty.hard:
        return const Color(0xFFF44336);
    }
  }

  Widget _buildStartButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _startGame,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFD4A574),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 8,
          shadowColor: const Color(0xFFD4A574).withOpacity(0.4),
        ),
        child: const Text(
          '开始游戏',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 2),
        ),
      ),
    );
  }

  void _startGame() {
    if (widget.gameType == GameType.gomoku) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => GomokuGameScreen(
            gameMode: _selectedMode,
            difficulty: _selectedMode == GameMode.pve ? _selectedDifficulty : null,
          ),
        ),
      );
    }
  }
}
