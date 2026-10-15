import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/report_failure.dart';
import '../../../core/widgets/app_search_bar.dart';
import '../../../core/widgets/initials_avatar.dart';
import '../../../core/enums/app_enums.dart';
import '../../../core/models/client.dart';
import '../../../core/widgets/status_chip.dart';
import '../providers/clients_providers.dart';
import '../widgets/client_form_dialog.dart';
import '../../../core/widgets/table_scroll.dart';

const _pageSize = 10;

/// Client Directory. Design: admin_clients_list/screen.png.
class AdminClientsScreen extends ConsumerStatefulWidget {
  const AdminClientsScreen({super.key});

  @override
  ConsumerState<AdminClientsScreen> createState() =>
      _AdminClientsScreenState();
}

class _AdminClientsScreenState extends ConsumerState<AdminClientsScreen> {
  int _page = 0;

  Future<void> _addClient() async {
    final id = await ClientFormDialog.show(context);
    if (id != null && mounted) context.go('/admin/clients/$id');
  }

  @override
  Widget build(BuildContext context) {
    final clients = ref.watch(filteredClientsProvider);
    final total = ref.watch(clientsProvider).valueOrNull?.length ?? 0;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.accent,
        foregroundColor: AppColors.onAccent,
        onPressed: _addClient,
        child: const Icon(Icons.add),
      ),
      body: LayoutBuilder(builder: (context, constraints) {
        final desktop = constraints.maxWidth > 900;

        return SingleChildScrollView(
          padding: EdgeInsets.all(desktop ? 24 : 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(textTheme, total, desktop),
              const SizedBox(height: 16),
              AppSearchBar(
                hint: 'Search clients by name, email or ID...',
                onChanged: (value) {
                  ref.read(clientSearchQueryProvider.notifier).set(value);
                  setState(() => _page = 0);
                },
              ),
              const SizedBox(height: 16),
              _buildTable(clients, textTheme),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildHeader(TextTheme textTheme, int total, bool desktop) {
    final filter = ref.watch(clientStatusFilterProvider);

    final title = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Client Directory', style: textTheme.displaySmall),
        const SizedBox(height: 4),
        Text(
          'Manage relationships and storage subscriptions for $total clients.',
          style:
              textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );

    final actions = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.border),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: filter,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              borderRadius: BorderRadius.circular(8),
              items: const [
                DropdownMenuItem(value: 'all', child: Text('All Clients')),
                DropdownMenuItem(value: 'active', child: Text('Active')),
                DropdownMenuItem(value: 'pastDue', child: Text('Past Due')),
                DropdownMenuItem(
                    value: 'cancelled', child: Text('Cancelled')),
              ],
              onChanged: (value) {
                if (value != null) {
                  ref.read(clientStatusFilterProvider.notifier).set(value);
                  setState(() => _page = 0);
                }
              },
            ),
          ),
        ),
        const SizedBox(width: 12),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.navy,
            foregroundColor: Colors.white,
            minimumSize: const Size(0, 44),
            padding: const EdgeInsets.symmetric(horizontal: 16),
          ),
          // CSV export ships with the reports module in Stage 4.
          onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Export arrives in Stage 4')),
          ),
          icon: const Icon(Icons.download, size: 18),
          label: const Text('Export'),
        ),
      ],
    );

    if (desktop) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [Expanded(child: title), actions],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [title, const SizedBox(height: 12), actions],
    );
  }

  Widget _buildTable(List<Client> list, TextTheme textTheme) {
    if (list.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(48),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [AppTheme.cardShadow],
        ),
        child: Column(
          children: [
            const Icon(Icons.group_outlined,
                size: 48, color: AppColors.border),
            const SizedBox(height: 12),
            Text('No clients match your filters.',
                style: textTheme.bodyMedium
                    ?.copyWith(color: AppColors.textSecondary)),
          ],
        ),
      );
    }

    final pageCount = (list.length / _pageSize).ceil();
    final page = _page.clamp(0, pageCount - 1);
    final start = page * _pageSize;
    final visible = list.skip(start).take(_pageSize).toList();

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [AppTheme.cardShadow],
      ),
      child: Column(
        children: [
          TableScroll(
  minWidth: 760,
  child: Column(
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      color: AppColors.surfaceContainer,
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(12)),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    child: Row(
                      children: [
                        _headerCell('CLIENT', flex: 3),
                        _headerCell('CONTACT INFO', flex: 3),
                        _headerCell('BOXES STORED', flex: 2),
                        _headerCell('STATUS', flex: 2),
                        const SizedBox(width: 48),
                      ],
                    ),
                  ),
                  for (final client in visible) _ClientRow(client: client),
                ],
              ),
),
          _buildPagination(list.length, page, pageCount, start, textTheme),
        ],
      ),
    );
  }

  Widget _headerCell(String label, {required int flex}) {
    return Expanded(
      flex: flex,
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
      ),
    );
  }

  Widget _buildPagination(
      int total, int page, int pageCount, int start, TextTheme textTheme) {
    final end = (start + _pageSize).clamp(0, total);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: const BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Showing ${start + 1}-$end of $total clients',
              style: textTheme.bodySmall,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_left, size: 20),
            onPressed:
                page > 0 ? () => setState(() => _page = page - 1) : null,
          ),
          Text('${page + 1} / $pageCount', style: textTheme.bodySmall),
          IconButton(
            icon: const Icon(Icons.chevron_right, size: 20),
            onPressed: page < pageCount - 1
                ? () => setState(() => _page = page + 1)
                : null,
          ),
        ],
      ),
    );
  }
}

class _ClientRow extends ConsumerStatefulWidget {
  const _ClientRow({required this.client});

  final Client client;

  @override
  ConsumerState<_ClientRow> createState() => _ClientRowState();
}

class _ClientRowState extends ConsumerState<_ClientRow> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final client = widget.client;
    final textTheme = Theme.of(context).textTheme;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: InkWell(
        onTap: () => context.go('/admin/clients/${client.id}'),
        child: Container(
          color: _hovered ? AppColors.surfaceContainer : Colors.transparent,
          padding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Row(
                  children: [
                    InitialsAvatar(name: client.displayName, size: 40),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(client.displayName,
                              style: textTheme.bodyMedium
                                  ?.copyWith(fontWeight: FontWeight.w600),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                          Text('ID: ${client.id.substring(0, client.id.length.clamp(0, 6))}',
                              style: textTheme.bodySmall),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(client.email,
                        style: textTheme.bodyMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    Text(client.phone, style: textTheme.bodySmall),
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainer,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text('${client.storageUnitCount}',
                        style: textTheme.bodyMedium
                            ?.copyWith(fontWeight: FontWeight.w600)),
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: StatusChip(status: client.subscriptionStatus.name),
                ),
              ),
              SizedBox(
                width: 48,
                child: PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert,
                      color: AppColors.textSecondary),
                  onSelected: (action) => _handleAction(action, client),
                  itemBuilder: (_) => const [
                    PopupMenuItem(
                        value: 'view', child: Text('View Details')),
                    PopupMenuItem(value: 'edit', child: Text('Edit')),
                    PopupMenuItem(
                        value: 'deactivate', child: Text('Deactivate')),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleAction(String action, Client client) async {
    switch (action) {
      case 'view':
        context.go('/admin/clients/${client.id}');
      case 'edit':
        await ClientFormDialog.show(context, existing: client);
      case 'deactivate':
        await reportFailure(context, 'Could not deactivate client', () => ref
            .read(clientMutationsProvider.notifier)
            .updateClient(client.id, status: SubscriptionStatus.cancelled));
    }
  }
}
