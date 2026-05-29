import '../../../core/enums/player.dart';
import '../../../core/interfaces/game_board.dart';
import '../../../core/models/position.dart';

/// 五子棋棋盘实现
class GomokuBoard implements GameBoard {
  static const int defaultSize = 15;
  late List<List<Player>> _grid;

  GomokuBoard({int size = defaultSize}) {
    _grid = List.generate(size, (_) => List.filled(size, Player.none));
  }

  @override
  int get size => _grid.length;

  @override
  Player getPiece(Position position) {
    if (!position.isInBounds(size)) return Player.none;
    return _grid[position.row][position.col];
  }

  @override
  void placePiece(Position position, Player player) {
    if (position.isInBounds(size)) {
      _grid[position.row][position.col] = player;
    }
  }

  @override
  void removePiece(Position position) {
    if (position.isInBounds(size)) {
      _grid[position.row][position.col] = Player.none;
    }
  }

  @override
  void clear() {
    for (int i = 0; i < size; i++) {
      for (int j = 0; j < size; j++) {
        _grid[i][j] = Player.none;
      }
    }
  }

  @override
  GameBoard clone() {
    final board = GomokuBoard(size: size);
    for (int i = 0; i < size; i++) {
      for (int j = 0; j < size; j++) {
        board._grid[i][j] = _grid[i][j];
      }
    }
    return board;
  }

  @override
  List<Position> get occupiedPositions {
    final positions = <Position>[];
    for (int i = 0; i < size; i++) {
      for (int j = 0; j < size; j++) {
        if (_grid[i][j] != Player.none) {
          positions.add(Position(i, j));
        }
      }
    }
    return positions;
  }

  /// 检查是否已满
  bool get isFull => occupiedPositions.length == size * size;

  @override
  List<List<int>> toDataList() {
    return List.generate(size, (i) =>
      List.generate(size, (j) => _grid[i][j].value)
    );
  }
}
