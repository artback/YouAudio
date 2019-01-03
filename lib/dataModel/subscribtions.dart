class Sub {
  final String id;
  final String title;
  final String description;
  final String channelId;
  final String img;
  bool checked;

  Sub(this.id, this.title, this.description, this.channelId, this.img, checked ){
   checked == null ? this.checked = false :this.checked =checked;
  }
}
