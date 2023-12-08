// ignore_for_file: constant_identifier_names

import 'api_env.dart';

const String MAIN_URL = 'https://www.googleapis.com/youtube/v3';

const String key = "?key=$YOUTUBE_API_KEY";

const String videos = '/videos';

const String search = '/search';

const String videoCategories = "/videoCategories";

const String channels = '/channels';

const String snippetPart = '&part=snippet';

const String statisticsPart = '&part=statistics'; // for videos url used only

const String language = "&hl=ru";

const String regionCode = "&regionCode=ru";