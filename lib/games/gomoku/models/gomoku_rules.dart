import '../../../core/enums/player.dart';
import '../../../core/enums/game_result.dart';
import '../../../core/interfaces/game_board.dart';
import '../../../core/interfaces/game_rules.dart';
import '../../../core/models/position.dart';

/// 五子棋规则实现
class GomokuRules implements GameRules {
  Player _currentPlayer = Player.black;

  @override
  Player get currentPlayer => _currentPlayer;

  @override
  bool isValidMove(GameBoard board, Position position, Player player) {
    if (!position.isInBounds(board.size)) return false;
    if (board.getPiece(position) != Player.none) return false;
    return true;
  }

  @override
  GameResult checkGameResult(GameBoard board, Player lastPlayer, Position lastMove) {
    // 检查是否获胜
    final winPath = checkWin(board, lastMove, lastPlayer);
    if (winPath != null) {
      return GameResult(
        type: GameResultType.win,
        winner: lastPlayer,
        winPath: winPath,
        winningMove: lastMove,
      );
    }

    // 检查是否平局
    if (board.occupiedPositions.length == board.size * board.size) {
      return const GameResult(type: GameResultType.draw);
    }

    return const GameResult(type: GameResultType.none);
  }

  /// 检查是否五连
  List<Position>? checkWin(GameBoard board, Position position, Player player) {
    // 四个方向：水平、垂直、正斜、反斜
    final directions = [
      [0, 1],  // 水平
      [1, 0],  // 垂直
      [1, 1],  // 正斜
      [1, -1], // 反斜
    ];

    for (final dir in directions) {
      final path = <Position>[position];
      
      // 正向检查
      for (int i = 1; i < 5; i++) {
        final pos = Position(position.row + dir[0] * i, position.col + dir[1] * i);
        if (pos.isInBounds(board.size) && board.getPiece(pos) == player) {
          path.add(pos);
        } else {
          break;
        }
      }

      // 反向检查
      for (int i = 1; i < 5; i++) {
        final pos = Position(position.row - dir[0] * i, position.col - dir[1] * i);
        if (pos.isInBounds(board.size) && board.getPiece(pos) == player) {
          path.add(pos);
        } else {
          break;
        }
      }

      if (path.length >= 5) {
        return path;
      }
    }

    return null;
  }

  /// 切换当前玩家
  void switchPlayer() {
    _currentPlayer = _currentPlayer.opponent;
  }

  /// 重置为黑棋先行
  void reset() {
    _currentPlayer = Player.black;
  }
}
