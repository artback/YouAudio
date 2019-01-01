
class Video {
  final bool downloaded;
  final String author;
  final String title;
  Video(this.title, this.downloaded, this.author);

  Video.fromJson(Map<String, dynamic> json)
      : author = json['author_name'],
        downloaded = false,
        title = (json['title']);
}
