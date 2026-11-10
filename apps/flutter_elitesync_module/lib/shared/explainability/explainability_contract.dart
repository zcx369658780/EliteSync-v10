class ExplainabilityContent {
  const ExplainabilityContent({
    required this.whatHappened,
    required this.why,
    required this.informationClasses,
    required this.doesNotMean,
    required this.uncertaintyAndLimits,
    required this.userControls,
  });

  final String whatHappened;
  final String why;
  final List<String> informationClasses;
  final String doesNotMean;
  final String uncertaintyAndLimits;
  final List<String> userControls;
}
