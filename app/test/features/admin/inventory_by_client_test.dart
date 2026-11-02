import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:strong_box/core/enums/app_enums.dart';
import 'package:strong_box/core/models/storage_unit.dart';
import 'package:strong_box/features/admin/providers/clients_providers.dart';
import 'package:strong_box/features/admin/providers/inventory_providers.dart';

StorageUnit _unit(
  String id,
  String clientId, {
  StorageStatus status = StorageStatus.inStorage,
}) => StorageUnit(
  id: id,
  tenantId: 'strongbox-default',
  clientId: clientId,
  status: status,
);

void main() {
  test('inventory is grouped by customer, A–Z, unknown clients last', () {
    final container = ProviderContainer(
      overrides: [
        allUnitsProvider.overrideWith(
          (ref) => Stream.value([
            _unit('u1', 'zoe'),
            _unit('u2', 'gone'),
            _unit('u3', 'amir'),
            _unit('u4', 'zoe', status: StorageStatus.pendingPickup),
            _unit('u5', 'amir', status: StorageStatus.archived),
          ]),
        ),
        clientNamesProvider.overrideWithValue({
          'zoe': 'Zoe Mokoena',
          'amir': 'amir Patel',
        }),
      ],
    );
    addTearDown(container.dispose);
    container.listen(allUnitsProvider, (_, _) {});

    return Future<void>.delayed(Duration.zero, () {
      final groups = container.read(inventoryByClientProvider);
      expect(groups.map((g) => g.clientName), [
        'amir Patel',
        'Zoe Mokoena',
        '',
      ]);
      expect(groups.map((g) => g.units.map((u) => u.id).toList()), [
        ['u3'], // archived u5 left out
        ['u1', 'u4'],
        ['u2'],
      ]);
    });
  });

  test('filters still apply inside the groups', () async {
    final container = ProviderContainer(
      overrides: [
        allUnitsProvider.overrideWith(
          (ref) => Stream.value([
            _unit('u1', 'zoe'),
            _unit('u4', 'zoe', status: StorageStatus.pendingPickup),
          ]),
        ),
        clientNamesProvider.overrideWithValue({'zoe': 'Zoe Mokoena'}),
      ],
    );
    addTearDown(container.dispose);
    container.listen(allUnitsProvider, (_, _) {});
    await Future<void>.delayed(Duration.zero);

    container.read(inventoryStatusFilterProvider.notifier).set('pending');
    final groups = container.read(inventoryByClientProvider);
    expect(groups.single.units.map((u) => u.id), ['u4']);
  });
}
