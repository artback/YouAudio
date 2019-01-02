
class Video {
  bool downloaded;
  final String author;
  final String title;
  final DateTime published;
  Video(this.title, this.author,[this.published,this.downloaded]);

  Video.fromJson(Map<String, dynamic> json)
      : author = json['author_name'],
        downloaded = false,
        published = null,
        title = (json['title']);
}
