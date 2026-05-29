import '../enums/player.dart';
import '../models/position.dart';

/// 棋盘抽象接口
abstract class GameBoard {
  /// 棋盘尺寸
  int get size;

  /// 获取指定位置的棋子
  Player getPiece(Position position);

  /// 放置棋子
  void placePiece(Position position, Player player);

  /// 移除棋子（悔棋用）
  void removePiece(Position position);

  /// 清空棋盘
  void clear();

  /// 获取棋盘状态副本
  GameBoard clone();

  /// 获取所有已落子的位置
  List<Position> get occupiedPositions;

  /// 导出棋盘数据为二维int数组（用于Isolate传递）
  List<List<int>> toDataList();
}
