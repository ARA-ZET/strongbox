import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/enums/app_enums.dart';
import '../../../core/models/storage_unit.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/storage_unit_card.dart';
import '../providers/clients_providers.dart';
import '../providers/inventory_providers.dart';
import '../widgets/add_box_dialog.dart';

const _pageSize = 20;

/// All Inventory grid with client/status/type filters.
/// Design: admin_all_inventory/screen.png.
class AdminInventoryScreen extends ConsumerStatefulWidget {
  const AdminInventoryScreen({super.key});

  @override
  ConsumerState<AdminInventoryScreen> createState() =>
      _AdminInventoryScreenState();
}

class _AdminInventoryScreenState extends ConsumerState<AdminInventoryScreen> {
  int _visible = _pageSize;

  Future<void> _addBox() async {
    final clientFilter = ref.read(inventoryClientFilterProvider);
    final id = await AddBoxDialog.show(
      context,
      initialClientId: clientFilter == 'all' ? null : clientFilter,
    );
    if (id != null && mounted) context.go('/admin/inventory/$id');
  }

  @override
  Widget build(BuildContext context) {
    final units = ref.watch(filteredUnitsProvider);
    final total = ref.watch(allUnitsProvider).valueOrNull?.length ?? 0;
    final clientNames = ref.watch(clientNamesProvider);
    final textTheme = Theme.of(context).textTheme;

    return LayoutBuilder(builder: (context, constraints) {
      final desktop = constraints.maxWidth > 900;

      return SingleChildScrollView(
        padding: EdgeInsets.all(desktop ? 24 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Inventory', style: textTheme.displaySmall),
                      const SizedBox(height: 4),
                      Text(
                        'Managing $total active boxes in the ecosystem.',
                        style: textTheme.bodyMedium
                            ?.copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.navy,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(0, 48),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                  ),
                  onPressed: _addBox,
                  icon: const Icon(Icons.add, size: 20),
                  label: const Text('Add Box'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _FilterRow(onChanged: () => setState(() => _visible = _pageSize)),
            const SizedBox(height: 20),
            _buildGrid(units, clientNames, desktop),
          ],
        ),
      );
    });
  }

  Widget _buildGrid(
      List<StorageUnit> list, Map<String, String> clientNames, bool desktop) {
    final active =
        list.where((u) => u.status != StorageStatus.archived).toList();
    final visible = active.take(_visible).toList();

    return Column(
      children: [
        LayoutBuilder(builder: (context, constraints) {
          final columns = constraints.maxWidth > 1100
              ? 4
              : constraints.maxWidth > 700
                  ? 2
                  : 1;
          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              mainAxisSpacing: 20,
              crossAxisSpacing: 20,
              mainAxisExtent: 290,
            ),
            itemCount: visible.length + 1,
            itemBuilder: (context, index) {
              if (index == visible.length) {
                return _AddBoxGhostCard(onTap: _addBox);
              }
              final unit = visible[index];
              return _UnitGridCard(
                unit: unit,
                clientName: clientNames[unit.clientId],
              );
            },
          );
        }),
        if (active.length > _visible) ...[
          const SizedBox(height: 24),
          TextButton.icon(
            style: TextButton.styleFrom(
              backgroundColor: AppColors.surfaceContainer,
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999)),
            ),
            onPressed: () => setState(() => _visible += _pageSize),
            icon: const Icon(Icons.expand_more, size: 20),
            label: const Text('Load More Inventory'),
          ),
        ],
      ],
    );
  }
}

/// Grid card that resolves a unit's first photo URL before rendering.
class _UnitGridCard extends ConsumerWidget {
  const _UnitGridCard({required this.unit, this.clientName});

  final StorageUnit unit;
  final String? clientName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final photos = ref.watch(entityPhotosProvider(unit.id)).valueOrNull;
    final photoUrl =
        (photos != null && photos.isNotEmpty) ? photos.first.storageUrl : null;
    return StorageUnitCard(
      unit: unit,
      clientName: clientName,
      photoUrl: photoUrl,
      onTap: () => context.go('/admin/inventory/${unit.id}'),
    );
  }
}

/// Client dropdown + status pills + type dropdown.
class _FilterRow extends ConsumerWidget {
  const _FilterRow({required this.onChanged});

  /// Lets the parent reset its "visible rows" pagination.
  final VoidCallback onChanged;

  static const _statuses = [
    ('all', 'All Status'),
    ('inStorage', 'In Storage'),
    ('inTransit', 'In Transit'),
    ('pending', 'Pending'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clients = ref.watch(clientsProvider).valueOrNull ?? [];
    final clientFilter = ref.watch(inventoryClientFilterProvider);
    final statusFilter = ref.watch(inventoryStatusFilterProvider);
    final typeFilter = ref.watch(inventoryTypeFilterProvider);
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 200),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: clientFilter,
                borderRadius: BorderRadius.circular(8),
                items: [
                  const DropdownMenuItem(
                      value: 'all', child: Text('All Clients')),
                  for (final client in clients)
                    DropdownMenuItem(
                        value: client.id, child: Text(client.displayName)),
                ],
                onChanged: (value) {
                  if (value != null) {
                    ref
                        .read(inventoryClientFilterProvider.notifier)
                        .set(value);
                    onChanged();
                  }
                },
              ),
            ),
          ),
          for (final (value, label) in _statuses)
            ChoiceChip(
              label: Text(label),
              selected: statusFilter == value,
              showCheckmark: false,
              selectedColor: AppColors.navy,
              backgroundColor: AppColors.surfaceContainer,
              labelStyle: textTheme.labelLarge?.copyWith(
                color: statusFilter == value
                    ? Colors.white
                    : AppColors.textPrimary,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
                side: BorderSide.none,
              ),
              onSelected: (_) {
                ref.read(inventoryStatusFilterProvider.notifier).set(value);
                onChanged();
              },
            ),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: typeFilter,
              borderRadius: BorderRadius.circular(8),
              items: const [
                DropdownMenuItem(value: 'all', child: Text('All Types')),
                DropdownMenuItem(value: 'closed', child: Text('Closed Box')),
                DropdownMenuItem(value: 'open', child: Text('Open Box')),
              ],
              onChanged: (value) {
                if (value != null) {
                  ref.read(inventoryTypeFilterProvider.notifier).set(value);
                  onChanged();
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Dashed "Add New Box" card closing the grid.
class _AddBoxGhostCard extends StatelessWidget {
  const _AddBoxGhostCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.border,
            width: 1.5,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.amber.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add_box_outlined,
                  color: AppColors.amberDark, size: 28),
            ),
            const SizedBox(height: 12),
            Text('Add New Box',
                style: textTheme.titleMedium),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Quickly register a new container into the system.',
                textAlign: TextAlign.center,
                style: textTheme.bodySmall,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
