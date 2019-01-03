class Sub {
  String title;
  final String channelId;
  final String img;
  bool checked;
  final String description;

  Sub(this.title, this.channelId, this.img, checked,[this.description]){
   checked == null ? this.checked = false :this.checked =checked;
  }
}
