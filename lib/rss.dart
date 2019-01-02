import 'package:YouAudio/dataModel/video.dart';
import 'package:http/http.dart' as http;
import 'package:webfeed/webfeed.dart';

Future<List<Video>> getVideoListByChannelId(String id) async {
  http.Response response = await http.get('https://www.youtube.com/feeds/videos.xml?channel_id=$id');
  AtomFeed feed= new AtomFeed.parse(response.body);
  List<Video> videos = feed.items.map<Video>((item) => new Video(item.title, item.authors.first.name,DateTime.parse(item.published),item.links.first.href)).toList();
  return videos;
}
