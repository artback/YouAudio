import 'dart:convert';

import 'package:YouAudio/dataModel/video.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  static const _platform = const MethodChannel('com.yaudio');
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  getAndDownloadYoutubeAudio(String url) async {
    bool status = await SimplePermissions.checkPermission(
        Permission.WriteExternalStorage);
     if(!status) {
       await SimplePermissions.requestPermission(
           Permission.WriteExternalStorage);
     }
    AudioInfo audioInfo = await _youtubeToAudio(url);
    _requestYoutubeVideoInfo(url)
        .then((video) => _downloadAudio(audioInfo, video));
  }

  Future<Video> _requestYoutubeVideoInfo(String url) {
    if (!url.contains('/(youtube.com|youtu.be)\/(watch)?(\?v=)?(\S+)?/')) {
      url = 'https://www.youtube.com/watch?v=$url';
    }
    String jsonUrl = 'https://www.youtube.com/oembed?url=$url&format=json';
    getVideo(response) {
      Map videoMap = json.decode(response.body);
      Video video = Video.fromJson(videoMap);
      return video;
    }

    return http.get(jsonUrl).then((response) => getVideo(response));
  }

  Future<AudioInfo> _youtubeToAudio(String url) async {
    if (url.contains('http(?:s?):\/\/(?:www\.)?youtu(?:be\.com\/watch\?v=|\.be\/)([\w\-\_]*)(&(amp;)?‌​[\w\?‌​=]*)?')) {
      url = getIdFromUrl(url);
    }
    var streamInfo = await extractor.getMediaStreamsAsync(url);
    return AudioInfo(
        streamInfo.audio.first.url,
        streamInfo.audio.first.audioEncoding
            .toString()
            .split('.')
            .last
            .toLowerCase());
  }

  _downloadAudio(AudioInfo info, Video youtubeVideo) async {
    Directory dir = await getExternalStorageDirectory();
    String downloadLocation = dir.path + '/Yaudio';
    download() async {
      try {
        String title =
            youtubeVideo.title.replaceAll("\/", "-").replaceAll("\\", "-");
        SharedPreferences prefs =  await _prefs;
        bool wifi =prefs.getBool('wifiOnly') ?? false;
        bool notification = prefs.getBool('notifications') ?? true;
        await _platform.invokeMethod('download', <String, dynamic>{
          'url': info.url,
          'folder': downloadLocation,
          'file_ending': '${info.fileType}',
          'title': '$title',
          'author': '${youtubeVideo.author}',
          'wifi': wifi,
          'notification' : notification
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
