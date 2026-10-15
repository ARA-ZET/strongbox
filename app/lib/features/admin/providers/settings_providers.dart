import 'package:flutter_riverpod/flutter_riverpod.dart' show Ref;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/enums/app_enums.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/models/app_user.dart';
import '../../../core/providers/business_settings_provider.dart';
import '../../../core/providers/tenant_provider.dart';
import '../../../repositories/repository_providers.dart';
import '../../auth/providers/auth_provider.dart';

part 'settings_providers.g.dart';

/// Everyone with [role], live — the admins and drivers on the Team list.
@riverpod
Stream<List<AppUser>> teamMembers(Ref ref, UserRole role) {
  final tenantId = ref.watch(currentTenantIdProvider);
  return ref.watch(userRepositoryProvider).watchByRole(tenantId, role);
}

/// Team & roles: find a signed-up account and change what it can do.
/// People register themselves (always as clients); an admin then promotes
/// them here. Every change is audited.
@Riverpod(keepAlive: true)
class TeamEditor extends _$TeamEditor {
  @override
  void build() {}

  /// The account registered with [email]; throws [StateError] with a
  /// next step when there is none.
  Future<AppUser> findAccount(String email) async {
    final user = await ref
        .read(userRepositoryProvider)
        .findByEmail(ref.read(currentTenantIdProvider), email);
    if (user == null) {
      throw StateError(
        'No account uses $email. Ask them to sign up in the '
        'app first, then add them here.',
      );
    }
    return user;
  }

  /// Gives [user] [role]. You can't change your own role — that also
  /// guarantees at least one admin always remains.
  Future<void> changeRole(AppUser user, UserRole role) async {
    final actorId = ref.read(currentActorIdProvider);
    if (user.id == actorId) {
      throw StateError("You can't change your own role. Ask another admin.");
    }
    if (user.role == role) return;
    await ref
        .read(userRepositoryProvider)
        .changeRole(user, role, actorId: actorId);
  }
}

/// The signed-in admin's own name and phone.
@Riverpod(keepAlive: true)
class ProfileEditor extends _$ProfileEditor {
  @override
  void build() {}

  Future<void> save({required String name, required String phone}) async {
    if (name.trim().isEmpty) throw StateError('Name is required.');
    await ref.read(userRepositoryProvider).updateUser(
      ref.read(currentActorIdProvider),
      {
        'name': name.trim(),
        'phone': phone.trim().isEmpty ? null : phone.trim(),
      },
    );
  }
}

/// Business details and operations defaults. Saves apply to the latest
/// stored settings in a transaction and are validated first; a problem
/// throws [StateError] with the reason and nothing is written.
@Riverpod(keepAlive: true)
class BusinessSettingsEditor extends _$BusinessSettingsEditor {
  @override
  void build() {}

  Future<void> save(BusinessSettings Function(BusinessSettings) change) async {
    try {
      await ref.read(tenantRepositoryProvider).updateSettings(
        ref.read(currentTenantIdProvider),
        (current) {
          final next = change(current);
          final problems = validateBusinessSettings(next);
          if (problems.isNotEmpty) throw StateError(problems.first);
          return next;
        },
        actorId: ref.read(currentActorIdProvider),
      );
    } on AppException catch (error) {
      // Surface our own validation message, not the repository's wrapper.
      final original = error.original;
      if (original is StateError) throw original;
      rethrow;
    }
    if (ref.read(liveBusinessSettingsProvider).hasError) {
      ref.invalidate(liveBusinessSettingsProvider);
    }
  }
}
