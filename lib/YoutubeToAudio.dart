import 'dart:convert';

import 'package:YouAudio/dataModel/video.dart';
import 'package:flutter/services.dart';
import 'package:simple_permissions/simple_permissions.dart';
import 'package:youtube_extractor/youtube_extractor.dart';
import "package:youtube_parser/youtube_parser.dart";
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:path_provider/path_provider.dart';

var extractor = YouTubeExtractor();

class AudioInfo {
  final String url;
  final String fileType;

  AudioInfo(this.url, this.fileType);
}

class Downloader {
  static const platform = const MethodChannel('com.yaudio');

  getAndDownloadYoutubeAudio(String url) async {
    bool status = await SimplePermissions.checkPermission(
        Permission.WriteExternalStorage);
    while (!status) {
      await SimplePermissions.requestPermission(
          Permission.WriteExternalStorage);
      status = await SimplePermissions.checkPermission(
          Permission.WriteExternalStorage);
    }
    AudioInfo audioInfo = await youtubeToAudio(url);
    requestYoutubeVideoInfo(url)
        .then((video) => downloadAudio(audioInfo, video));
  }

  Future<Video> requestYoutubeVideoInfo(String url) {
    if (!url.contains('/(youtube.com|youtu.be)\/(watch)?(\?v=)?(\S+)?/')) {
      url = 'https://www.youtube.com/watch?v=$url';
    }
    String jsonUrl = 'https://www.youtube.com/oembed?url=$url&format=json';
    print(jsonUrl);
    getVideo(response) {
      Map videoMap = json.decode(response.body);
      Video video = Video.fromJson(videoMap);
      return video;
    }

    return http.get(jsonUrl).then((response) => getVideo(response));
  }

  Future<AudioInfo> youtubeToAudio(String url) async {
    String youtubeId;
    if (url.contains('/(youtube.com|youtu.be)\/(watch)?(\?v=)?(\S+)?/')) {
      youtubeId = getIdFromUrl(url);
    } else {
      youtubeId = url;
    }
    var streamInfo = await extractor.getMediaStreamsAsync(youtubeId);
    return AudioInfo(
        streamInfo.audio.first.url,
        streamInfo.audio.first.audioEncoding
            .toString()
            .split('.')
            .last
            .toLowerCase());
  }

  downloadAudio(AudioInfo info, Video youtubeVideo) async {
    Directory dir = await getExternalStorageDirectory();
    String downloadLocation = dir.path + '/Yaudio';
    download() async {
      try {
        String title =
            youtubeVideo.title.replaceAll("\/", "-").replaceAll("\\", "-");
        await platform.invokeMethod('download', <String, dynamic>{
          'url': info.url,
          'folder': downloadLocation,
          'file_ending': '${info.fileType}',
          'title': '$title',
          'author': '${youtubeVideo.author}',
        });
      } on PlatformException {
        print('Failed to download audio');
      }
    }

    createDir() {
      new Directory(downloadLocation)
          .create(recursive: true)
          .then((Directory directory) {
        download();
      });
    }

    final myDir = new Directory(downloadLocation);
    myDir.exists().then((isThere) {
      isThere ? download() : createDir();
    });
  }
}
