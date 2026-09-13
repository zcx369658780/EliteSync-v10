enum AppPresentationCondition {
  loading,
  empty,
  offline,
  stale,
  retryableError,
  unavailable,
  authorityNotEstablished,
}

extension AppPresentationConditionCode on AppPresentationCondition {
  String get code => switch (this) {
    AppPresentationCondition.loading => 'loading',
    AppPresentationCondition.empty => 'empty',
    AppPresentationCondition.offline => 'offline',
    AppPresentationCondition.stale => 'stale',
    AppPresentationCondition.retryableError => 'retryableError',
    AppPresentationCondition.unavailable => 'unavailable',
    AppPresentationCondition.authorityNotEstablished =>
      'unknown / authorityNotEstablished',
  };
}

class AppPresentationState {
  const AppPresentationState.loading({
    this.safeTitle = '正在获取当前内容',
    this.safeBody = '所属数据源尚未完成解析；这不代表任何领域状态正在等待或处理。',
    this.owningDomainMeaning,
  }) : condition = AppPresentationCondition.loading,
       mayShowLastKnownContent = false,
       retryAvailable = false,
       safeActionLabel = null;

  const AppPresentationState.empty({
    this.safeTitle = '当前没有可显示内容',
    this.safeBody = '已授权来源当前未返回本页面内容；这不代表拒绝、不符合条件、Safety 结论或生命周期结束。',
    this.owningDomainMeaning,
  }) : condition = AppPresentationCondition.empty,
       mayShowLastKnownContent = false,
       retryAvailable = false,
       safeActionLabel = null;

  const AppPresentationState.offline({
    this.safeTitle = '当前处于离线状态',
    this.safeBody = '网络不可用是传输条件，不会改写任何领域生命周期事实。',
    this.safeActionLabel = '重新请求',
    this.owningDomainMeaning,
  }) : condition = AppPresentationCondition.offline,
       mayShowLastKnownContent = false,
       retryAvailable = true;

  const AppPresentationState.stale({
    this.safeTitle = '正在显示上次已知内容',
    this.safeBody = '这些内容可能已过期，不是当前权威生命周期事实。受保护内容仍须先通过所属隐私与同意门。',
    this.safeActionLabel = '检查更新',
    this.owningDomainMeaning,
  }) : condition = AppPresentationCondition.stale,
       mayShowLastKnownContent = true,
       retryAvailable = true;

  const AppPresentationState.retryableError({
    this.safeTitle = '暂时无法加载',
    this.safeBody = '本次读取未完成；不会据此推断任何领域结果。',
    this.safeActionLabel = '重新加载',
    this.owningDomainMeaning,
  }) : condition = AppPresentationCondition.retryableError,
       mayShowLastKnownContent = false,
       retryAvailable = true;

  const AppPresentationState.unavailable({
    this.safeTitle = '当前无法建立结果',
    this.safeBody = '当前来源无法建立可展示结果，且重试暂时没有意义；这不等于内容不存在或任何领域结论。',
    this.owningDomainMeaning,
  }) : condition = AppPresentationCondition.unavailable,
       mayShowLastKnownContent = false,
       retryAvailable = false,
       safeActionLabel = null;

  const AppPresentationState.authorityNotEstablished({
    this.safeTitle = '权威状态尚未建立',
    this.safeBody = '当前来源不足以授权内容或操作；受保护内容与操作保持关闭。',
    this.owningDomainMeaning,
  }) : condition = AppPresentationCondition.authorityNotEstablished,
       mayShowLastKnownContent = false,
       retryAvailable = false,
       safeActionLabel = null;

  final AppPresentationCondition condition;
  final bool mayShowLastKnownContent;
  final bool retryAvailable;
  final String safeTitle;
  final String safeBody;
  final String? safeActionLabel;

  /// Null means this presentation/transport condition carries no domain fact.
  /// Only the owning domain may supply a value.
  final String? owningDomainMeaning;

  bool get hasOwningDomainMeaning =>
      owningDomainMeaning != null && owningDomainMeaning!.trim().isNotEmpty;
}
