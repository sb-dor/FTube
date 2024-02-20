// ignore_for_file: constant_identifier_names

abstract class Constants {
  static const int perPage = 15;

  static const int STATUS_SUCCESS = 200;

  static const int STATUS_UNAUTH = 401;

  static const int STATUS_BAD_REQUEST = 400;

  static const int STATUS_INTERNAL_SERVER_ERROR = 500;

  static const String tempDateTime = "2010-01-01 00:00:00";

  static const String videoDownloadingInfo =
      "There is another video which is still downloading. Please wait before download another one.";

  static const String audioDownloadingInfo =
      "There is another video which is still downloading. Please wait before download another one.";

  static const String videoSavedInAppStorageInfo = "Video was successfully saved in App Storage!";

  static const String videoSavedInGalleryInfo = "Video was successfully saved in Gallery!";

  static const String videoDownloadedErrorTitleMessage =
      'Something went wrong while video was downloading';

  static const String videoDownloadedErrorContentMessage =
      'Please, try to download the "Recommended" video from video downloading section';

  static const String audioDownloadedErrorTitleMessage =
      'Something went wrong while audio was downloading';

  static const String audioDownloadedErrorContentMessage =
      'Please, try to download the "Recommended" audio from video downloading section';

  static const String videoDownloadingErrorOccurred =
      "An error occurred while downloading, please try to download another format.";

  static const String errorMessage = "Something went wrong. Please try again";
}
