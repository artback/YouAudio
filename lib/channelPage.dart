import 'package:YouAudio/dataModel/video.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart' as xml;
class ChannelPage extends StatefulWidget {
  final String id;

  ChannelPage(this.id);

  @override
  ChannelPageState createState() {
    return new ChannelPageState();
  }
}

class ChannelPageState extends State<ChannelPage> {
  final List<Video> videos = new List();
  Future<Iterable<xml.XmlElement>> getRssFeed(String id) async {
   http.Response response = await http.get('https://www.youtube.com/feeds/videos.xml?channel_id=$id');
   xml.XmlDocument document = xml.parse(response.body);
   print(document.findAllElements('entry').length);
   return document.findAllElements('entry');
  }
  @override
  void initState() {
    getRssFeed(widget.id);
    super.initState();

  }


  @override
  Widget build(BuildContext context) {
    return new Container(
        child: ListView.builder(
          itemCount: videos != null ? videos.length : 0,
          itemBuilder: (context, position) {
            return ListTile(
                title: RichText(
                  text: new TextSpan(
                    text: '${videos[position].title}',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.black),
                  ),
                ),
                trailing: videos[position].downloaded
                    ? new IconButton(
                    icon: new Icon(Icons.file_download), onPressed: null)
                    : new IconButton(
                    icon: new Icon(Icons.play_arrow), onPressed: null));
          },
        ));
  }
}
