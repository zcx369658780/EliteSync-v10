double? readProfileBirthLatitude(Map<String, dynamic> json) =>
    _coordinate(json['birth_lat'], 90) ??
    _coordinate(json['private_birth_lat'], 90);

double? readProfileBirthLongitude(Map<String, dynamic> json) =>
    _coordinate(json['birth_lng'], 180) ??
    _coordinate(json['private_birth_lng'], 180);

double? _coordinate(Object? value, double limit) {
  final number = switch (value) {
    num number => number.toDouble(),
    String decimal => double.tryParse(decimal),
    _ => null,
  };
  if (number == null || !number.isFinite || number.abs() > limit) {
    return null;
  }
  return number;
}
