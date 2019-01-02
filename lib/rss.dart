import 'package:YouAudio/dataModel/video.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart' as xml;

Future<List<Video>> getVideoListByChannelId(String id) async {
  List<Video> videos = new List();
  http.Response response = await http.get('https://www.youtube.com/feeds/videos.xml?channel_id=$id');
  xml.XmlDocument document = xml.parse(response.body);
  document.findAllElements('entry').forEach((xml) => videos.add(
      new Video(
          xml.findElements('title').first.text,
          xml.findElements('author').first.findElements('name').first.text,
          DateTime.parse(xml.findElements('published').first.text)
      )
  ));
  return videos;
}
