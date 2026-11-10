class QuestionItemDto {
  const QuestionItemDto({
    required this.id,
    required this.title,
    required this.options,
    required this.version,
    this.optionIds = const [],
  });

  final int id;
  final String title;
  final List<String> options;
  final int version;
  final List<String> optionIds;

  factory QuestionItemDto.fromJson(Map<String, dynamic> json) {
    final optionItems = (json['option_items'] as List?) ?? const [];
    final labeledItems = optionItems
        .whereType<Map<String, dynamic>>()
        .map((item) {
          final label = item['label'];
          if (label is Map<String, dynamic>) {
            final zh = (label['zh'] as String?)?.trim() ?? '';
            return (
              id: (item['option_id'] as String?) ?? '',
              label: zh.isNotEmpty
                  ? zh
                  : (label['en'] as String?)?.trim() ?? '',
            );
          }
          return (id: (item['option_id'] as String?) ?? '', label: '');
        })
        .where((v) => v.label.isNotEmpty)
        .toList();
    final optionsFromItems = labeledItems.map((item) => item.label).toList();

    final options = optionsFromItems.isNotEmpty
        ? optionsFromItems
        : ((json['options'] as List?) ?? const [])
              .map((e) => e.toString())
              .where((v) => v.trim().isNotEmpty)
              .toList();

    return QuestionItemDto(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title:
          (json['title'] as String?) ??
          (json['content'] as String?) ??
          (json['question_text_zh'] as String?) ??
          (json['question_text_en'] as String?) ??
          '',
      options: options,
      optionIds: labeledItems.map((item) => item.id).toList(),
      version:
          (json['question_version'] as num?)?.toInt() ??
          (json['version'] as num?)?.toInt() ??
          1,
    );
  }
}
