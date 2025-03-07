import 'package:youtube/core/youtube_data_api/helpers/helpers_extension.dart';
import 'package:youtube/core/youtube_data_api/models/video.dart';

import 'channel_page.dart';

class ChannelData {
  ChannelPage channel;
  List<Video> videosList;

  ChannelData({required this.channel, required this.videosList});

  factory ChannelData.fromMap(Map<String, dynamic> map) {
    final headers = map.get('header');
    final String? subscribers =
        headers
            ?.get('c4TabbedHeaderRenderer')
            ?.get('subscriberCountText')?['simpleText'];
    final thumbnails = headers
        ?.get('c4TabbedHeaderRenderer')
        ?.get('avatar')
        ?.getList('thumbnails');
    final String avatar =
        thumbnails?.elementAtSafe(thumbnails.length - 1)?['url'];
    final String? banner =
        headers
            ?.get('c4TabbedHeaderRenderer')
            ?.get('banner')
            ?.getList('thumbnails')
            ?.first['url'];
    final contents = map
        .get('contents')
        ?.get('twoColumnBrowseResultsRenderer')
        ?.getList('tabs')?[1]
        .get('tabRenderer')
        ?.get('content')
        ?.get('sectionListRenderer')
        ?.getList('contents')
        ?.firstOrNull
        ?.get('itemSectionRenderer')
        ?.getList('contents')
        ?.firstOrNull
        ?.get('gridRenderer')
        ?.getList('items');
    final contentList = contents!.toList();
    final List<Video> videoList = [];
    for (var element in contentList) {
      final Video video = Video.fromMap(element);
      videoList.add(video);
    }

    return ChannelData(
      videosList: videoList,
      channel: ChannelPage(
        subscribers: (subscribers != null) ? subscribers : " ",
        avatar: avatar,
        banner: banner,
      ),
    );
  }
}
