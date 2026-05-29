/// 棋盘位置模型
class Position {
  final int row;
  final int col;

  const Position(this.row, this.col);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Position && row == other.row && col == other.col;

  @override
  int get hashCode => row.hashCode ^ col.hashCode;

  @override
  String toString() => '($row, $col)';

  /// 检查位置是否在棋盘范围内
  bool isInBounds(int boardSize) =>
      row >= 0 && row < boardSize && col >= 0 && col < boardSize;

  /// 获取周围指定距离的位置
  List<Position> getNeighbors(int distance, int boardSize) {
    final neighbors = <Position>[];
    for (int dr = -distance; dr <= distance; dr++) {
      for (int dc = -distance; dc <= distance; dc++) {
        if (dr == 0 && dc == 0) continue;
        final pos = Position(row + dr, col + dc);
        if (pos.isInBounds(boardSize)) neighbors.add(pos);
      }
    }
    return neighbors;
  }
}
