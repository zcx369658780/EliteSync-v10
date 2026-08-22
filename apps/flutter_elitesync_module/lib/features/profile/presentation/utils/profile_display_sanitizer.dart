String sanitizeProfileDisplayName(String value) {
  final trimmed = value.trim();
  final normalized = trimmed.toLowerCase();
  if (RegExp(r'^smokeuser\d*$').hasMatch(normalized)) {
    return '示例用户';
  }
  return value;
}

String sanitizeProfileDisplayBirthPlace(
  String? value, {
  String emptyValue = '未填写',
}) {
  final trimmed = value?.trim() ?? '';
  if (trimmed.isEmpty) return emptyValue;
  return trimmed == '北京动物园' ? '已填写示例地点' : trimmed;
}

String sanitizeProfileDisplayCity(
  String? value, {
  String emptyValue = '城市未填写',
}) {
  final trimmed = value?.trim() ?? '';
  if (trimmed.isEmpty) return emptyValue;
  final lower = trimmed.toLowerCase();
  if (lower == 'nanyang') return '南阳';
  if (lower == 'oldcity' || lower == 'newcity') return '示例城市';
  return trimmed;
}
