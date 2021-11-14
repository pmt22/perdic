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
  int get hashCode => vi.hashCode * 31 + en.hashCode * 31;

  bool contains(String str) => vi.toUpperCase().contains(str.toUpperCase())
      || en.toUpperCase().contains(str.toUpperCase());

  @override
  String toString() => vi + ' — ' + en;

  bool isEmpty() => vi.isEmpty && en.isEmpty;

  Translation copy() => Translation(vi, en);
  void update(Translation updated) {
    vi = updated.vi;
    en = updated.en;
  }

  static Translation get empty => Translation('', '');
}

class TranslationService {
  final Set<Translation> _translations = <Translation>{};

  Set<Translation> get translations => _translations;
}