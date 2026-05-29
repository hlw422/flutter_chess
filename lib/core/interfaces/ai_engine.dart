import '../enums/player.dart';
import '../enums/difficulty.dart';
import '../models/position.dart';
import 'game_board.dart';

/// AI引擎抽象接口
abstract class AIEngine {
  /// AI难度
  Difficulty get difficulty;

  /// AI棋手颜色
  Player get aiPlayer;

  /// 计算AI下一步
  Future<Position> calculateMove(GameBoard board, Player currentPlayer);
}
