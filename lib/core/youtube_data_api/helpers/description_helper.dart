String? collectDescriptionString(dynamic list) {
  String? description;
  if (list != null) {
    description = "";
    for (var element in list) {
      if (element != null) {
        description = description! + element['text'].toString();
      }
    }
  }
  return description;
}
