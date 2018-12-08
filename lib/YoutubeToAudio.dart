import 'dart:convert';

import 'package:YouAudio/dataModel/video.dart';
import 'package:flutter/services.dart';
import 'package:youtube_extractor/youtube_extractor.dart';
import "package:youtube_parser/youtube_parser.dart";
import 'package:http/http.dart' as http;

var extractor = YouTubeExtractor();

class AudioInfo {
  final String url;
  final String fileType;
  AudioInfo(this.url, this.fileType);
}

class Downloader {
  static const platform = const MethodChannel('com.yaudio');
  getAndDownloadYoutubeAudio(String url) async {
    AudioInfo audioInfo = await youtubeToAudio(url);
    requestYoutubeVideoInfo(url).then((video) =>
        downloadAudio(audioInfo, '/storage/emulated/0/Yaudio', video));
  }

  Future<Video> requestYoutubeVideoInfo(String url) {
    var jsonUrl = 'https://www.youtube.com/oembed?url=$url&format=json';
    getVideo(response) {
      Map videoMap = json.decode(response.body);
      Video video = Video.fromJson(videoMap);
      return video;
    }

    return http.get(jsonUrl).then((response) => getVideo(response));
  }

  Future<AudioInfo> youtubeToAudio(String url) async {
    String youtubeId = getIdFromUrl(url);
    var streamInfo = await extractor.getMediaStreamsAsync(youtubeId);
    return AudioInfo(
        streamInfo.audio.first.url,
        streamInfo.audio.first.audioEncoding
            .toString()
            .split('.')
            .last
            .toLowerCase());
  }

  downloadAudio(
      AudioInfo info, String downloadLocation, Video youtubeVideo) async {
    String name= youtubeVideo.name;
    if(name.length >= 50)
      name.substring(0,50);
    try {
      await platform.invokeMethod('download', <String, dynamic>{
        'url': info.url,
        'folder': downloadLocation,
        'filename': '$name.${info.fileType}'
      });
    } on PlatformException {
      print('Failed to download audio');
    }
  }
}
