class Translation {
  String? id;
  String vi;
  String en;

  Translation(this.vi, this.en);

  @override
  bool operator ==(Object other) {
    return vi.toUpperCase() == (other as Translation).vi.toUpperCase()
        && en.toUpperCase() == (other).en.toUpperCase();
  }

  @override
  int get hashCode => vi.hashCode * 31 + en.hashCode;

  bool contains(String str) => normalize(vi.toLowerCase()).contains(normalize(str.toLowerCase()))
      || normalize(en.toLowerCase()).contains(normalize(str.toLowerCase()));

  @override
  String toString() => vi + ' — ' + en;

  bool isEmpty() => vi.isEmpty && en.isEmpty;

  Translation copy() {
    Translation copy = Translation(vi, en);
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