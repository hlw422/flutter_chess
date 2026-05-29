import 'dart:math';
import 'package:flutter/foundation.dart';
import '../../../core/enums/player.dart';
import '../../../core/enums/difficulty.dart';
import '../../../core/interfaces/ai_engine.dart';
import '../../../core/interfaces/game_board.dart';
import '../../../core/models/position.dart';

/// 候选着法及其评分
class _ScoredPosition {
  final Position position;
  final int score;
  const _ScoredPosition(this.position, this.score);
}

/// 五子棋AI引擎 - Minimax + Alpha-Beta剪枝
class GomokuAIEngine implements AIEngine {
  @override
  final Difficulty difficulty;

  @override
  final Player aiPlayer;

  GomokuAIEngine({
    this.difficulty = Difficulty.medium,
    this.aiPlayer = Player.white,
  });

  @override
  Future<Position> calculateMove(GameBoard board, Player currentPlayer) async {
    // 使用compute将计算移到Isolate，避免阻塞UI
    return compute(_calculateMoveIsolate, _IsolateParams(
      boardData: board.toDataList(),
      boardSize: board.size,
      currentPlayer: currentPlayer,
      difficulty: difficulty,
      aiPlayer: aiPlayer,
    ));
  }
}

/// Isolate参数
class _IsolateParams {
  final List<List<int>> boardData;
  final int boardSize;
  final Player currentPlayer;
  final Difficulty difficulty;
  final Player aiPlayer;

  const _IsolateParams({
    required this.boardData,
    required this.boardSize,
    required this.currentPlayer,
    required this.difficulty,
    required this.aiPlayer,
  });
}

/// Isolate入口函数
Position _calculateMoveIsolate(_IsolateParams params) {
  final board = _SimpleBoard(params.boardData, params.boardSize);
  final emptyPositions = _getNearbyEmptyPositions(board, 2);

  if (emptyPositions.isEmpty) {
    final center = params.boardSize ~/ 2;
    return Position(center, center);
  }

  // 检查必胜/必防位置
  final urgentMove = _findUrgentMove(board, params.currentPlayer, emptyPositions);
  if (urgentMove != null) return urgentMove;

  // 检查活三、冲四等必杀棋型
  final threatMove = _findThreatMove(board, params.currentPlayer, emptyPositions);
  if (threatMove != null) return threatMove;

  // 对候选位置进行评分并排序
  final scored = <_ScoredPosition>[];
  for (final pos in emptyPositions) {
    final score = _quickEvaluate(board, pos, params.currentPlayer, params.aiPlayer);
    scored.add(_ScoredPosition(pos, score));
  }
  scored.sort((a, b) => b.score.compareTo(a.score));
  
  // 根据难度限制候选数量
  final maxCandidates = params.difficulty.maxCandidates;
  final candidates = scored.take(maxCandidates).map((s) => s.position).toList();

  Position bestMove = candidates.first;
  int bestScore = -999999;

  for (final pos in candidates) {
    board.placePiece(pos, params.currentPlayer);
    final score = _minimax(
      board,
      params.difficulty.searchDepth - 1,
      -999999,
      999999,
      false,
      params.currentPlayer,
      params.aiPlayer,
      maxCandidates,
    );
    board.removePiece(pos);

    if (score > bestScore) {
      bestScore = score;
      bestMove = pos;
    }
  }

  return bestMove;
}

/// 简化的棋盘数据结构，用于Isolate
class _SimpleBoard {
  final List<List<int>> data;
  final int size;

  _SimpleBoard(this.data, this.size);

  int getPiece(Position pos) => data[pos.row][pos.col];
  void placePiece(Position pos, Player player) => data[pos.row][pos.col] = player.value;
  void removePiece(Position pos) => data[pos.row][pos.col] = Player.none.value;

  List<Position> get occupiedPositions {
    final result = <Position>[];
    for (int i = 0; i < size; i++) {
      for (int j = 0; j < size; j++) {
        if (data[i][j] != Player.none.value) {
          result.add(Position(i, j));
        }
      }
    }
    return result;
  }
}

/// 快速评估单个位置的价值（用于候选排序）
int _quickEvaluate(_SimpleBoard board, Position pos, Player currentPlayer, Player aiPlayer) {
  int score = 0;
  final opponent = currentPlayer.opponent;

  // 模拟落子后评估
  board.placePiece(pos, currentPlayer);
  score += _evaluatePatterns(board, pos, currentPlayer, aiPlayer) * 3;
  board.removePiece(pos);

  // 模拟对手落子评估（防守价值）
  board.placePiece(pos, opponent);
  score += _evaluatePatterns(board, pos, opponent, aiPlayer) * 2;
  board.removePiece(pos);

  // 中心位置加分
  final center = board.size ~/ 2;
  final dist = (pos.row - center).abs() + (pos.col - center).abs();
  score += max(0, (board.size - dist));

  return score;
}

/// 评估某个位置周围的棋型
int _evaluatePatterns(_SimpleBoard board, Position pos, Player player, Player aiPlayer) {
  int score = 0;
  final directions = [[0, 1], [1, 0], [1, 1], [1, -1]];

  for (final dir in directions) {
    int count = 0;
    int openEnds = 0;

    // 正向
    for (int i = 0; i < 5; i++) {
      final p = Position(pos.row + dir[0] * i, pos.col + dir[1] * i);
      if (!p.isInBounds(board.size)) break;
      if (board.getPiece(p) == player.value) {
        count++;
      } else {
        if (board.getPiece(p) == Player.none.value) openEnds++;
        break;
      }
    }
    // 反向
    final backP = Position(pos.row - dir[0], pos.col - dir[1]);
    if (backP.isInBounds(board.size) && board.getPiece(backP) == Player.none.value) {
      openEnds++;
    }

    score += _getPatternScore(count, openEnds);
  }
  return score;
}

/// 检查紧急落子位置（必胜/必防）
Position? _findUrgentMove(_SimpleBoard board, Player player, List<Position> positions) {
  final opponent = player.opponent;

  // 检查AI能否直接获胜
  for (final pos in positions) {
    board.placePiece(pos, player);
    if (_hasWin(board, pos, player)) {
      board.removePiece(pos);
      return pos;
    }
    board.removePiece(pos);
  }

  // 检查对手能否直接获胜（需要防守）
  for (final pos in positions) {
    board.placePiece(pos, opponent);
    if (_hasWin(board, pos, opponent)) {
      board.removePiece(pos);
      return pos;
    }
    board.removePiece(pos);
  }

  return null;
}

/// 检查威胁性落子（活三、冲四等）
Position? _findThreatMove(_SimpleBoard board, Player player, List<Position> positions) {
  final opponent = player.opponent;
  
  // 优先级：活四 > 冲四 > 活三
  Position? bestThreat;
  int bestThreatScore = 0;

  for (final pos in positions) {
    // 检查AI的威胁
    board.placePiece(pos, player);
    final aiThreat = _evaluateThreat(board, pos, player);
    board.removePiece(pos);

    // 检查对手的威胁（防守）
    board.placePiece(pos, opponent);
    final opponentThreat = _evaluateThreat(board, pos, opponent);
    board.removePiece(pos);

    // 综合评分
    final totalThreat = aiThreat * 2 + opponentThreat;
    if (totalThreat > bestThreatScore) {
      bestThreatScore = totalThreat;
      bestThreat = pos;
    }
  }

  // 只有威胁足够大才返回
  if (bestThreatScore >= 1000) {
    return bestThreat;
  }
  return null;
}

/// 评估威胁程度
int _evaluateThreat(_SimpleBoard board, Position pos, Player player) {
  int threatScore = 0;
  final directions = [[0, 1], [1, 0], [1, 1], [1, -1]];

  for (final dir in directions) {
    int count = 0;
    int openEnds = 0;

    for (int i = 0; i < 5; i++) {
      final p = Position(pos.row + dir[0] * i, pos.col + dir[1] * i);
      if (!p.isInBounds(board.size)) break;
      if (board.getPiece(p) == player.value) {
        count++;
      } else {
        if (board.getPiece(p) == Player.none.value) openEnds++;
        break;
      }
    }

    final backP = Position(pos.row - dir[0], pos.col - dir[1]);
    if (backP.isInBounds(board.size) && board.getPiece(backP) == Player.none.value) {
      openEnds++;
    }

    if (count >= 4 && openEnds >= 1) {
      threatScore += 10000; // 冲四或活四
    } else if (count >= 3 && openEnds >= 2) {
      threatScore += 1000; // 活三
    } else if (count >= 3 && openEnds >= 1) {
      threatScore += 100; // 眠三
    }
  }
  return threatScore;
}

bool _hasWin(_SimpleBoard board, Position pos, Player player) {
  final directions = [[0, 1], [1, 0], [1, 1], [1, -1]];
  for (final dir in directions) {
    int count = 1;
    for (int i = 1; i < 5; i++) {
      final p = Position(pos.row + dir[0] * i, pos.col + dir[1] * i);
      if (p.isInBounds(board.size) && board.getPiece(p) == player.value) {
        count++;
      } else {
        break;
      }
    }
    for (int i = 1; i < 5; i++) {
      final p = Position(pos.row - dir[0] * i, pos.col - dir[1] * i);
      if (p.isInBounds(board.size) && board.getPiece(p) == player.value) {
        count++;
      } else {
        break;
      }
    }
    if (count >= 5) return true;
  }
  return false;
}

/// Minimax + Alpha-Beta剪枝
int _minimax(_SimpleBoard board, int depth, int alpha, int beta, bool isMax, Player player, Player aiPlayer, int maxCandidates) {
  if (depth == 0) return _evaluateBoard(board, player, aiPlayer);

  final positions = _getNearbyEmptyPositions(board, 1);
  if (positions.isEmpty) return _evaluateBoard(board, player, aiPlayer);

  // 限制每层候选数量
  final limited = positions.length > maxCandidates ? positions.sublist(0, maxCandidates) : positions;

  if (isMax) {
    int maxScore = -999999;
    for (final pos in limited) {
      board.placePiece(pos, player);
      final score = _minimax(board, depth - 1, alpha, beta, false, player, aiPlayer, maxCandidates);
      board.removePiece(pos);
      maxScore = max(maxScore, score);
      alpha = max(alpha, score);
      if (beta <= alpha) break;
    }
    return maxScore;
  } else {
    int minScore = 999999;
    for (final pos in limited) {
      board.placePiece(pos, player.opponent);
      final score = _minimax(board, depth - 1, alpha, beta, true, player, aiPlayer, maxCandidates);
      board.removePiece(pos);
      minScore = min(minScore, score);
      beta = min(beta, score);
      if (beta <= alpha) break;
    }
    return minScore;
  }
}

/// 获取已落子附近的空位
List<Position> _getNearbyEmptyPositions(_SimpleBoard board, int range) {
  final occupied = board.occupiedPositions;
  if (occupied.isEmpty) {
    final c = board.size ~/ 2;
    return [Position(c, c)];
  }

  final nearby = <Position>{};
  for (final pos in occupied) {
    for (int dr = -range; dr <= range; dr++) {
      for (int dc = -range; dc <= range; dc++) {
        if (dr == 0 && dc == 0) continue;
        final p = Position(pos.row + dr, pos.col + dc);
        if (p.isInBounds(board.size) && board.getPiece(p) == Player.none.value) {
          nearby.add(p);
        }
      }
    }
  }
  return nearby.toList();
}

/// 评估棋盘分数
int _evaluateBoard(_SimpleBoard board, Player player, Player aiPlayer) {
  int score = 0;
  final size = board.size;

  for (int i = 0; i < size; i++) {
    for (int j = 0; j < size; j++) {
      final pos = Position(i, j);
      final piece = board.getPiece(pos);
      if (piece == Player.none.value) continue;

      final directions = [[0, 1], [1, 0], [1, 1], [1, -1]];
      for (final dir in directions) {
        score += _evaluateDirection(board, pos, dir, Player.fromValue(piece), aiPlayer);
      }
    }
  }
  return score;
}

int _evaluateDirection(_SimpleBoard board, Position start, List<int> dir, Player piece, Player aiPlayer) {
  int count = 0;
  int openEnds = 0;
  final size = board.size;

  for (int i = 0; i < 5; i++) {
    final p = Position(start.row + dir[0] * i, start.col + dir[1] * i);
    if (!p.isInBounds(size)) break;
    if (board.getPiece(p) == piece.value) {
      count++;
    } else {
      if (board.getPiece(p) == Player.none.value) openEnds++;
      break;
    }
  }

  final backP = Position(start.row - dir[0], start.col - dir[1]);
  if (backP.isInBounds(size) && board.getPiece(backP) == Player.none.value) {
    openEnds++;
  }

  if (count == 0) return 0;

  int baseScore = _getPatternScore(count, openEnds);
  return piece == aiPlayer ? baseScore : -baseScore;
}

int _getPatternScore(int count, int openEnds) {
  if (openEnds == 0 && count < 5) return 0;

  switch (count) {
    case 5: return 100000;
    case 4: return openEnds == 2 ? 50000 : 5000;
    case 3: return openEnds == 2 ? 5000 : 500;
    case 2: return openEnds == 2 ? 500 : 50;
    case 1: return openEnds == 2 ? 50 : 5;
    default: return 100000;
  }
}
