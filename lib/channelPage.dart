import 'package:YouAudio/AudioPlayerSingleton.dart';
import 'package:YouAudio/FilesSingleton.dart';
import 'package:YouAudio/YoutubeToAudio.dart';
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
  List<Video> channelVideos;
  Downloader downloader = new Downloader();

  Future _getVideos() async{
    List<Video> videos = await getVideoListByChannelId((widget.id));
    if(this.mounted) {
      setState(() {
        channelVideos = videos;
      });
    }
    _checkDownloadStatus();
  }
  _checkDownloadStatus() async{
    channelVideos.forEach((title) => _isInDirectory(title));
  }
  _isInDirectory(Video video){
    List<String> filename = new FilesSingleton().filename;
    video.downloaded = filename.contains(video.title);
    if(video.downloaded) {
      video.index = filename.indexOf(video.title);
    }
  }
  @override
  void initState() {
    _getVideos();
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
                        fontSize: 16,
                        color: Colors.black),
                  ),
                ),
                trailing: channelVideos[position].downloaded
                    ? new IconButton(
                    icon: new Icon(Icons.play_arrow), onPressed: (){
                      new AudioPlayerSingleton().play(channelVideos[position].index);
                    })
                    : new IconButton(
                    icon: new Icon(Icons.file_download), onPressed: (){
                    downloader.getAndDownloadYoutubeAudio(channelVideos[position].url.split('=').last);
                  }));
          },
        ));
  }

}
