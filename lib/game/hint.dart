class Hint {
  final int hint1;
  final int hint2;

  Hint(this.hint1, this.hint2);

  isHint(int index) {
    return index == hint1 || index == hint2;
  }
}
