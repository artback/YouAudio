import 'package:YouAudio/dataModel/content.dart';

class Channel extends Content {
  final bool subscribing;
  final String description;

  Channel(String name, this.description, this.subscribing) : super(name);
}
