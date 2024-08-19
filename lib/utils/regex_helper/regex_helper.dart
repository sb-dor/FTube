mixin class RegexHelper {
  String videoId(String text) {
    RegExp? regExp;
    // .be\/(.{1,})\?
    if (text.contains('shorts/')) {
      regExp = RegExp(r"shorts\/(\w{0,})");
    }
    return '';
  }
}
