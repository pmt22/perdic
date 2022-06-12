class WordCategory {
  String? id;
  String text;
  bool isDeleted = false;

  WordCategory(this.text);

  @override
  String toString() {
    return text;
  }
}