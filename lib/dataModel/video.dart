
class Video {
  bool downloaded;
  final String author;
  final String title;
  final DateTime published;
  final String url;
  int index;
  Video(this.title, this.author,[this.published, this.url,this.downloaded = false]);

  Video.fromJson(Map<String, dynamic> json)
      : author = json['author_name'],
        downloaded = false,
        published = null,
        url = json['url'],
        title = (json['title']);
}
