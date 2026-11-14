String buddyLocalTime(Object? value) {
  var raw = value?.toString() ?? '';
  if (!RegExp(r'(Z|[+-]\d{2}:?\d{2})$').hasMatch(raw)) {
    raw = '${raw.replaceFirst(' ', 'T')}Z';
  }
  final date = DateTime.tryParse(raw)?.toLocal();
  if (date == null) return '时间暂不可用';
  String two(int value) => value.toString().padLeft(2, '0');
  return '${date.year}-${two(date.month)}-${two(date.day)} ${two(date.hour)}:${two(date.minute)} ${date.timeZoneName}';
}
