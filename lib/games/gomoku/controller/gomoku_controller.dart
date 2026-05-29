import '../../../core/enums/player.dart';
import '../../../core/enums/game_mode.dart';
import '../../../core/enums/difficulty.dart';
import '../../../core/enums/game_result.dart';
import '../../../core/interfaces/game_controller.dart';
import '../../../core/models/position.dart';
import '../../../core/models/move.dart';
import '../models/gomoku_board.dart';
import '../models/gomoku_rules.dart';
import '../ai/gomoku_ai_engine.dart';

/// 五子棋游戏控制器
class GomokuController extends GameController {
  GameMode _gameMode = GameMode.pvp;
  late GomokuBoard _board;
  late GomokuRules _rules;
  GomokuAIEngine? _aiEngine;
  
  Player _currentPlayer = Player.black;
  final List<Move> _moveHistory = [];
  GameResult _result = const GameResult(type: GameResultType.none);
  bool _isAiThinking = false;

  @override
  GameMode get gameMode => _gameMode;

  @override
  GameState get gameState => GameState(
    board: _board,
    currentPlayer: _currentPlayer,
    moveHistory: List.unmodifiable(_moveHistory),
    result: _result,
    isAiThinking: _isAiThinking,
  );

  @override
  void initGame({GameMode mode = GameMode.pvp, Difficulty? difficulty}) {
    _gameMode = mode;
    _board = GomokuBoard();
    _rules = GomokuRules();
    _currentPlayer = Player.black;
    _moveHistory.clear();
    _result = const GameResult(type: GameResultType.none);
    _isAiThinking = false;

    if (mode == GameMode.pve && difficulty != null) {
      _aiEngine = GomokuAIEngine(
        difficulty: difficulty,
        aiPlayer: Player.white,
      );
    } else {
      _aiEngine = null;
    }

    notifyListeners();
  }

  @override
  Future<bool> makeMove(Position position) async {
    if (_result.isGameOver) return false;
    if (_isAiThinking) return false;
    if (!_rules.isValidMove(_board, position, _currentPlayer)) return false;

    // 落子
    _board.placePiece(position, _currentPlayer);
    _moveHistory.add(Move(position: position, player: _currentPlayer));

    // 检查胜负
    _result = _rules.checkGameResult(_board, _currentPlayer, position);
    notifyListeners();

    if (_result.isGameOver) return true;

    // 切换玩家
    _currentPlayer = _currentPlayer.opponent;
    notifyListeners();

    // 人机模式 - AI落子
    if (_gameMode == GameMode.pve && _currentPlayer == Player.white && _aiEngine != null) {
      await _aiMove();
    }

    return true;
  }

  /// AI落子
  Future<void> _aiMove() async {
    _isAiThinking = true;
    notifyListeners();

    try {
      final aiPos = await _aiEngine!.calculateMove(_board, _currentPlayer);
      _board.placePiece(aiPos, _currentPlayer);
      _moveHistory.add(Move(position: aiPos, player: _currentPlayer));

      _result = _rules.checkGameResult(_board, _currentPlayer, aiPos);
      
      if (!_result.isGameOver) {
        _currentPlayer = _currentPlayer.opponent;
      }
    } finally {
      _isAiThinking = false;
      notifyListeners();
    }
  }

  @override
  bool undoMove() {
    if (_moveHistory.isEmpty) return false;
    if (_result.isGameOver) return false;
    if (_isAiThinking) return false;

    // 人机模式需要撤回两步（玩家 + AI）
    if (_gameMode == GameMode.pve && _moveHistory.length >= 2) {
      final aiMove = _moveHistory.removeLast();
      _board.removePiece(aiMove.position);
      
      final playerMove = _moveHistory.removeLast();
      _board.removePiece(playerMove.position);
      
      _currentPlayer = playerMove.player;
    } else if (_gameMode == GameMode.pvp && _moveHistory.isNotEmpty) {
      final move = _moveHistory.removeLast();
      _board.removePiece(move.position);
      _currentPlayer = move.player;
    } else {
      return false;
    }

    _result = const GameResult(type: GameResultType.none);
    notifyListeners();
    return true;
  }

  @override
  void resign() {
    if (_result.isGameOver) return;

    _result = GameResult(
      type: GameResultType.resign,
      winner: _currentPlayer.opponent,
    );
    notifyListeners();
  }

  @override
  void restart() {
    initGame(mode: _gameMode, difficulty: _aiEngine?.difficulty);
  }
}
