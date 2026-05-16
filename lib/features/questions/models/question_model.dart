class EnadeQuestion {
  final String id;
  final String text;
  final List<String> options;
  final int correctOptionIndex;
  final List<String> hints;

  EnadeQuestion({
    required this.id,
    required this.text,
    required this.options,
    required this.correctOptionIndex,
    required this.hints,
  });
}