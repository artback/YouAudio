import 'package:YouAudio/dataModel/content.dart';

class Video extends Content {
  final bool downloaded;
  Video(String id, String name, String description, this.downloaded) : super(id, name, description);
}