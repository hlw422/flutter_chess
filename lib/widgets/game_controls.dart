import 'package:flutter/material.dart';

/// 游戏控制按钮组件
class GameControls extends StatelessWidget {
  final bool canUndo;
  final VoidCallback onUndo;
  final VoidCallback onResign;
  final VoidCallback onRestart;
  final bool isVertical;

  const GameControls({
    super.key,
    required this.canUndo,
    required this.onUndo,
    required this.onResign,
    required this.onRestart,
    this.isVertical = false,
  });

  @override
  Widget build(BuildContext context) {
    final buttons = [
      _buildButton(
        icon: Icons.undo,
        label: '悔棋',
        onPressed: canUndo ? onUndo : null,
        color: const Color(0xFF4CAF50),
      ),
      _buildButton(
        icon: Icons.flag,
        label: '认输',
        onPressed: onResign,
        color: const Color(0xFFF44336),
      ),
      _buildButton(
        icon: Icons.refresh,
        label: '重来',
        onPressed: onRestart,
        color: const Color(0xFF2196F3),
      ),
    ];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isVertical ? 8 : 20),
      child: isVertical
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: buttons
                  .map((b) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: b,
                      ))
                  .toList(),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: buttons,
            ),
    );
  }

  Widget _buildButton({
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
    required Color color,
  }) {
    return SizedBox(
      width: isVertical ? 140 : 100,
      height: 44,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 18),
        label: Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
        style: ElevatedButton.styleFrom(
          backgroundColor: onPressed != null ? color : Colors.grey[800],
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: onPressed != null ? 4 : 0,
        ),
      ),
    );
  }
}
