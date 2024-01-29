class VideoContentDetails {
  String? duration;
  String? dimension;
  String? definition;
  String? caption;
  bool? licensedContent;
  String? projection;

  VideoContentDetails({
    this.duration,
    this.dimension,
    this.definition,
    this.caption,
    this.licensedContent,
    this.projection,
  });

  factory VideoContentDetails.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> contentDetails = {};
    if (json['contentDetails'] != null) contentDetails = json['contentDetails'];
    return VideoContentDetails(
      duration: contentDetails['duration'],
      dimension: contentDetails['dimension'],
      definition: contentDetails['definition'],
      caption: contentDetails['caption'],
      licensedContent: contentDetails['licensedContent'],
      projection: contentDetails['projection'],
    );
  }
}