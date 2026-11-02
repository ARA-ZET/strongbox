import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/enums/app_enums.dart';
import '../../../core/models/storage_unit.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_shadow.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/public_ref.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/label_print_dialog.dart';
import '../../../core/widgets/storage_unit_card.dart';
import '../providers/clients_providers.dart';
import '../providers/inventory_providers.dart';
import '../widgets/add_box_dialog.dart';

/// All Inventory, grouped by customer (A–Z), with client/status/type
/// filters. Design: admin_all_inventory/screen.png.
class AdminInventoryScreen extends ConsumerStatefulWidget {
  const AdminInventoryScreen({super.key});

  @override
  ConsumerState<AdminInventoryScreen> createState() =>
      _AdminInventoryScreenState();
}

class _AdminInventoryScreenState extends ConsumerState<AdminInventoryScreen> {
  Future<void> _addBox({String? clientId}) async {
    final clientFilter = ref.read(inventoryClientFilterProvider);
    final id = await AddBoxDialog.show(
      context,
      initialClientId:
          clientId ?? (clientFilter == 'all' ? null : clientFilter),
    );
    if (id != null && mounted) context.go('/admin/inventory/$id');
  }

  @override
  Widget build(BuildContext context) {
    final groups = ref.watch(inventoryByClientProvider);
    final total = ref.watch(allUnitsProvider).valueOrNull?.length ?? 0;
    final textTheme = Theme.of(context).textTheme;

    return LayoutBuilder(builder: (context, constraints) {
      final desktop = constraints.maxWidth > 900;

      return SingleChildScrollView(
        padding: EdgeInsets.all(desktop ? 24 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Buttons drop under the title on narrow screens.
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.end,
              spacing: AppSpacing.md,
              runSpacing: AppSpacing.sm + 4,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Inventory', style: textTheme.displaySmall),
                    const SizedBox(height: 4),
                    Text(
                      'Managing $total units, grouped by customer.',
                      style: textTheme.bodyMedium
                          ?.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
                Wrap(
                  spacing: AppSpacing.sm + 4,
                  runSpacing: AppSpacing.sm,
                  children: [
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 48),
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                      ),
                      // Everything the filters show, grouped by client.
                      onPressed: () => LabelPrintDialog.show(
                        context,
                        units: [for (final g in groups) ...g.units],
                        groupNames: ref.read(clientNamesProvider),
                      ),
                      icon: const Icon(Icons.print_outlined, size: 20),
                      label: const Text('Print labels'),
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
              ],
            ),
            const SizedBox(height: 20),
            const _FilterRow(),
            const SizedBox(height: 20),
            _buildGroups(groups),
          ],
        ),
      );
    });
  }

  Widget _buildGroups(List<ClientInventory> groups) {
    if (groups.isEmpty) {
      return const EmptyState(
        icon: Icons.inventory_2_outlined,
        title: 'No units match these filters',
        subtitle: 'Try a different client, status or type.',
      );
    }
    return Column(
      children: [
        for (final group in groups)
          _ClientSection(
            key: ValueKey(group.clientId),
            group: group,
            onAddBox: () => _addBox(clientId: group.clientId),
          ),
      ],
    );
  }
}

/// One customer's units: header with name, account number, counts and
/// actions; collapsible; first [_preview] cards until "Show all".
class _ClientSection extends StatefulWidget {
  const _ClientSection({
    super.key,
    required this.group,
    required this.onAddBox,
  });

  final ClientInventory group;
  final VoidCallback onAddBox;

  @override
  State<_ClientSection> createState() => _ClientSectionState();
}

class _ClientSectionState extends State<_ClientSection> {
  static const _preview = 8;
  bool _open = true;
  bool _all = false;

  @override
  Widget build(BuildContext context) {
    final group = widget.group;
    final units = group.units;
    final textTheme = Theme.of(context).textTheme;
    final awaiting =
        units.where((u) => u.status == StorageStatus.pendingPickup).length;
    final labelled = units.where((u) => u.qrCodeId.isNotEmpty).toList();
    final shown = _all ? units : units.take(_preview).toList();
    final complete = shown.length == units.length;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.md,
        boxShadow: AppShadow.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.sm, AppSpacing.sm, AppSpacing.md, AppSpacing.sm),
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              runSpacing: AppSpacing.xs,
              children: [
                InkWell(
                  borderRadius: AppRadius.sm,
                  onTap: () => setState(() => _open = !_open),
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(_open ? Icons.expand_less : Icons.expand_more,
                            color: AppColors.textSecondary),
                        const SizedBox(width: AppSpacing.sm),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                group.clientName.isEmpty
                                    ? 'Unknown client'
                                    : group.clientName,
                                style: textTheme.titleMedium),
                            Text(
                              [
                                'Account ${clientRef(group.clientId)}',
                                '${units.length} '
                                    '${units.length == 1 ? 'unit' : 'units'}',
                                if (awaiting > 0) '$awaiting awaiting pickup',
                              ].join(' · '),
                              style: textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Wrap(
                  spacing: AppSpacing.xs,
                  children: [
                    if (labelled.isNotEmpty)
                      TextButton.icon(
                        onPressed: () => LabelPrintDialog.show(context,
                            units: units,
                            preselected: {for (final u in labelled) u.id}),
                        icon: const Icon(Icons.print_outlined, size: 18),
                        label: const Text('Print labels'),
                      ),
                    if (group.clientName.isNotEmpty)
                      TextButton(
                        onPressed: () =>
                            context.go('/admin/clients/${group.clientId}'),
                        child: const Text('View client'),
                      ),
                  ],
                ),
              ],
            ),
          ),
          if (_open)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md, 0, AppSpacing.md, AppSpacing.md),
              child: Column(
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
                      itemCount: shown.length + (complete ? 1 : 0),
                      itemBuilder: (context, index) => index == shown.length
                          ? _AddBoxGhostCard(onTap: widget.onAddBox)
                          : _UnitGridCard(unit: shown[index]),
                    );
                  }),
                  if (!complete) ...[
                    const SizedBox(height: AppSpacing.md),
                    TextButton.icon(
                      onPressed: () => setState(() => _all = true),
                      icon: const Icon(Icons.expand_more, size: 20),
                      label: Text('Show all ${units.length}'),
                    ),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// Grid card that resolves a unit's first photo URL before rendering.
class _UnitGridCard extends ConsumerWidget {
  const _UnitGridCard({required this.unit});

  final StorageUnit unit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final photos = ref.watch(entityPhotosProvider(unit.id)).valueOrNull;
    final photoUrl =
        (photos != null && photos.isNotEmpty) ? photos.first.storageUrl : null;
    return StorageUnitCard(
      unit: unit,
      photoUrl: photoUrl,
      onTap: () => context.go('/admin/inventory/${unit.id}'),
    );
  }
}

/// Client dropdown + status pills + type dropdown.
class _FilterRow extends ConsumerWidget {
  const _FilterRow();

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
                color: AppColors.accent.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add_box_outlined,
                  color: AppColors.accentDeep, size: 28),
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
