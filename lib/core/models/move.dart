import 'position.dart';
import '../enums/player.dart';

/// 棋步模型
class Move {
  final Position position;
  final Player player;
  final DateTime timestamp;

  Move({
    required this.position,
    required this.player,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  @override
  String toString() => 'Move(${player.label} -> $position)';
}
