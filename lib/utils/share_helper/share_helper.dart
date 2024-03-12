import 'package:share_plus/share_plus.dart';
import 'package:youtube/utils/constants.dart';

class ShareHelper {
  Future<void> shareVideoPath(String? videoId) async {
    if (videoId == null) return;
    await Share.shareUri(Uri.parse('${Constants.youtubeUrlVideo}$videoId'));
  }
}
