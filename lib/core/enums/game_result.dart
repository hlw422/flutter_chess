import 'player.dart';
import '../models/position.dart';

/// 游戏结果枚举
enum GameResultType {
  win('胜利'),
  draw('平局'),
  resign('认输'),
  none('进行中');

  final String label;
  const GameResultType(this.label);
}

/// 游戏结果
class GameResult {
  final GameResultType type;
  final Player? winner;
  final List<dynamic>? winPath;
  final Position? winningMove;

  const GameResult({
    required this.type,
    this.winner,
    this.winPath,
    this.winningMove,
  });

  bool get isGameOver => type != GameResultType.none;

  String get message {
    switch (type) {
      case GameResultType.win:
        return '${winner?.label ?? ""}获胜！';
      case GameResultType.draw:
        return '平局！';
      case GameResultType.resign:
        return '${winner?.opponent.label ?? ""}认输，${winner?.label ?? ""}获胜！';
      case GameResultType.none:
        return '游戏进行中';
    }
  }

  /// 获取绝杀位置的显示文本
  String? get winningMoveText {
    if (winningMove == null) return null;
    return '第${winningMove!.row + 1}行第${winningMove!.col + 1}列';
  }
}
