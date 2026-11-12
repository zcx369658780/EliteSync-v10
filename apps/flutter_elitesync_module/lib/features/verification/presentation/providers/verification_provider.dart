import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_elitesync_module/features/verification/data/datasource/verification_remote_data_source.dart';
import 'package:flutter_elitesync_module/features/verification/data/mapper/verification_mapper.dart';
import 'package:flutter_elitesync_module/features/verification/data/repository/verification_repository_impl.dart';
import 'package:flutter_elitesync_module/features/verification/domain/repository/verification_repository.dart';
import 'package:flutter_elitesync_module/features/verification/domain/usecases/get_verification_status_usecase.dart';
import 'package:flutter_elitesync_module/features/verification/domain/usecases/submit_verification_usecase.dart';
import 'package:flutter_elitesync_module/features/verification/presentation/state/verification_ui_state.dart';
import 'package:flutter_elitesync_module/shared/providers/app_providers.dart';
import 'package:flutter_elitesync_module/shared/providers/session_provider.dart';
import 'package:flutter_elitesync_module/shared/enums/verification_status.dart';

final verificationRemoteDataSourceProvider =
    Provider<VerificationRemoteDataSource>((ref) {
      final env = ref.watch(appEnvProvider);
      return VerificationRemoteDataSource(
        apiClient: ref.watch(apiClientProvider),
        useMock: env.useMockData,
      );
    });

final verificationRepositoryProvider = Provider<VerificationRepository>((ref) {
  return VerificationRepositoryImpl(
    remote: ref.watch(verificationRemoteDataSourceProvider),
    mapper: const VerificationMapper(),
  );
});

final getVerificationStatusUseCaseProvider =
    Provider<GetVerificationStatusUseCase>((ref) {
      return GetVerificationStatusUseCase(
        ref.watch(verificationRepositoryProvider),
      );
    });

final submitVerificationUseCaseProvider = Provider<SubmitVerificationUseCase>((
  ref,
) {
  return SubmitVerificationUseCase(ref.watch(verificationRepositoryProvider));
});

enum VerificationSubmissionResult { confirmed, failed, unconfirmed, obsolete }

class _VerificationConfirmation {
  bool active = true;
  bool required = false;
  bool submitting = false;
}

// Keep the receipt through profile updates and verification-provider refreshes.
// Authentication intent changes, logout, and account changes replace this holder.
final _verificationConfirmationProvider = Provider<_VerificationConfirmation>((
  ref,
) {
  final sessionNotifier = ref.watch(sessionProvider.notifier);
  ref.watch(
    sessionProvider.select(
      (value) => (
        value.asData?.value.isLoggedIn,
        value.asData?.value.user?.id,
        sessionNotifier.currentAuthenticationIntent,
      ),
    ),
  );
  final confirmation = _VerificationConfirmation();
  ref.onDispose(() => confirmation.active = false);
  return confirmation;
});

class VerificationNotifier extends AsyncNotifier<VerificationUiState> {
  int _operation = 0;
  bool get _requiresConfirmation =>
      ref.read(_verificationConfirmationProvider).required;
  set _requiresConfirmation(bool value) =>
      ref.read(_verificationConfirmationProvider).required = value;

  bool get requiresConfirmation => _requiresConfirmation;

  bool _current(int operation, SessionState session) =>
      operation == _operation &&
      identical(ref.read(sessionProvider).asData?.value, session);

  @override
  Future<VerificationUiState> build() async {
    final session = ref.watch(sessionProvider).asData?.value;
    _operation++;
    ref.watch(_verificationConfirmationProvider);
    ref.onDispose(() => _operation++);
    if (session?.isLoggedIn != true) return const VerificationUiState();
    final status = await ref.read(getVerificationStatusUseCaseProvider).call();
    return VerificationUiState(status: status);
  }

  Future<VerificationSubmissionResult> refresh() async {
    final session = ref.read(sessionProvider).asData?.value;
    final current = state.asData?.value ?? const VerificationUiState();
    if (session?.isLoggedIn != true ||
        current.isSubmitting ||
        current.isLoading) {
      return VerificationSubmissionResult.obsolete;
    }
    final operation = ++_operation;
    state = AsyncData(
      current.copyWith(isLoading: true, clearError: true, clearMessage: true),
    );
    try {
      final status = await ref
          .read(getVerificationStatusUseCaseProvider)
          .call();
      if (!_current(operation, session!)) {
        return VerificationSubmissionResult.obsolete;
      }
      if (_requiresConfirmation &&
          (status.status == VerificationStatus.unknown ||
              status.status == VerificationStatus.unverified)) {
        throw StateError('服务器尚未返回已提交的认证状态');
      }
      final confirmedSubmission = _requiresConfirmation;
      _requiresConfirmation = false;
      state = AsyncData(
        current.copyWith(
          status: status,
          isLoading: false,
          clearError: true,
          message: confirmedSubmission ? '提交成功，状态已确认' : null,
          clearMessage: !confirmedSubmission,
        ),
      );
      return VerificationSubmissionResult.confirmed;
    } catch (e) {
      if (!_current(operation, session!)) {
        return VerificationSubmissionResult.obsolete;
      }
      state = AsyncData(
        current.copyWith(
          isLoading: false,
          error: _requiresConfirmation
              ? '已接收提交，但状态尚未确认，请刷新提交状态。$e'
              : '状态加载失败，请重试。$e',
        ),
      );
      return _requiresConfirmation
          ? VerificationSubmissionResult.unconfirmed
          : VerificationSubmissionResult.failed;
    }
  }

  Future<VerificationSubmissionResult> submit({
    required String realName,
    required String idNumber,
  }) async {
    if (_requiresConfirmation) return refresh();
    final confirmation = ref.read(_verificationConfirmationProvider);
    if (confirmation.submitting) return VerificationSubmissionResult.obsolete;
    final session = ref.read(sessionProvider).asData?.value;
    final current = state.asData?.value ?? const VerificationUiState();
    if (session?.isLoggedIn != true ||
        current.isSubmitting ||
        current.isLoading) {
      return VerificationSubmissionResult.obsolete;
    }
    final operation = ++_operation;
    state = AsyncData(
      current.copyWith(
        isSubmitting: true,
        clearError: true,
        clearMessage: true,
      ),
    );
    confirmation.submitting = true;
    try {
      await ref
          .read(submitVerificationUseCaseProvider)
          .call(realName: realName, idNumber: idNumber);
      // Preserve a received POST across same-authentication UI rebuilds before
      // discarding the old operation. Retired authentication holders stay closed.
      if (confirmation.active) confirmation.required = true;
      if (!_current(operation, session!)) {
        return VerificationSubmissionResult.obsolete;
      }
    } catch (e) {
      if (!_current(operation, session!)) {
        return VerificationSubmissionResult.obsolete;
      }
      state = AsyncData(
        current.copyWith(isSubmitting: false, error: '提交失败，请检查后重试。$e'),
      );
      return VerificationSubmissionResult.failed;
    } finally {
      confirmation.submitting = false;
    }
    // Once POST succeeds, retries only read status and never replay the submission.
    state = AsyncData(current.copyWith(isSubmitting: false, clearError: true));
    return refresh();
  }
}

final verificationProvider =
    AsyncNotifierProvider<VerificationNotifier, VerificationUiState>(
      VerificationNotifier.new,
    );
