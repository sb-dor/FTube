mixin class SolvePercentageMixin {
  static double percentage(int receive, int total) {
    final solvePercentage = receive / total * 100;
    return solvePercentage / 100;
  }
}
