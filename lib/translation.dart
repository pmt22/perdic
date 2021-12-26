class Translation {
  String? id;
  String vi;
  String en;
  String? note;

  Translation(this.vi, this.en);

  @override
  bool operator ==(Object other) {
    return vi.trim().toUpperCase() == (other as Translation).vi.trim().toUpperCase()
        && en.trim().toUpperCase() == (other).en.trim().toUpperCase();
  }

  @override
  int get hashCode => vi.trim().toUpperCase().hashCode * 31 + en.trim().toUpperCase().hashCode * 31;

  bool contains(String str) => normalize(vi.toLowerCase()).contains(normalize(str.toLowerCase()))
      || normalize(en.toLowerCase()).contains(normalize(str.toLowerCase()));

  @override
  String toString() => vi + ' — ' + en;

  bool isEmpty() => vi.isEmpty && en.isEmpty;

  Translation copy() {
    Translation copy = Translation(vi, en);
    copy.note = note;
    copy.id = id;
    return copy;
  }

  void update(Translation updated) {
    vi = updated.vi;
    en = updated.en;
  }

  static Translation get empty => Translation('', '');

  String normalize(String str) {
    var withDia = 'áàảạãăắằẳẵặâấầẩẫậéèẻẽẹêếềểễệíìỉĩịóòỏõọôốồổỗộơớờởỡợúùủũụưứừửữựýỳỷỹỵđ';
    var withoutDia = 'aaaaaaaaaaaaaaaaaeeeeeeeeeeeiiiiiooooooooooooooooouuuuuuuuuuuyyyyyd';

    for (int i = 0; i < withDia.length; i++) {
      str = str.replaceAll(withDia[i], withoutDia[i]);
    }

    return str.trim();
  }
}