import 'package:YouAudio/dataModel/video.dart';
import 'package:YouAudio/rss.dart';
import 'package:flutter/material.dart';
class ChannelPage extends StatefulWidget {
  final String id;

  ChannelPage(this.id);

  @override
  ChannelPageState createState() {
    return new ChannelPageState();
  }
}

class ChannelPageState extends State<ChannelPage> {
  List<Video> channelVideos = new List();


  @override
  void initState() {
   getVideoListByChannelId((widget.id)).then((videos) => (){
      setState(() {
        channelVideos = videos;
      });
    });
    super.initState();

  }


  @override
  Widget build(BuildContext context) {
    return new Container(
        child: ListView.builder(
          itemCount: channelVideos != null ? channelVideos.length : 0,
          itemBuilder: (context, position) {
            return ListTile(
                title: RichText(
                  text: new TextSpan(
                    text: '${channelVideos[position].title}',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.black),
                  ),
                ),
                trailing: channelVideos[position].downloaded
                    ? new IconButton(
                    icon: new Icon(Icons.file_download), onPressed: null)
                    : new IconButton(
                    icon: new Icon(Icons.play_arrow), onPressed: null));
          },
        ));
  }

}
