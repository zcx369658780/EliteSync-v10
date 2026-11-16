import 'package:flutter/material.dart';
import 'package:flutter_elitesync_module/core/storage/local_storage_service.dart';
import 'package:flutter_elitesync_module/design_system/components/buttons/app_secondary_button.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme_extensions.dart';
import 'package:flutter_elitesync_module/features/onboarding/application/first_use_onboarding_coordinator.dart';

enum FirstUseOnboardingMode { automatic, replay }

enum FirstUseOnboardingResult { skipped, completed }

@immutable
class FirstUseOnboardingStep {
  const FirstUseOnboardingStep({
    required this.title,
    required this.body,
    required this.icon,
  });

  final String title;
  final String body;
  final IconData icon;
}

const firstUseOnboardingSteps = <FirstUseOnboardingStep>[
  FirstUseOnboardingStep(
    title: '查看匹配',
    body: '在“匹配”入口查看结果，回应你感兴趣的候选。',
    icon: Icons.auto_awesome_rounded,
  ),
  FirstUseOnboardingStep(
    title: '按需要完善资料',
    body: '填写资料与偏好，页面会提示尚需准备的内容。',
    icon: Icons.person_outline_rounded,
  ),
  FirstUseOnboardingStep(
    title: '查看站内提醒',
    body: '匹配与消息提醒会显示在站内通知中。',
    icon: Icons.hourglass_bottom_rounded,
  ),
  FirstUseOnboardingStep(
    title: '双方同意后再聊天',
    body: '建立连接并互相同意消息后，就可以开始交流。',
    icon: Icons.chat_bubble_outline_rounded,
  ),
  FirstUseOnboardingStep(
    title: '随时跳过或重新查看',
    body: '可以随时跳过，之后可在“设置 > 新手引导”重新查看。资料与报名请按各自页面完成。',
    icon: Icons.replay_rounded,
  ),
];

Future<FirstUseOnboardingResult?> showFirstUseOnboarding({
  required BuildContext context,
  required LocalStorageService storage,
  required FirstUseOnboardingMode mode,
}) {
  final reduceMotion = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
  return showGeneralDialog<FirstUseOnboardingResult>(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black54,
    transitionDuration: reduceMotion
        ? Duration.zero
        : const Duration(milliseconds: 180),
    pageBuilder: (context, animation, secondaryAnimation) {
      return FirstUseOnboardingPage(storage: storage, mode: mode);
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      if (reduceMotion) return child;
      return FadeTransition(opacity: animation, child: child);
    },
  );
}

class FirstUseOnboardingAutomaticEntry extends StatefulWidget {
  const FirstUseOnboardingAutomaticEntry({
    super.key,
    required this.storage,
    required this.child,
    this.eligible = true,
  });

  final LocalStorageService storage;
  final Widget child;
  final bool eligible;

  @override
  State<FirstUseOnboardingAutomaticEntry> createState() =>
      _FirstUseOnboardingAutomaticEntryState();
}

class _FirstUseOnboardingAutomaticEntryState
    extends State<FirstUseOnboardingAutomaticEntry> {
  final FirstUseOnboardingSessionGate _sessionGate =
      FirstUseOnboardingSessionGate();
  bool _checkScheduled = false;

  @override
  void initState() {
    super.initState();
    _scheduleEligibleCheck();
  }

  @override
  void didUpdateWidget(FirstUseOnboardingAutomaticEntry oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.eligible && widget.eligible) {
      _scheduleEligibleCheck();
    }
  }

  void _scheduleEligibleCheck() {
    if (!widget.eligible || _checkScheduled || _sessionGate.attempted) return;
    _checkScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkScheduled = false;
      if (!mounted || !widget.eligible) return;
      _checkAndPresent();
    });
  }

  Future<void> _checkAndPresent() async {
    if (!mounted || !widget.eligible) return;
    final shouldPresent = await _sessionGate.shouldPresent(
      FirstUseOnboardingCoordinator(widget.storage),
    );
    if (!mounted || !widget.eligible || !shouldPresent) return;
    await showFirstUseOnboarding(
      context: context,
      storage: widget.storage,
      mode: FirstUseOnboardingMode.automatic,
    );
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class FirstUseOnboardingPage extends StatefulWidget {
  const FirstUseOnboardingPage({
    super.key,
    required this.storage,
    required this.mode,
  });

  final LocalStorageService storage;
  final FirstUseOnboardingMode mode;

  @override
  State<FirstUseOnboardingPage> createState() => _FirstUseOnboardingPageState();
}

class _FirstUseOnboardingPageState extends State<FirstUseOnboardingPage> {
  int _stepIndex = 0;
  bool _closing = false;
  bool _allowPop = false;

  FirstUseOnboardingCoordinator get _coordinator =>
      FirstUseOnboardingCoordinator(widget.storage);

  bool get _isLastStep => _stepIndex == firstUseOnboardingSteps.length - 1;

  void _goBack() {
    if (!mounted || _stepIndex == 0 || _closing) return;
    setState(() => _stepIndex -= 1);
  }

  void _goNext() {
    if (!mounted || _isLastStep || _closing) return;
    setState(() => _stepIndex += 1);
  }

  Future<void> _skip() async {
    if (!mounted || _closing) return;
    setState(() => _closing = true);
    try {
      if (widget.mode == FirstUseOnboardingMode.automatic) {
        await _coordinator.markSkipped();
      }
    } finally {
      _popSafely(FirstUseOnboardingResult.skipped);
    }
  }

  Future<void> _finish() async {
    if (!mounted || _closing) return;
    setState(() => _closing = true);
    try {
      if (widget.mode == FirstUseOnboardingMode.automatic) {
        await _coordinator.markCompleted();
      }
    } finally {
      _popSafely(FirstUseOnboardingResult.completed);
    }
  }

  void _popSafely(FirstUseOnboardingResult result) {
    if (!mounted) return;
    setState(() => _allowPop = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Navigator.of(context).pop(result);
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    final step = firstUseOnboardingSteps[_stepIndex];
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final stepContent = _OnboardingStepContent(
      key: ValueKey(_stepIndex),
      step: step,
    );

    return PopScope<void>(
      canPop: _allowPop,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _skip();
      },
      child: Material(
        color: t.pageBackground,
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              t.spacing.pageHorizontal,
              t.spacing.sm,
              t.spacing.pageHorizontal,
              t.spacing.lg,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Semantics(
                        excludeSemantics: true,
                        label:
                            '第 ${_stepIndex + 1} 步，共 ${firstUseOnboardingSteps.length} 步',
                        child: Text(
                          '${_stepIndex + 1}/${firstUseOnboardingSteps.length}',
                          style: Theme.of(context).textTheme.labelLarge
                              ?.copyWith(
                                color: t.textSecondary,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ),
                    ),
                    Semantics(
                      excludeSemantics: true,
                      button: true,
                      label: '跳过首次使用引导',
                      onTap: _closing ? null : _skip,
                      child: _OnboardingSkipButton(
                        label: '跳过',
                        onPressed: _closing ? null : _skip,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: t.spacing.xs),
                ClipRRect(
                  borderRadius: BorderRadius.circular(t.radius.pill),
                  child: LinearProgressIndicator(
                    key: const Key('first-use-onboarding-progress'),
                    minHeight: 5,
                    value: (_stepIndex + 1) / firstUseOnboardingSteps.length,
                    backgroundColor: t.overlay,
                    color: t.textPrimary,
                  ),
                ),
                SizedBox(height: t.spacing.lg),
                Expanded(
                  child: SingleChildScrollView(
                    key: const Key('first-use-onboarding-scroll'),
                    child: reduceMotion
                        ? stepContent
                        : AnimatedSwitcher(
                            key: const Key('first-use-onboarding-transition'),
                            duration: t.motionFast,
                            switchInCurve: Curves.easeOutCubic,
                            switchOutCurve: Curves.easeInCubic,
                            child: stepContent,
                          ),
                  ),
                ),
                SizedBox(height: t.spacing.md),
                Row(
                  children: [
                    if (_stepIndex > 0) ...[
                      Expanded(
                        child: Semantics(
                          excludeSemantics: true,
                          button: true,
                          label: '返回上一步',
                          onTap: _closing ? null : _goBack,
                          child: AppSecondaryButton(
                            label: '上一步',
                            fullWidth: true,
                            onPressed: _closing ? null : _goBack,
                          ),
                        ),
                      ),
                      SizedBox(width: t.spacing.sm),
                    ],
                    Expanded(
                      flex: _stepIndex > 0 ? 1 : 2,
                      child: Semantics(
                        excludeSemantics: true,
                        button: true,
                        label: _isLastStep ? '完成首次使用引导' : '进入下一步',
                        onTap: _closing
                            ? null
                            : (_isLastStep ? _finish : _goNext),
                        child: _OnboardingPrimaryButton(
                          label: _isLastStep ? '完成引导' : '继续',
                          onPressed: _closing
                              ? null
                              : (_isLastStep ? _finish : _goNext),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OnboardingStepContent extends StatelessWidget {
  const _OnboardingStepContent({super.key, required this.step});

  final FirstUseOnboardingStep step;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: t.spacing.xl),
        Container(
          key: const Key('first-use-onboarding-step-icon'),
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: t.textPrimary,
            borderRadius: BorderRadius.circular(t.radius.xl),
          ),
          child: Icon(step.icon, size: 36, color: t.pageBackground),
        ),
        SizedBox(height: t.spacing.xl),
        Text(
          step.title,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: t.textPrimary,
            fontWeight: FontWeight.w800,
            height: 1.25,
          ),
        ),
        SizedBox(height: t.spacing.md),
        Text(
          step.body,
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(color: t.textSecondary, height: 1.6),
        ),
      ],
    );
  }
}

class _OnboardingSkipButton extends StatelessWidget {
  const _OnboardingSkipButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    return TextButton(
      key: const Key('first-use-onboarding-skip-action'),
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: t.textPrimary,
        minimumSize: const Size(48, 48),
        padding: EdgeInsets.symmetric(horizontal: t.spacing.md),
        textStyle: Theme.of(
          context,
        ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
      ),
      child: Text(label),
    );
  }
}

class _OnboardingPrimaryButton extends StatelessWidget {
  const _OnboardingPrimaryButton({
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    final enabled = onPressed != null;
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 52, minWidth: 48),
      child: Material(
        key: const Key('first-use-onboarding-primary-action'),
        color: t.textPrimary,
        borderRadius: BorderRadius.circular(t.radius.lg),
        child: InkWell(
          borderRadius: BorderRadius.circular(t.radius.lg),
          onTap: onPressed,
          child: Center(
            child: Text(
              label,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: t.pageBackground.withValues(alpha: enabled ? 1 : 0.6),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
