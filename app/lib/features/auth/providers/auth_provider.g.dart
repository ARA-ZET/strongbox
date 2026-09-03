// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$firebaseAuthHash() => r'8c3e9d11b27110ca96130356b5ef4d5d34a5ffc2';

/// Raw FirebaseAuth instance — the only place it is referenced directly.
///
/// Copied from [firebaseAuth].
@ProviderFor(firebaseAuth)
final firebaseAuthProvider = Provider<FirebaseAuth>.internal(
  firebaseAuth,
  name: r'firebaseAuthProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$firebaseAuthHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef FirebaseAuthRef = ProviderRef<FirebaseAuth>;
String _$authStateHash() => r'4f403845df0a7b94f769c9a7d5f9b2e890f4960f';

/// Emits the Firebase [User] on every sign-in/sign-out.
///
/// Copied from [authState].
@ProviderFor(authState)
final authStateProvider = StreamProvider<User?>.internal(
  authState,
  name: r'authStateProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$authStateHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef AuthStateRef = StreamProviderRef<User?>;
String _$currentUserHash() => r'64f4bdd453f2a67e91f9e41f2348702b29cb1ace';

/// The signed-in user's `users/{uid}` document as an [AppUser], or null.
///
/// Copied from [currentUser].
@ProviderFor(currentUser)
final currentUserProvider = StreamProvider<AppUser?>.internal(
  currentUser,
  name: r'currentUserProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$currentUserHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef CurrentUserRef = StreamProviderRef<AppUser?>;
String _$currentActorIdHash() => r'a4e9ca6f3c414648b7359c3640cb505463249205';

/// The signed-in user's uid, used as the `actorId` on repository writes.
///
/// Copied from [currentActorId].
@ProviderFor(currentActorId)
final currentActorIdProvider = AutoDisposeProvider<String>.internal(
  currentActorId,
  name: r'currentActorIdProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$currentActorIdHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef CurrentActorIdRef = AutoDisposeProviderRef<String>;
String _$authNotifierHash() => r'e9e2dac21a277c8f50e24b53db4568d05c7898d9';

/// Auth actions. keepAlive: registration routes away mid-write, and
/// auto-dispose would tear the notifier down before the user doc lands.
///
/// Account merging: Firebase's "one account per email" (console default,
/// keep it ON) preserves the uid when a password user later signs in with
/// Google. The reverse — registering a password on a Google-first account —
/// throws `email-already-in-use`, which [register] converts into
/// [AuthErrorCodes.linkGoogle] so the UI can run
/// [linkPasswordWithGoogle] and attach both providers to ONE uid.
///
/// Copied from [AuthNotifier].
@ProviderFor(AuthNotifier)
final authNotifierProvider = AsyncNotifierProvider<AuthNotifier, void>.internal(
  AuthNotifier.new,
  name: r'authNotifierProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$authNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$AuthNotifier = AsyncNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
