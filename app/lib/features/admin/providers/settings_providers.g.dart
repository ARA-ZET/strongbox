// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$teamMembersHash() => r'1c1aa80e2ae4006d9c4120d03894ba6aa68b91a5';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// Everyone with [role], live — the admins and drivers on the Team list.
///
/// Copied from [teamMembers].
@ProviderFor(teamMembers)
const teamMembersProvider = TeamMembersFamily();

/// Everyone with [role], live — the admins and drivers on the Team list.
///
/// Copied from [teamMembers].
class TeamMembersFamily extends Family<AsyncValue<List<AppUser>>> {
  /// Everyone with [role], live — the admins and drivers on the Team list.
  ///
  /// Copied from [teamMembers].
  const TeamMembersFamily();

  /// Everyone with [role], live — the admins and drivers on the Team list.
  ///
  /// Copied from [teamMembers].
  TeamMembersProvider call(
    UserRole role,
  ) {
    return TeamMembersProvider(
      role,
    );
  }

  @override
  TeamMembersProvider getProviderOverride(
    covariant TeamMembersProvider provider,
  ) {
    return call(
      provider.role,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'teamMembersProvider';
}

/// Everyone with [role], live — the admins and drivers on the Team list.
///
/// Copied from [teamMembers].
class TeamMembersProvider extends AutoDisposeStreamProvider<List<AppUser>> {
  /// Everyone with [role], live — the admins and drivers on the Team list.
  ///
  /// Copied from [teamMembers].
  TeamMembersProvider(
    UserRole role,
  ) : this._internal(
          (ref) => teamMembers(
            ref as TeamMembersRef,
            role,
          ),
          from: teamMembersProvider,
          name: r'teamMembersProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$teamMembersHash,
          dependencies: TeamMembersFamily._dependencies,
          allTransitiveDependencies:
              TeamMembersFamily._allTransitiveDependencies,
          role: role,
        );

  TeamMembersProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.role,
  }) : super.internal();

  final UserRole role;

  @override
  Override overrideWith(
    Stream<List<AppUser>> Function(TeamMembersRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: TeamMembersProvider._internal(
        (ref) => create(ref as TeamMembersRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        role: role,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<List<AppUser>> createElement() {
    return _TeamMembersProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is TeamMembersProvider && other.role == role;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, role.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin TeamMembersRef on AutoDisposeStreamProviderRef<List<AppUser>> {
  /// The parameter `role` of this provider.
  UserRole get role;
}

class _TeamMembersProviderElement
    extends AutoDisposeStreamProviderElement<List<AppUser>>
    with TeamMembersRef {
  _TeamMembersProviderElement(super.provider);

  @override
  UserRole get role => (origin as TeamMembersProvider).role;
}

String _$teamEditorHash() => r'92e6a3a140f3f415362867a40d6d96cd33805c14';

/// Team & roles: find a signed-up account and change what it can do.
/// People register themselves (always as clients); an admin then promotes
/// them here. Every change is audited.
///
/// Copied from [TeamEditor].
@ProviderFor(TeamEditor)
final teamEditorProvider = NotifierProvider<TeamEditor, void>.internal(
  TeamEditor.new,
  name: r'teamEditorProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$teamEditorHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$TeamEditor = Notifier<void>;
String _$profileEditorHash() => r'807c8e40e08b931d15b304368391af12c1488be4';

/// The signed-in admin's own name and phone.
///
/// Copied from [ProfileEditor].
@ProviderFor(ProfileEditor)
final profileEditorProvider = NotifierProvider<ProfileEditor, void>.internal(
  ProfileEditor.new,
  name: r'profileEditorProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$profileEditorHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ProfileEditor = Notifier<void>;
String _$businessSettingsEditorHash() =>
    r'9ba3d2e538729eab9cdbc9badfac3ae2631dda48';

/// Business details and operations defaults. Saves apply to the latest
/// stored settings in a transaction and are validated first; a problem
/// throws [StateError] with the reason and nothing is written.
///
/// Copied from [BusinessSettingsEditor].
@ProviderFor(BusinessSettingsEditor)
final businessSettingsEditorProvider =
    NotifierProvider<BusinessSettingsEditor, void>.internal(
  BusinessSettingsEditor.new,
  name: r'businessSettingsEditorProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$businessSettingsEditorHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$BusinessSettingsEditor = Notifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
