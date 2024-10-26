class Hint {
  final int hint1;
  final int hint2;

  Hint(this.hint1, this.hint2);

  bool isHint(int index) {
    return index == hint1 || index == hint2;
  }

  @override
  String toString() {
    return '[$hint1; $hint2]';
  }
}
