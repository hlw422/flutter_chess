# 棋艺大师 - Flutter 棋类游戏集合

一个使用 Flutter 构建的可扩展棋类游戏应用，当前已实现五子棋（Gomoku），架构预留了中国象棋和国际象棋的扩展接口。

## 功能特性

### 五子棋模块
- **双人对战（PvP）**：支持同屏轮流落子
- **人机对战（PvE）**：三种难度级别可选
  - 简单：适合新手，搜索深度 2
  - 中等：有一定挑战，搜索深度 3
  - 困难：高手级别，搜索深度 4
- **智能 AI**：基于 Minimax + Alpha-Beta 剪枝算法，支持威胁检测（活三/冲四）
- **游戏操作**：悔棋、认输、重新开始
- **胜负判定**：五连珠检测、平局检测
- **获胜可视化**：
  - 红色连线高亮获胜的五颗棋子
  - 金色标记显示绝杀位置（★）
  - 2 秒延迟弹窗，让玩家看清棋盘局势

### 界面设计
- **响应式布局**：自动适配竖屏/横屏模式
- **深色主题**：护眼的深蓝色调设计
- **自定义棋盘绘制**：使用 CustomPainter 实现精美的 15×15 棋盘
- **星位标记**：标准五子棋星位点显示
- **坐标系统**：列坐标 A-O，行坐标 1-15
- **落子反馈**：悬停预览、最后落子标记
- **紧凑弹窗**：底部对齐的结果弹窗，半透明遮罩

## 技术架构

### 核心技术栈
- **Flutter**：跨平台 UI 框架
- **Dart**：编程语言
- **Flutter Riverpod**：状态管理
- **GoRouter**：路由管理（预留）
- **Google Fonts**：中文字体支持

### 架构设计

项目采用分层架构，通过抽象接口实现游戏模块的可扩展性：

```
lib/
├── core/                    # 核心抽象层
│   ├── enums/               # 枚举定义
│   │   ├── player.dart      # 棋手枚举（黑棋/白棋）
│   │   ├── game_mode.dart   # 游戏模式（PvP/PvE）和类型
│   │   ├── difficulty.dart  # AI 难度级别
│   │   └── game_result.dart # 游戏结果类型
│   ├── interfaces/          # 抽象接口
│   │   ├── game_board.dart  # 棋盘接口
│   │   ├── game_rules.dart  # 规则接口
│   │   ├── game_controller.dart # 控制器接口
│   │   └── ai_engine.dart   # AI 引擎接口
│   └── models/              # 数据模型
│       ├── position.dart    # 位置坐标
│       └── move.dart        # 棋步记录
├── games/                   # 游戏实现模块
│   └── gomoku/              # 五子棋
│       ├── models/          # 数据模型
│       │   ├── gomoku_board.dart   # 棋盘实现
│       │   └── gomoku_rules.dart   # 规则实现
│       ├── controller/      # 游戏控制器
│       │   └── gomoku_controller.dart
│       ├── ai/              # AI 引擎
│       │   └── gomoku_ai_engine.dart
│       └── widgets/         # UI 组件
│           ├── gomoku_board_painter.dart  # 棋盘绘制器
│           └── gomoku_game_screen.dart    # 游戏界面
├── screens/                 # 页面
│   ├── home_screen.dart     # 主页
│   └── game_setup_screen.dart # 游戏设置
├── widgets/                 # 通用组件
│   ├── game_controls.dart   # 游戏控制按钮
│   └── result_dialog.dart   # 结果弹窗
└── main.dart                # 应用入口
```

### 扩展性设计

通过抽象接口实现新棋类的快速接入：

```dart
// 棋盘接口
abstract class GameBoard {
  int get size;
  Player getPiece(Position position);
  void placePiece(Position position, Player player);
  void removePiece(Position position);
  void clear();
  GameBoard clone();
  List<Position> get occupiedPositions;
  List<List<int>> toDataList();
}

// 规则接口
abstract class GameRules {
  bool isValidMove(GameBoard board, Position position, Player player);
  GameResult checkGameResult(GameBoard board, Player lastPlayer, Position lastMove);
}

// AI 引擎接口
abstract class AIEngine {
  Difficulty get difficulty;
  Player get aiPlayer;
  Future<Position> calculateMove(GameBoard board, Player currentPlayer);
}

// 控制器接口
abstract class GameController extends ChangeNotifier {
  GameState get gameState;
  void initGame({GameMode mode, Difficulty? difficulty});
  Future<bool> makeMove(Position position);
  bool undoMove();
  void resign();
  void restart();
}
```

## 快速开始

### 环境要求
- Flutter SDK >= 3.11.5
- Dart SDK >= 3.11.5

### 安装步骤

1. 克隆项目
```bash
git clone https://github.com/hlw422/flutter_chess.git
cd flutter_chess
```

2. 安装依赖
```bash
flutter pub get
```

3. 运行应用
```bash
flutter run
```

### 支持平台
- Android
- iOS
- Windows
- macOS
- Linux
- Web

## 游戏玩法

### 五子棋规则
- 黑棋先行，双方轮流落子
- 先将五颗或更多棋子连成一线（横、竖、斜均可）者获胜
- 棋盘满且无人获胜则为平局

### 操作说明
1. **落子**：点击棋盘上的交叉点
2. **悔棋**：撤回上一步（人机模式会撤回玩家和 AI 各一步）
3. **认输**：放弃当前对局
4. **重来**：重新开始新一局

## AI 算法

### 核心算法
- **Minimax 搜索**：博弈树搜索算法
- **Alpha-Beta 剪枝**：优化搜索效率，减少不必要的分支
- **Isolate 并发**：使用 Dart 的 `compute()` 函数将 AI 计算移至独立线程，避免阻塞 UI

### 评估策略
- **棋型评分**：
  - 五连：100,000 分
  - 活四：50,000 分
  - 冲四：5,000 分
  - 活三：5,000 分
  - 眠三：500 分
- **攻防权重**：攻击权重 3x，防守权重 2x
- **威胁检测**：优先识别必胜/必防位置，以及活三、冲四等威胁棋型
- **候选排序**：对候选位置快速评估并排序，限制搜索数量以提高效率

### 难度参数
| 难度 | 搜索深度 | 最大候选数 | 说明 |
|------|----------|------------|------|
| 简单 | 2 | 8 | 适合新手 |
| 中等 | 3 | 12 | 有一定挑战 |
| 困难 | 4 | 18 | 高手级别 |

## 扩展新棋类

1. 在 `lib/core/enums/game_mode.dart` 的 `GameType` 枚举中添加新类型
2. 在 `lib/games/` 目录下创建新的游戏模块（如 `chess/`、`xiangqi/`）
3. 实现 `GameBoard`、`GameRules`、`GameController`、`AIEngine` 接口
4. 创建对应的 UI 组件和页面
5. 在 `game_setup_screen.dart` 中添加新游戏的启动逻辑

## 项目依赖

```yaml
dependencies:
  flutter_riverpod: ^2.6.1    # 状态管理
  go_router: ^14.8.1           # 路由管理
  shared_preferences: ^2.3.4   # 本地存储（预留）
  google_fonts: ^6.2.1         # 字体支持
```

## 版本历史

### v1.0.0
- 实现五子棋完整功能
- 支持双人对战和人机对战模式
- 三级难度 AI（简单/中等/困难）
- 响应式 UI 设计，适配横竖屏
- 获胜高亮和绝杀标记

## 许可证

本项目仅供学习和个人使用。

## 致谢

- Flutter 团队提供的优秀跨平台框架
- 五子棋 AI 算法参考了经典的 Minimax 和 Alpha-Beta 剪枝理论
