import 'package:flutter/material.dart';
import '../../../core/enums/player.dart';
import '../../../core/models/position.dart';
import '../models/gomoku_board.dart';

/// 五子棋棋盘绘制器
class GomokuBoardPainter extends CustomPainter {
  final GomokuBoard board;
  final Position? lastMove;
  final List<Position>? winPath;
  final Position? hoverPosition;
  final Position? winningMove;

  GomokuBoardPainter({
    required this.board,
    this.lastMove,
    this.winPath,
    this.hoverPosition,
    this.winningMove,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cellSize = size.width / (board.size + 1);
    final offset = cellSize;

    _drawBoard(canvas, size, cellSize, offset);
    _drawPieces(canvas, cellSize, offset);
    if (hoverPosition != null) _drawHover(canvas, cellSize, offset);
    if (winPath != null) _drawWinHighlight(canvas, cellSize, offset);
    if (winningMove != null) _drawWinningMoveMarker(canvas, cellSize, offset);
  }

  void _drawBoard(Canvas canvas, Size size, double cellSize, double offset) {
    // 棋盘背景
    final bgPaint = Paint()
      ..color = const Color(0xFFDEB887)
      ..style = PaintingStyle.fill;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // 网格线
    final linePaint = Paint()
      ..color = const Color(0xFF8B4513)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < board.size; i++) {
      // 水平线
      canvas.drawLine(
        Offset(offset, offset + i * cellSize),
        Offset(offset + (board.size - 1) * cellSize, offset + i * cellSize),
        linePaint,
      );
      // 垂直线
      canvas.drawLine(
        Offset(offset + i * cellSize, offset),
        Offset(offset + i * cellSize, offset + (board.size - 1) * cellSize),
        linePaint,
      );
    }

    // 星位标记
    final starPaint = Paint()
      ..color = const Color(0xFF8B4513)
      ..style = PaintingStyle.fill;
    
    final starPoints = [
      [3, 3], [3, 7], [3, 11],
      [7, 3], [7, 7], [7, 11],
      [11, 3], [11, 7], [11, 11],
    ];

    for (final star in starPoints) {
      canvas.drawCircle(
        Offset(offset + star[1] * cellSize, offset + star[0] * cellSize),
        4,
        starPaint,
      );
    }

    // 坐标标记
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    for (int i = 0; i < board.size; i++) {
      // 列坐标 (A-O)
      textPainter.text = TextSpan(
        text: String.fromCharCode(65 + i),
        style: const TextStyle(color: Color(0xFF5D4037), fontSize: 10),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(offset + i * cellSize - textPainter.width / 2, 4),
      );

      // 行坐标 (1-15)
      textPainter.text = TextSpan(
        text: '${i + 1}',
        style: const TextStyle(color: Color(0xFF5D4037), fontSize: 10),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(2, offset + i * cellSize - textPainter.height / 2),
      );
    }
  }

  void _drawPieces(Canvas canvas, double cellSize, double offset) {
    for (int i = 0; i < board.size; i++) {
      for (int j = 0; j < board.size; j++) {
        final piece = board.getPiece(Position(i, j));
        if (piece == Player.none) continue;

        final center = Offset(offset + j * cellSize, offset + i * cellSize);
        final radius = cellSize * 0.42;

        // 棋子阴影
        final shadowPaint = Paint()
          ..color = Colors.black.withOpacity(0.3)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
        canvas.drawCircle(center + const Offset(1, 1), radius, shadowPaint);

        // 棋子渐变
        final gradient = RadialGradient(
          colors: piece == Player.black
              ? [const Color(0xFF424242), const Color(0xFF212121)]
              : [const Color(0xFFFFFFFF), const Color(0xFFE0E0E0)],
          stops: const [0.3, 1.0],
        );

        final piecePaint = Paint()
          ..shader = gradient.createShader(
            Rect.fromCircle(center: center, radius: radius),
          );
        canvas.drawCircle(center, radius, piecePaint);

        // 棋子边框
        final borderPaint = Paint()
          ..color = piece == Player.black
              ? const Color(0xFF000000)
              : const Color(0xFFBDBDBD)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1;
        canvas.drawCircle(center, radius, borderPaint);

        // 最后落子标记
        if (lastMove != null && lastMove!.row == i && lastMove!.col == j) {
          final markerPaint = Paint()
            ..color = piece == Player.black ? Colors.white : Colors.red
            ..style = PaintingStyle.fill;
          canvas.drawCircle(center, radius * 0.25, markerPaint);
        }
      }
    }
  }

  void _drawHover(Canvas canvas, double cellSize, double offset) {
    if (hoverPosition == null) return;
    if (board.getPiece(hoverPosition!) != Player.none) return;

    final center = Offset(
      offset + hoverPosition!.col * cellSize,
      offset + hoverPosition!.row * cellSize,
    );

    final hoverPaint = Paint()
      ..color = Colors.black.withOpacity(0.15)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, cellSize * 0.42, hoverPaint);
  }

  void _drawWinHighlight(Canvas canvas, double cellSize, double offset) {
    if (winPath == null || winPath!.isEmpty) return;

    // 先绘制获胜连线（连接五颗棋子的线）
    if (winPath!.length >= 2) {
      // 按行列排序，找到连线的起点和终点
      final sorted = List<Position>.from(winPath!)
        ..sort((a, b) {
          if (a.row != b.row) return a.row.compareTo(b.row);
          return a.col.compareTo(b.col);
        });

      final start = sorted.first;
      final end = sorted.last;
      final startCenter = Offset(offset + start.col * cellSize, offset + start.row * cellSize);
      final endCenter = Offset(offset + end.col * cellSize, offset + end.row * cellSize);

      // 绘制连线背景（半透明红色）
      final lineBgPaint = Paint()
        ..color = Colors.red.withOpacity(0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = cellSize * 0.6
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(startCenter, endCenter, lineBgPaint);

      // 绘制连线高亮（亮红色）
      final linePaint = Paint()
        ..color = Colors.red.withOpacity(0.7)
        ..style = PaintingStyle.stroke
        ..strokeWidth = cellSize * 0.15
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(startCenter, endCenter, linePaint);
    }

    // 绘制获胜棋子的高亮圆圈
    final highlightPaint = Paint()
      ..color = Colors.red.withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    final glowPaint = Paint()
      ..color = Colors.red.withOpacity(0.3)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);

    for (final pos in winPath!) {
      final center = Offset(offset + pos.col * cellSize, offset + pos.row * cellSize);
      // 外发光
      canvas.drawCircle(center, cellSize * 0.5, glowPaint);
      // 高亮圆圈
      canvas.drawCircle(center, cellSize * 0.45, highlightPaint);
    }
  }

  void _drawWinningMoveMarker(Canvas canvas, double cellSize, double offset) {
    if (winningMove == null) return;

    final center = Offset(
      offset + winningMove!.col * cellSize,
      offset + winningMove!.row * cellSize,
    );
    final radius = cellSize * 0.42;

    // 绝杀位置的大型金色光晕
    final bigGlowPaint = Paint()
      ..color = const Color(0xFFFFD700).withOpacity(0.4)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawCircle(center, radius * 1.5, bigGlowPaint);

    // 绝杀位置的金色光环
    final glowPaint = Paint()
      ..color = const Color(0xFFFFD700)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawCircle(center, radius + 6, glowPaint);

    // 绝杀位置的实心金色圆点（更大）
    final markerPaint = Paint()
      ..color = const Color(0xFFFFD700)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius * 0.45, markerPaint);

    // 绝杀位置的白色边框
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    canvas.drawCircle(center, radius * 0.45, borderPaint);

    // 绘制"绝杀"文字标记
    final textPainter = TextPainter(
      text: const TextSpan(
        text: '★',
        style: TextStyle(
          color: Color(0xFFFFD700),
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        center.dx - textPainter.width / 2,
        center.dy - textPainter.height / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant GomokuBoardPainter oldDelegate) {
    return board != oldDelegate.board ||
        lastMove != oldDelegate.lastMove ||
        winPath != oldDelegate.winPath ||
        hoverPosition != oldDelegate.hoverPosition ||
        winningMove != oldDelegate.winningMove;
  }
}
