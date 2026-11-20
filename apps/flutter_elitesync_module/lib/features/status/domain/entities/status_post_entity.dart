String statusAudienceLabel(String audience) => switch (audience) {
  'FRIENDS' => '双向好友可见',
  'PUBLIC_AUTHENTICATED' => '登录用户可见',
  _ => '仅自己可见',
};

String statusCommentPolicyLabel(String policy) => switch (policy) {
  'FRIENDS_ONLY' => '仅双向好友可评论',
  'ALL_ELIGIBLE' => '有权阅读的登录用户可评论',
  _ => '关闭评论',
};

class StatusPostEntity {
  const StatusPostEntity({
    required this.id,
    required this.title,
    required this.body,
    required this.authorId,
    required this.authorName,
    required this.authorPhone,
    required this.authorRole,
    required this.authorAccountType,
    required this.authorIsSynthetic,
    required this.authorCity,
    required this.authorRelationshipGoal,
    required this.authorPublicMbti,
    required this.authorPublicPersonality,
    required this.locationName,
    required this.visibility,
    this.audience = 'SELF',
    this.commentPolicy = 'OFF',
    this.editorRecommended = false,
    required this.canDelete,
    required this.likesCount,
    required this.likedByViewer,
    this.favoritedByViewer = false,
    required this.coverMediaAssetId,
    required this.coverMediaUrl,
    this.coverMediaType = 'image',
    required this.createdAt,
    required this.isDeleted,
  });

  final int id;
  final String title;
  final String body;
  final int authorId;
  final String authorName;
  final String authorPhone;
  final String authorRole;
  final String authorAccountType;
  final bool authorIsSynthetic;
  final String authorCity;
  final String authorRelationshipGoal;
  final String authorPublicMbti;
  final List<String> authorPublicPersonality;
  final String locationName;
  final String visibility;
  final String audience;
  final String commentPolicy;
  final bool editorRecommended;
  final bool canDelete;
  final int likesCount;
  final bool likedByViewer;
  final bool favoritedByViewer;
  final int? coverMediaAssetId;
  final String? coverMediaUrl;
  final String coverMediaType;
  final DateTime createdAt;
  final bool isDeleted;

  factory StatusPostEntity.fromJson(Map<String, dynamic> json) {
    final author = json['author'] is Map<String, dynamic>
        ? (json['author'] as Map<String, dynamic>)
        : <String, dynamic>{};
    bool parseBool(dynamic value) {
      if (value is bool) return value;
      if (value is num) return value != 0;
      if (value is String) {
        final normalized = value.toLowerCase().trim();
        if (normalized == 'true' || normalized == '1') return true;
        if (normalized == 'false' || normalized == '0') return false;
      }
      return false;
    }

    int parseInt(dynamic value) {
      if (value is num) return value.toInt();
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    List<dynamic> parseList(dynamic value) {
      if (value is List<dynamic>) return value;
      if (value is Map<String, dynamic>) return value.values.toList();
      if (value is String && value.trim().isNotEmpty) return [value];
      return const [];
    }

    String? parseMediaUrl(dynamic value) {
      if (value is Map<String, dynamic>) {
        final publicUrl = (value['public_url'] ?? value['url'] ?? '')
            .toString()
            .trim();
        return publicUrl.isEmpty ? null : publicUrl;
      }
      final list = parseList(value);
      if (list.isEmpty) return null;
      final first = list.first;
      if (first is Map<String, dynamic>) {
        final publicUrl = (first['public_url'] ?? first['url'] ?? '')
            .toString()
            .trim();
        return publicUrl.isEmpty ? null : publicUrl;
      }
      final mediaUrl = first.toString().trim();
      return mediaUrl.isEmpty ? null : mediaUrl;
    }

    return StatusPostEntity(
      id: parseInt(json['id']),
      title: (json['title'] ?? '').toString(),
      body: (json['body'] ?? '').toString(),
      authorId: parseInt(author['id']),
      authorName: (author['name'] ?? '').toString(),
      authorPhone: (author['phone'] ?? '').toString(),
      authorRole: (author['role'] ?? 'user').toString(),
      authorAccountType: (author['account_type'] ?? 'normal').toString(),
      authorIsSynthetic: parseBool(author['is_synthetic']),
      authorCity: (author['city'] ?? '').toString(),
      authorRelationshipGoal: (author['relationship_goal'] ?? '').toString(),
      authorPublicMbti: (author['public_mbti'] ?? '').toString(),
      authorPublicPersonality: parseList(
        author['public_personality'],
      ).map((e) => e.toString()).where((e) => e.isNotEmpty).toList(),
      locationName: (json['location_name'] ?? '').toString(),
      visibility: (json['visibility'] ?? 'public').toString(),
      audience: switch (json['audience']) {
        'FRIENDS' => 'FRIENDS',
        'PUBLIC_AUTHENTICATED' => 'PUBLIC_AUTHENTICATED',
        _ => 'SELF',
      },
      commentPolicy: (json['comment_policy'] as String?) ?? 'OFF',
      editorRecommended: json['editor_recommended'] == true,
      canDelete: parseBool(json['can_delete']),
      likesCount: parseInt(json['likes_count']),
      likedByViewer: parseBool(json['liked_by_viewer']),
      favoritedByViewer: parseBool(json['favorited_by_viewer']),
      coverMediaAssetId:
          (json['cover_media_asset_id'] as num?)?.toInt() ??
          (json['cover_media'] is Map<String, dynamic>
              ? parseInt((json['cover_media'] as Map<String, dynamic>)['id'])
              : null),
      coverMediaUrl:
          parseMediaUrl(json['cover_media']) ?? parseMediaUrl(json['media']),
      coverMediaType:
          json['cover_media'] is Map &&
              json['cover_media']['media_type'] == 'video'
          ? 'video'
          : 'image',
      createdAt:
          DateTime.tryParse((json['created_at'] ?? '').toString()) ??
          DateTime.fromMillisecondsSinceEpoch(0),
      isDeleted: parseBool(json['is_deleted']),
    );
  }

  bool get isPublic => visibility == 'public' || visibility == 'square';

  String get visibilityLabel => statusAudienceLabel(audience);

  String get visibilityTierLabel {
    return switch (visibility) {
      'private' => '私密层',
      'square' => '广场层',
      _ => '公开层',
    };
  }

  String get authorLayerLabel {
    if (authorIsSynthetic) {
      return '示例动态';
    }
    return switch (authorAccountType) {
      'test' => '示例动态',
      _ => '用户动态',
    };
  }

  String get authorLayerBadge {
    return '$authorLayerLabel · $visibilityLabel';
  }

  String get displayAuthorName => authorName.isNotEmpty ? authorName : '示例用户';

  bool get hasMedia => (coverMediaUrl ?? '').isNotEmpty;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'location_name': locationName,
      'visibility': visibility,
      'audience': audience,
      'comment_policy': commentPolicy,
      'editor_recommended': editorRecommended,
      'is_deleted': isDeleted,
      'can_delete': canDelete,
      'likes_count': likesCount,
      'liked_by_viewer': likedByViewer,
      'favorited_by_viewer': favoritedByViewer,
      'cover_media_asset_id': coverMediaAssetId,
      'cover_media': coverMediaUrl == null && coverMediaAssetId == null
          ? null
          : {
              'id': coverMediaAssetId,
              'public_url': coverMediaUrl,
              'media_type': coverMediaType,
            },
      'media': coverMediaUrl == null ? const [] : [coverMediaUrl],
      'created_at': createdAt.toIso8601String(),
      'author': {
        'id': authorId,
        'name': authorName,
        'nickname': authorName,
        'phone': authorPhone,
        'role': authorRole,
        'account_type': authorAccountType,
        'is_synthetic': authorIsSynthetic,
        'city': authorCity,
        'relationship_goal': authorRelationshipGoal,
        'public_mbti': authorPublicMbti,
        'public_personality': authorPublicPersonality,
      },
    };
  }
}
