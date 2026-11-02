import 'package:flutter_riverpod/flutter_riverpod.dart' show Ref;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/enums/app_enums.dart';
import '../../../core/models/issue_report.dart';
import '../../../core/providers/tenant_provider.dart';
import '../../../core/utils/async_value_ext.dart';
import '../../../repositories/repository_providers.dart';
import '../../auth/providers/auth_provider.dart';

part 'issues_providers.g.dart';

/// Every driver issue report, newest first.
@riverpod
Stream<List<IssueReport>> issueReports(Ref ref) {
  final tenantId = ref.watch(currentTenantIdProvider);
  return ref.watch(issueRepositoryProvider).watchAll(tenantId);
}

/// Reports not resolved yet — the admin's to-do count.
@riverpod
int openIssueCount(Ref ref) =>
    (ref.watch(issueReportsProvider).valueOrNull ?? const [])
        .where((r) => r.status != IssueStatus.resolved)
        .length;

/// Ops moves reports through open → in review → resolved.
@Riverpod(keepAlive: true)
class IssueMutations extends _$IssueMutations {
  @override
  FutureOr<void> build() {}

  Future<void> setStatus(IssueReport report, IssueStatus status) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => ref
        .read(issueRepositoryProvider)
        .updateStatus(report, status,
            actorId: ref.read(currentActorIdProvider)));
    state.throwIfError();
  }
}
