import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/enums/player.dart';
import '../../../core/enums/game_mode.dart';
import '../../../core/enums/difficulty.dart';
import '../../../core/enums/game_result.dart';
import '../../../core/interfaces/game_controller.dart';
import '../../../core/models/position.dart';
import '../../../widgets/game_controls.dart';
import '../../../widgets/result_dialog.dart';
import '../controller/gomoku_controller.dart';
import '../models/gomoku_board.dart';
import 'gomoku_board_painter.dart';

/// 五子棋对弈页面
class GomokuGameScreen extends ConsumerStatefulWidget {
  final GameMode gameMode;
  final Difficulty? difficulty;

  const GomokuGameScreen({
    super.key,
    required this.gameMode,
    this.difficulty,
  });

  @override
  ConsumerState<GomokuGameScreen> createState() => _GomokuGameScreenState();
}

class _GomokuGameScreenState extends ConsumerState<GomokuGameScreen>
    with SingleTickerProviderStateMixin {
  late GomokuController _controller;
  late AnimationController _animController;
  Position? _hoverPosition;

  @override
  void initState() {
    super.initState();
    _controller = GomokuController();
    _controller.initGame(mode: widget.gameMode, difficulty: widget.difficulty);
    _controller.addListener(_onGameStateChanged);

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _controller.removeListener(_onGameStateChanged);
    _controller.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _onGameStateChanged() {
    final result = _controller.gameState.result;
    setState(() {});
    
    if (result.isGameOver) {
      // 延迟显示弹窗，让玩家先看清棋盘上的获胜情况
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          _showResultDialog(result);
        }
      });
    }
  }

  void _showResultDialog(GameResult result) {
    showDialog(
      context: context,
      barrierDismissible: true, // 点击外部可关闭
      barrierColor: Colors.black54, // 更透明的遮罩
      builder: (ctx) => ResultDialog(
        result: result,
        onRestart: () {
          Navigator.of(ctx).pop();
          _controller.restart();
        },
        onExit: () {
          Navigator.of(ctx).pop();
          Navigator.of(context).pop();
        },
      ),
    );
  }

  void _onBoardTap(TapUpDetails details, Size boardSize) {
    final cellSize = boardSize.width / (_controller.gameState.board.size + 1);
    final offset = cellSize;

    final col = ((details.localPosition.dx - offset + cellSize / 2) / cellSize).round();
    final row = ((details.localPosition.dy - offset + cellSize / 2) / cellSize).round();

    final pos = Position(row, col);
    if (pos.isInBounds(_controller.gameState.board.size)) {
      _controller.makeMove(pos);
    }
  }

  void _onBoardHover(PointerEvent details, Size boardSize) {
    final cellSize = boardSize.width / (_controller.gameState.board.size + 1);
    final offset = cellSize;

    final col = ((details.localPosition.dx - offset + cellSize / 2) / cellSize).round();
    final row = ((details.localPosition.dy - offset + cellSize / 2) / cellSize).round();

    final pos = Position(row, col);
    if (pos.isInBounds(_controller.gameState.board.size)) {
      if (_hoverPosition != pos) {
        setState(() => _hoverPosition = pos);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = _controller.gameState;
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        title: Text(
          '五子棋 - ${widget.gameMode.label}',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: const Color(0xFF16213E),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: isLandscape ? _buildLandscapeLayout(state) : _buildPortraitLayout(state),
      ),
    );
  }

  Widget _buildPortraitLayout(GameState state) {
    return Column(
      children: [
        _buildStatusBar(state),
        Expanded(child: _buildBoard(state)),
        GameControls(
          canUndo: state.moveHistory.isNotEmpty && !state.isAiThinking && !state.result.isGameOver,
          onUndo: _controller.undoMove,
          onResign: _controller.resign,
          onRestart: _controller.restart,
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildLandscapeLayout(GameState state) {
    return Row(
      children: [
        Expanded(child: _buildBoard(state)),
        Container(
          width: 170,
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildStatusBar(state),
              const SizedBox(height: 12),
              GameControls(
                canUndo: state.moveHistory.isNotEmpty && !state.isAiThinking && !state.result.isGameOver,
                onUndo: _controller.undoMove,
                onResign: _controller.resign,
                onRestart: _controller.restart,
                isVertical: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBar(GameState state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          // 当前玩家指示
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF16213E),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFD4A574), width: 1.5),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.circle,
                    size: 16,
                    color: state.currentPlayer == Player.black
                        ? const Color(0xFF212121)
                        : const Color(0xFFEEEEEE),
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      state.isAiThinking ? 'AI思考中...' : '${state.currentPlayer.label}落子',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          // 步数显示
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF16213E),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '第 ${state.moveHistory.length} 手',
                style: const TextStyle(color: Color(0xFFB0B0B0), fontSize: 13),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBoard(GameState state) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final boardSize = constraints.maxWidth < constraints.maxHeight
            ? constraints.maxWidth
            : constraints.maxHeight;
        final size = Size(boardSize, boardSize);

        return Center(
          child: GestureDetector(
            onTapUp: (details) => _onBoardTap(details, size),
            child: MouseRegion(
              onHover: (details) => _onBoardHover(details, size),
              onExit: (_) => setState(() => _hoverPosition = null),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.5),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CustomPaint(
                    size: size,
                    painter: GomokuBoardPainter(
                      board: state.board as GomokuBoard,
                      lastMove: state.moveHistory.isNotEmpty
                          ? state.moveHistory.last.position
                          : null,
                      winPath: state.result.winPath?.cast<Position>(),
                      hoverPosition: _hoverPosition,
                      winningMove: state.result.winningMove,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
