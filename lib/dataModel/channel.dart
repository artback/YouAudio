import 'package:YouAudio/dataModel/content.dart';

class Channel extends Content{
  final bool subscribing;
  Channel(String id, String name, String description, this.subscribing) : super(id, name, description);
}