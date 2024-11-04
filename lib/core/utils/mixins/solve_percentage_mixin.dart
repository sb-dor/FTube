mixin class SolvePercentageMixin {
  static double percentage(int receive, int total) {
    var solvePercentage = receive / total * 100;
    return solvePercentage / 100;
  }
}
