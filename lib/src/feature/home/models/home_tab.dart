/// Bottom-navigation tabs.
enum HomeTab {
  feed('home'),
  trending('trending'),
  library('library');

  const HomeTab(this.analyticsName);

  /// Value of the `screen_tab` analytics parameter.
  final String analyticsName;
}
