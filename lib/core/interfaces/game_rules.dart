import '../enums/player.dart';
import '../enums/game_result.dart';
import '../models/position.dart';
import 'game_board.dart';

/// 游戏规则抽象接口
abstract class GameRules {
  /// 检查落子是否合法
  bool isValidMove(GameBoard board, Position position, Player player);

  /// 检查游戏是否结束
  GameResult checkGameResult(GameBoard board, Player lastPlayer, Position lastMove);

  /// 获取当前玩家
  Player get currentPlayer;
}
