// Model jedneho policka v mriezke (jedno pismeno a jeho stav).
class Wordle {
  String letter; // samotne pismeno
  bool existsInTarget; // pismeno sa nachadza v cielovom slove
  bool doesNotExistInTarget; // pismeno sa v cielovom slove nenachadza

  Wordle({
    required this.letter,
    this.existsInTarget = false,
    this.doesNotExistInTarget = false,
  });
}
