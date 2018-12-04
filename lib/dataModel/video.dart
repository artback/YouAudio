import 'package:YouAudio/dataModel/content.dart';

class Video extends Content {
  final bool downloaded;
  final String author;
  Video(String id, String name, String description, this.downloaded, this.author) : super(id, name);
  Video.fromJson(Map<String, dynamic> json)
      : author = json['author_name'],
        downloaded = false,
         super('', json['title']);
}