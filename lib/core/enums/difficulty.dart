/// AI难度枚举
enum Difficulty {
  easy('简单', '适合新手', 2, 8),
  medium('中等', '有一定挑战', 3, 12),
  hard('困难', '高手级别', 4, 18);

  final String label;
  final String description;
  final int searchDepth;
  final int maxCandidates;
  const Difficulty(this.label, this.description, this.searchDepth, this.maxCandidates);
}
