abstract class ViewFormatHelper {
  static String viewsFormatNumbers(int? number) {
    if (number == null) return '';
    if (number >= 1000000) {
      double result = number / 1000000.0;
      return '${result.toStringAsFixed(result.truncateToDouble() == result ? 0 : 1)} млн.';
    } else if (number >= 1000) {
      double result = number / 1000.0;
      return '${result.toStringAsFixed(result.truncateToDouble() == result ? 0 : 1)} тыс.';
    } else {
      return number.toString();
    }
  }
}
