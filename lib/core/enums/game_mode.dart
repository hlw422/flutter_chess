/// 游戏模式枚举
enum GameMode {
  pvp('双人对战', '与朋友同屏对弈'),
  pve('人机对战', '挑战AI棋手');

  final String label;
  final String description;
  const GameMode(this.label, this.description);
}

/// 游戏类型枚举
enum GameType {
  gomoku('五子棋', '先连成五子者胜'),
  chineseChess('中国象棋', '即将推出'),
  internationalChess('国际象棋', '即将推出');

  final String label;
  final String description;
  const GameType(this.label, this.description);
}
