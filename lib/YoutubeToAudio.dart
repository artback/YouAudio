import 'dart:convert';

import 'package:YouAudio/dataModel/video.dart';
import 'package:youtube_extractor/youtube_extractor.dart';
import "package:youtube_parser/youtube_parser.dart";
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:http/http.dart' as http;
var extractor = YouTubeExtractor();


getAndDownloadYoutubeAudio(String url)async{
   String audioUrl =await youtubeToAudio(url);
   requestYoutubeVideoInfo(url).then((video) => {});
}
Future<Video> requestYoutubeVideoInfo(String url) {
  var jsonUrl = 'https://www.youtube.com/oembed?url=$url&format=json';
  getVideo(response){
    Map videoMap = json.decode(response.body);
    Video video= new Video.fromJson(videoMap);
    return video;
  }
  return http.get(jsonUrl).then((response)=> getVideo(response));
}
youtubeToAudio( String url)async{
  String youtubeId = getIdFromUrl(url);
  var streamInfo = await extractor.getMediaStreamsAsync(youtubeId);
  print('Audio URL: ${streamInfo.audio.first.url}');
  print('Audio  ${streamInfo.audio.first.audioEncoding}');
  return streamInfo.audio.first.url;
}
downloadAudioUrl(String audioUrl, String downloadLocation ) async {
  final taskId = await FlutterDownloader.enqueue(
    url: audioUrl,
    savedDir: downloadLocation,
    showNotification: true, // show download progress in status bar (for Android)
    openFileFromNotification: true, // click on notification to open downloaded file (for Android)
  );
}
