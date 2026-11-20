import 'package:flutter/material.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/providers/astro_profile_errors.dart';

class AstroProfileStateSpec {
  const AstroProfileStateSpec({
    required this.title,
    required this.description,
    required this.icon,
    this.actionLabel,
  });

  final String title;
  final String description;
  final IconData icon;
  final String? actionLabel;
}

AstroProfileStateSpec astroProfileLoadingSpec(String moduleName) {
  return AstroProfileStateSpec(
    title: '正在加载$moduleName',
    description: '正在准备$moduleName内容，请稍候。',
    icon: Icons.hourglass_empty_rounded,
  );
}

AstroProfileStateSpec astroProfileEmptySpec(String moduleName) {
  return AstroProfileStateSpec(
    title: '暂无$moduleName数据',
    description: '可在本命工具中手填本次输入并保存计算结果。',
    icon: Icons.inbox_outlined,
    actionLabel: '重新加载',
  );
}

AstroProfileStateSpec astroProfileErrorSpec(String moduleName, Object error) {
  if (error is AstroProfileApiException) {
    if (error.code == 'LEGAL_BASIS_UNVERIFIED') {
      return const AstroProfileStateSpec(
        title: '旧排盘资料暂不可复用',
        description: '可打开本命工具，手填本次计算所需的资料。',
        icon: Icons.lock_outline_rounded,
      );
    }
    if (error.isUnauthorized) {
      return AstroProfileStateSpec(
        title: '$moduleName登录已失效',
        description: '当前会话已过期或未登录，请重新登录后再查看。',
        icon: Icons.lock_outline_rounded,
        actionLabel: '去登录',
      );
    }

    if (error.isNotFound) {
      return AstroProfileStateSpec(
        title: '服务端暂无$moduleName',
        description: '当前账号没有可用记录。可在本命工具中手填本次输入。',
        icon: Icons.inbox_outlined,
        actionLabel: '重新加载',
      );
    }

    if (error.isRateLimited) {
      return AstroProfileStateSpec(
        title: '$moduleName请求过于频繁',
        description: '请求被限流了，请稍后再试。',
        icon: Icons.hourglass_bottom_rounded,
        actionLabel: '重新加载',
      );
    }

    if (error.isServerError) {
      return AstroProfileStateSpec(
        title: '$moduleName服务暂不可用',
        description: '服务端当前不可用，请稍后再试。',
        icon: Icons.cloud_off_rounded,
        actionLabel: '重新加载',
      );
    }

    return AstroProfileStateSpec(
      title: '$moduleName加载失败',
      description: error.message.isNotEmpty ? error.message : '请稍后再试。',
      icon: Icons.error_outline_rounded,
      actionLabel: '重新加载',
    );
  }

  final text = error.toString();
  if (text.contains('Unauthorized')) {
    return AstroProfileStateSpec(
      title: '$moduleName登录已失效',
      description: '当前会话已过期或未登录，请重新登录后再查看。',
      icon: Icons.lock_outline_rounded,
      actionLabel: '去登录',
    );
  }
  if (text.contains('Not found')) {
    return AstroProfileStateSpec(
      title: '服务端暂无$moduleName',
      description: '当前账号没有可用记录。可在本命工具中手填本次输入。',
      icon: Icons.inbox_outlined,
      actionLabel: '重新加载',
    );
  }
  if (text.contains('Server error')) {
    return AstroProfileStateSpec(
      title: '$moduleName服务暂不可用',
      description: '服务端当前不可用，请稍后再试。',
      icon: Icons.cloud_off_rounded,
      actionLabel: '重新加载',
    );
  }
  if (text.contains('Connection') ||
      text.contains('timeout') ||
      text.contains('network')) {
    return AstroProfileStateSpec(
      title: '$moduleName网络异常',
      description: '请检查网络连接后重试。',
      icon: Icons.wifi_off_rounded,
      actionLabel: '重新加载',
    );
  }

  return AstroProfileStateSpec(
    title: '$moduleName加载失败',
    description: '请稍后重试。',
    icon: Icons.error_outline_rounded,
    actionLabel: '重新加载',
  );
}
