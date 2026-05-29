import 'package:flutter/foundation.dart';
import '../enums/player.dart';
import '../enums/game_mode.dart';
import '../enums/difficulty.dart';
import '../enums/game_result.dart';
import '../models/position.dart';
import '../models/move.dart';
import 'game_board.dart';

/// 游戏状态
class GameState {
  final GameBoard board;
  final Player currentPlayer;
  final List<Move> moveHistory;
  final GameResult result;
  final bool isAiThinking;

  const GameState({
    required this.board,
    required this.currentPlayer,
    required this.moveHistory,
    required this.result,
    this.isAiThinking = false,
  });

  GameState copyWith({
    GameBoard? board,
    Player? currentPlayer,
    List<Move>? moveHistory,
    GameResult? result,
    bool? isAiThinking,
  }) {
    return GameState(
      board: board ?? this.board,
      currentPlayer: currentPlayer ?? this.currentPlayer,
      moveHistory: moveHistory ?? this.moveHistory,
      result: result ?? this.result,
      isAiThinking: isAiThinking ?? this.isAiThinking,
    );
  }
}

/// 游戏控制器抽象接口
abstract class GameController extends ChangeNotifier {
  /// 游戏模式
  GameMode get gameMode;

  /// 当前游戏状态
  GameState get gameState;

  /// 初始化游戏
  void initGame({GameMode mode, Difficulty? difficulty});

  /// 落子
  Future<bool> makeMove(Position position);

  /// 悔棋
  bool undoMove();

  /// 认输
  void resign();

  /// 重新开始
  void restart();
}
