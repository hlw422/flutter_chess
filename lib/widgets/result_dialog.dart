import 'package:flutter/material.dart';
import '../core/enums/game_result.dart';

/// 游戏结果弹窗
class ResultDialog extends StatelessWidget {
  final GameResult result;
  final VoidCallback onRestart;
  final VoidCallback onExit;

  const ResultDialog({
    super.key,
    required this.result,
    required this.onRestart,
    required this.onExit,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      alignment: Alignment.bottomCenter, // 弹窗显示在底部
      insetPadding: const EdgeInsets.all(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFD4A574), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 标题行（图标+标题+消息在同一行）
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 图标
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _getIconColor().withOpacity(0.2),
                    border: Border.all(color: _getIconColor(), width: 1.5),
                  ),
                  child: Icon(
                    _getIcon(),
                    size: 22,
                    color: _getIconColor(),
                  ),
                ),
                const SizedBox(width: 12),
                // 标题和消息
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getTitle(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        result.message,
                        style: const TextStyle(
                          color: Color(0xFFB0B0B0),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // 绝杀位置信息
            if (result.winningMove != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFD4A574).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.location_on,
                      color: Color(0xFFD4A574),
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '绝杀：${result.winningMoveText}',
                      style: const TextStyle(
                        color: Color(0xFFD4A574),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
            // 按钮（水平排列，更紧凑）
            Row(
              children: [
                Expanded(
                  child: _buildButton(
                    label: '退出',
                    onPressed: onExit,
                    color: const Color(0xFF424242),
                    height: 40,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildButton(
                    label: '再来一局',
                    onPressed: onRestart,
                    color: const Color(0xFFD4A574),
                    height: 40,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getTitle() {
    switch (result.type) {
      case GameResultType.win:
        return '恭喜获胜！';
      case GameResultType.draw:
        return '平局';
      case GameResultType.resign:
        return '认输';
      default:
        return '游戏结束';
    }
  }

  IconData _getIcon() {
    switch (result.type) {
      case GameResultType.win:
        return Icons.emoji_events;
      case GameResultType.draw:
        return Icons.handshake;
      case GameResultType.resign:
        return Icons.flag;
      default:
        return Icons.info;
    }
  }

  Color _getIconColor() {
    switch (result.type) {
      case GameResultType.win:
        return const Color(0xFFFFC107);
      case GameResultType.draw:
        return const Color(0xFF2196F3);
      case GameResultType.resign:
        return const Color(0xFFF44336);
      default:
        return Colors.grey;
    }
  }

  Widget _buildButton({
    required String label,
    required VoidCallback onPressed,
    required Color color,
    double height = 48,
  }) {
    return SizedBox(
      height: height,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          elevation: 4,
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
