/// 棋手枚举
enum Player {
  none('无', '', 0),
  black('黑棋', '●', 1),
  white('白棋', '○', 2);

  final String label;
  final String symbol;
  final int value;
  const Player(this.label, this.symbol, this.value);

  Player get opponent => this == Player.black ? Player.white : Player.black;

  static Player fromValue(int v) {
    switch (v) {
      case 1: return Player.black;
      case 2: return Player.white;
      default: return Player.none;
    }
  }
}
