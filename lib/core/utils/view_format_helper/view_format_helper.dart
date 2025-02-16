abstract class ViewFormatHelper {
  static String viewsFormatNumbers(int? number) {
    if (number == null) return '';
    if (number >= 1000000000) {
      final double result = number / 1000000000;
      return "${result.toStringAsFixed(result.truncateToDouble() == result ? 0 : 1)}B"; //млрд.
    } else if (number >= 1000000) {
      final double result = number / 1000000.0;
      return '${result.toStringAsFixed(result.truncateToDouble() == result ? 0 : 1)}M'; //млн.
    } else if (number >= 1000) {
      final double result = number / 1000.0;
      return '${result.toStringAsFixed(result.truncateToDouble() == result ? 0 : 1)}K'; //тыс.
    } else {
      return number.toString();
    }
  }
}
