# 07 — Flutter Architecture

## Core Principles
1. **Feature-first folder structure** — code is organised by feature, not by type
2. **Repository pattern** — all Firestore/Storage access goes through repositories
3. **Riverpod for all state** — no `setState`, no `BuildContext`-based state
4. **Immutable models** — use `freezed` for all data classes
5. **Never access Firebase from widgets or providers directly** — always via repositories
6. **Responsive by default** — every screen handles desktop and mobile with `LayoutBuilder`

---

## Folder Structure

```
lib/
  core/
    theme/
      app_colors.dart          # Colour constants — never use raw hex in widgets
      app_theme.dart           # ThemeData + component themes
    widgets/                   # Shared UI components (see 11_COMPONENT_LIBRARY.md)
    utils/
      qr_generator.dart        # QR code ID generation
      pdf_builder.dart         # QR label PDF generation
      date_formatters.dart
      validators.dart
    constants/
      firestore_collections.dart
      storage_paths.dart
      app_constants.dart       # e.g. box limits per plan
    errors/
      app_exception.dart
  features/
    auth/
      screens/
        login_screen.dart
        register_screen.dart
      providers/
        auth_provider.dart
      models/
        app_user.dart
    admin/
      screens/
        dashboard_screen.dart
        inventory_screen.dart
        box_detail_screen.dart
        qr_management_screen.dart
        jobs_list_screen.dart
        create_job_screen.dart
        clients_list_screen.dart
        client_detail_screen.dart
        fleet_screen.dart
        driver_detail_screen.dart
        notifications_screen.dart
        reports_screen.dart
        settings_screen.dart
      providers/
        dashboard_provider.dart
        inventory_provider.dart
        jobs_provider.dart
        clients_provider.dart
        fleet_provider.dart
      widgets/
        admin_shell.dart
        admin_sidebar.dart
        admin_top_bar.dart
    driver/
      screens/
        jobs_screen.dart
        job_detail_screen.dart
        scanner_screen.dart
        photo_capture_screen.dart
        sign_off_screen.dart
        shift_screen.dart
        account_screen.dart
        report_issue_screen.dart
      providers/
        driver_jobs_provider.dart
        scanner_provider.dart
        shift_provider.dart
      widgets/
        driver_shell.dart
    client/
      screens/
        dashboard_screen.dart
        storage_screen.dart
        unit_detail_screen.dart
        delivery_request_screen.dart
        subscription_screen.dart
        account_screen.dart
        notifications_screen.dart
      providers/
        client_storage_provider.dart
        client_jobs_provider.dart
        subscription_provider.dart
      widgets/
        client_shell.dart
  repositories/
    storage_unit_repository.dart
    job_repository.dart
    client_repository.dart
    user_repository.dart
    qr_repository.dart
    photo_repository.dart
    audit_repository.dart
    subscription_repository.dart
    shift_repository.dart
  routing/
    app_router.dart
  main.dart
```

---

## Dependencies (pubspec.yaml)

```yaml
dependencies:
  # State
  flutter_riverpod: ^2.5.1
  riverpod_annotation: ^2.3.5

  # Data / Serialisation
  freezed_annotation: ^2.4.1
  json_annotation: ^4.9.0

  # Firebase
  firebase_core: ^3.1.0
  firebase_auth: ^5.1.0
  cloud_firestore: ^5.1.0
  firebase_storage: ^12.1.0
  cloud_functions: ^5.0.4
  firebase_messaging: ^15.0.0

  # Navigation
  go_router: ^14.2.0

  # UI / Fonts
  google_fonts: ^6.2.1
  cached_network_image: ^3.3.1

  # QR
  qr_flutter: ^4.1.0
  mobile_scanner: ^5.1.1

  # PDF / Print
  pdf: ^3.11.0
  printing: ^5.13.0

  # Image
  image_picker: ^1.1.2
  image: ^4.1.7                 # compression

  # Signature
  signature: ^5.4.1

  # Charts
  fl_chart: ^0.68.0

  # Utilities
  intl: ^0.19.0
  uuid: ^4.4.2
  equatable: ^2.0.5
  url_launcher: ^6.3.0

dev_dependencies:
  build_runner: ^2.4.11
  freezed: ^2.5.2
  json_serializable: ^6.8.0
  riverpod_generator: ^2.4.0
  riverpod_lint: ^2.3.10
  custom_lint: ^0.6.4
```

---

## Model Pattern (Freezed)

All models use `freezed` for immutability and `json_serializable` for Firestore serialisation.

```dart
// storageunit.dart
import 'package:freezed_annotation/freezed_annotation.dart';
part 'storage_unit.freezed.dart';
part 'storage_unit.g.dart';

@freezed
class StorageUnit with _$StorageUnit {
  const factory StorageUnit({
    required String id,
    required String tenantId,
    required String clientId,
    required String qrCodeId,
    String? parentId,
    required UnitType type,
    required String label,
    String? description,
    required StorageStatus status,
    @Default([]) List<String> photoIds,
    @Default([]) List<String> tags,
    String? category,
    double? weight,
    String? jobId,
    String? warehouseLocationId,
    @Default(false) bool isDeleted,
    DateTime? deletedAt,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _StorageUnit;

  factory StorageUnit.fromJson(Map<String, dynamic> json) =>
      _$StorageUnitFromJson(json);

  factory StorageUnit.fromFirestore(DocumentSnapshot doc) =>
      StorageUnit.fromJson({...doc.data() as Map<String, dynamic>, 'id': doc.id});
}
```

---

## Repository Pattern

Repositories are the **only** place where Firestore or Firebase Storage is accessed.

```dart
// Abstract interface
abstract class StorageUnitRepository {
  Stream<List<StorageUnit>> watchUnits({required String tenantId, String? clientId, StorageStatus? status});
  Future<StorageUnit?> getUnit(String id);
  Future<void> createUnit(StorageUnit unit);
  Future<void> updateUnit(String id, Map<String, dynamic> fields);
  Future<void> updateStatus(String id, StorageStatus newStatus, {required String actorId});
  Future<void> softDelete(String id, {required String actorId});
}

// Firestore implementation
class FirestoreStorageUnitRepository implements StorageUnitRepository {
  final FirebaseFirestore _db;
  // Always filter by tenantId — never query without it
  // Always filter isDeleted == false in all queries
  // Use transactions for status changes (also write audit event)
}
```

---

## Provider Pattern (Riverpod)

Providers consume repositories — never Firebase directly.

```dart
@riverpod
class InventoryNotifier extends _$InventoryNotifier {
  @override
  FutureOr<List<StorageUnit>> build() async {
    final tenantId = ref.watch(currentTenantIdProvider);
    return ref.watch(storageUnitRepositoryProvider).watchUnits(tenantId: tenantId);
  }
}

// StreamProvider for real-time
@riverpod
Stream<List<StorageUnit>> inventoryStream(InventoryStreamRef ref, {String? clientId}) {
  final repo = ref.watch(storageUnitRepositoryProvider);
  final tenantId = ref.watch(currentTenantIdProvider);
  return repo.watchUnits(tenantId: tenantId, clientId: clientId);
}
```

---

## Responsive Layout Rule

Every screen must use `LayoutBuilder` at the top level:

```dart
class InventoryScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth > 900) {
        return const _InventoryDesktop();
      }
      return const _InventoryMobile();
    });
  }
}
```

Breakpoints:
- Mobile: < 600px
- Tablet: 600–900px
- Desktop: > 900px

---

## Error Handling

All repository methods throw `AppException` on failure:
```dart
class AppException implements Exception {
  final String code;
  final String message;
  final dynamic original;
}
```

In providers, use `AsyncValue` and handle `.error` state in the UI with a consistent error widget.

---

## Navigation Rules
- Use `go_router` for all navigation
- Never use `Navigator.push` directly
- Pass route parameters, not full objects (fetch from provider by ID)
- See `12_NAVIGATION.md` for full route table

---

## Code Generation
Run after changing any `@freezed` or `@riverpod` annotated file:
```bash
dart run build_runner build --delete-conflicting-outputs
```
