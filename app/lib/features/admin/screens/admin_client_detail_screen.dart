import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/initials_avatar.dart';
import '../../../core/widgets/status_chip.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/enums/app_enums.dart';
import '../../../core/models/storage_unit.dart';
import '../../../core/models/client.dart';
import '../../../core/models/job.dart';
import '../providers/clients_providers.dart';
import '../widgets/client_form_dialog.dart';

/// Single client view: profile header, subscription + insight, stored
/// inventory grid, job history. Design: admin_client_detail/screen.png.
class AdminClientDetailScreen extends ConsumerWidget {
  const AdminClientDetailScreen({super.key, required this.clientId});

  final String clientId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final client = ref.watch(clientByIdProvider(clientId));
    final textTheme = Theme.of(context).textTheme;

    return client.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
        child: Text('Could not load client: $error',
            style:
                textTheme.bodyMedium?.copyWith(color: AppColors.statusError)),
      ),
      data: (model) {
        if (model == null) {
          return Center(
            child: Text('Client not found.', style: textTheme.titleMedium),
          );
        }
        return _ClientDetailBody(client: model);
      },
    );
  }
}

class _ClientDetailBody extends ConsumerWidget {
  const _ClientDetailBody({required this.client});

  final Client client;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return LayoutBuilder(builder: (context, constraints) {
      final desktop = constraints.maxWidth > 900;

      return SingleChildScrollView(
        padding: EdgeInsets.all(desktop ? 24 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Breadcrumb(name: client.displayName),
            const SizedBox(height: 16),
            _HeaderCard(client: client, desktop: desktop),
            const SizedBox(height: 24),
            if (desktop)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 35,
                    child: Column(
                      children: [
                        _SubscriptionCard(client: client),
                        const SizedBox(height: 24),
                        _InsightCard(insight: client.notes),
                      ],
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                      flex: 65,
                      child: _StoredInventoryCard(clientId: client.id)),
                ],
              )
            else ...[
              _SubscriptionCard(client: client),
              const SizedBox(height: 24),
              _InsightCard(insight: client.notes),
              const SizedBox(height: 24),
              _StoredInventoryCard(clientId: client.id),
            ],
            const SizedBox(height: 24),
            _JobHistoryCard(clientId: client.id),
          ],
        ),
      );
    });
  }
}

// -------------------------------------------------------------- breadcrumb

class _Breadcrumb extends StatelessWidget {
  const _Breadcrumb({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back, size: 20),
          onPressed: () => context.go('/admin/clients'),
        ),
        const SizedBox(width: 4),
        Flexible(
          child: Text.rich(
            TextSpan(
              style: textTheme.bodyMedium
                  ?.copyWith(color: AppColors.textSecondary),
              children: [
                const TextSpan(text: 'Clients / '),
                TextSpan(
                  text: name,
                  style: textTheme.bodyMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

// ------------------------------------------------------------- header card

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({required this.client, required this.desktop});

  final Client client;
  final bool desktop;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    final identity = Row(
      children: [
        Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.amber, width: 2.5),
          ),
          child: InitialsAvatar(name: client.displayName, size: 72),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(client.displayName, style: textTheme.headlineSmall),
              const SizedBox(height: 8),
              Wrap(
                spacing: 16,
                runSpacing: 4,
                children: [
                  _contactRow(Icons.mail_outline, client.email, textTheme),
                  _contactRow(Icons.phone_outlined, client.phone, textTheme),
                  _contactRow(
                      Icons.location_on_outlined, client.address.line1, textTheme),
                ],
              ),
            ],
          ),
        ),
      ],
    );

    final actions = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(0, 44),
            padding: const EdgeInsets.symmetric(horizontal: 16),
          ),
          onPressed: () => ClientFormDialog.show(context, existing: client),
          icon: const Icon(Icons.edit_outlined, size: 18),
          label: const Text('Edit Profile'),
        ),
        const SizedBox(width: 12),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(0, 44),
            padding: const EdgeInsets.symmetric(horizontal: 16),
          ),
          onPressed: () => context.go('/admin/jobs/new'),
          icon: const Icon(Icons.add_box_outlined, size: 18),
          label: const Text('New Job'),
        ),
      ],
    );

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [AppTheme.cardShadow],
      ),
      child: desktop
          ? Row(children: [Expanded(child: identity), actions])
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [identity, const SizedBox(height: 16), actions],
            ),
    );
  }

  Widget _contactRow(IconData icon, String value, TextTheme textTheme) {
    if (value.isEmpty) return const SizedBox.shrink();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 6),
        Text(value,
            style: textTheme.bodyMedium
                ?.copyWith(color: AppColors.textSecondary)),
      ],
    );
  }
}

// ------------------------------------------------------- subscription card

class _SubscriptionCard extends ConsumerWidget {
  const _SubscriptionCard({required this.client});

  final Client client;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final used = client.storageUnitCount;
    final limit = AppConstants.planUnitLimits[client.subscriptionPlan.name] ?? 0;
    final fraction = limit > 0 ? (used / limit).clamp(0.0, 1.0) : 0.0;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [AppTheme.cardShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Subscription', style: textTheme.titleMedium),
              StatusChip(status: client.subscriptionStatus.name),
            ],
          ),
          const SizedBox(height: 20),
          Text('CURRENT PLAN',
              style: textTheme.bodySmall?.copyWith(letterSpacing: 0.8)),
          const SizedBox(height: 4),
          Text(client.subscriptionPlan.label, style: textTheme.headlineSmall),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _fieldColumn(
                  'Status',
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.statusSuccess,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text('Billed Monthly', style: textTheme.bodyMedium),
                    ],
                  ),
                  textTheme,
                ),
              ),
              Expanded(
                child: _fieldColumn(
                  'Renewal Date',
                  Text(
                    '—',
                    style: textTheme.bodyMedium,
                  ),
                  textTheme,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Storage Capacity', style: textTheme.labelLarge),
              Text(
                limit > 0 ? '${(fraction * 100).round()}%' : '—',
                style: textTheme.labelLarge,
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: fraction,
              minHeight: 8,
              backgroundColor: AppColors.surfaceContainer,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.amber),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            limit > 0
                ? '$used of $limit units used'
                : '$used units in storage',
            style: textTheme.bodySmall,
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.navy,
                foregroundColor: Colors.white,
              ),
              // Stripe portal link is wired in Stage 7.
              onPressed: client.stripeCustomerId == null
                  ? () => ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text(
                                'Billing portal is wired up in Stage 7')),
                      )
                  : () {},
              child: const Text('Manage Billing'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _fieldColumn(String label, Widget value, TextTheme textTheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: textTheme.bodySmall),
        const SizedBox(height: 4),
        value,
      ],
    );
  }
}

// ------------------------------------------------------------ insight card

class _InsightCard extends StatelessWidget {
  const _InsightCard({required this.insight});

  final String? insight;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.navy,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.insights, color: AppColors.amber, size: 22),
              const SizedBox(width: 10),
              Text(
                'Logistics Insight',
                style: textTheme.titleMedium
                    ?.copyWith(color: AppColors.amber),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            insight ??
                'No insight recorded for this client yet. Notes added by '
                    'operations will appear here.',
            style: textTheme.bodyMedium
                ?.copyWith(color: Colors.white.withValues(alpha: 0.8)),
          ),
        ],
      ),
    );
  }
}

// -------------------------------------------------- stored inventory card

class _StoredInventoryCard extends ConsumerStatefulWidget {
  const _StoredInventoryCard({required this.clientId});

  final String clientId;

  @override
  ConsumerState<_StoredInventoryCard> createState() =>
      _StoredInventoryCardState();
}

class _StoredInventoryCardState extends ConsumerState<_StoredInventoryCard> {
  String _filter = '';

  @override
  Widget build(BuildContext context) {
    final boxes = ref.watch(clientUnitsProvider(widget.clientId));
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [AppTheme.cardShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Stored Inventory', style: textTheme.titleMedium),
                    Text('Active boxes under custody',
                        style: textTheme.bodySmall),
                  ],
                ),
              ),
              SizedBox(
                width: 200,
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: 'Filter boxes...',
                    prefixIcon: Icon(Icons.search,
                        size: 18, color: AppColors.textSecondary),
                    isDense: true,
                  ),
                  onChanged: (value) =>
                      setState(() => _filter = value.toLowerCase()),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          boxes.when(
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: CircularProgressIndicator(),
              ),
            ),
            error: (error, _) => Text('Could not load boxes: $error',
                style: textTheme.bodyMedium
                    ?.copyWith(color: AppColors.statusError)),
            data: (list) => _buildGrid(list, textTheme),
          ),
        ],
      ),
    );
  }

  Widget _buildGrid(List<StorageUnit> all, TextTheme textTheme) {
    final list = _filter.isEmpty
        ? all
        : all
            .where((box) =>
                box.qrCodeId.toLowerCase().contains(_filter) ||
                box.label.toLowerCase().contains(_filter))
            .toList();

    if (list.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          all.isEmpty
              ? 'No boxes in custody for this client yet.'
              : 'No boxes match the filter.',
          style:
              textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
        ),
      );
    }

    final visible = list.take(6).toList();

    return Column(
      children: [
        LayoutBuilder(builder: (context, constraints) {
          final columns = constraints.maxWidth > 640 ? 3 : 2;
          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.95,
            ),
            itemCount: visible.length,
            itemBuilder: (context, index) =>
                _MiniBoxCard(box: visible[index]),
          );
        }),
        if (list.length > visible.length) ...[
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => context.go('/admin/inventory'),
            child: Text('View All ${list.length} Boxes'),
          ),
        ],
      ],
    );
  }
}

class _MiniBoxCard extends StatelessWidget {
  const _MiniBoxCard({required this.box});

  final StorageUnit box;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => context.go('/admin/inventory/${box.id}'),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(12)),
                child: Container(
                  width: double.infinity,
                  color: AppColors.border.withValues(alpha: 0.4),
                  child: const Icon(Icons.inventory_2_outlined,
                      size: 36, color: AppColors.textSecondary),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          box.qrCodeId.isEmpty ? box.id : box.qrCodeId,
                          style: textTheme.bodyMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Icon(Icons.arrow_forward,
                          size: 16, color: AppColors.textSecondary),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    box.label.isEmpty ? 'Unlabelled' : box.label,
                    style: textTheme.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  StatusChip(status: box.status.name),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --------------------------------------------------------- job history card

class _JobHistoryCard extends ConsumerWidget {
  const _JobHistoryCard({required this.clientId});

  final String clientId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jobs = ref.watch(clientJobsProvider(clientId));
    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [AppTheme.cardShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                    child:
                        Text('Job History', style: textTheme.headlineSmall)),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.navy,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(0, 40),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  onPressed: () => context.go('/admin/jobs'),
                  child: const Text('View All Jobs'),
                ),
              ],
            ),
          ),
          jobs.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(32),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (error, _) => Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Text('Could not load jobs: $error',
                  style: textTheme.bodyMedium
                      ?.copyWith(color: AppColors.statusError)),
            ),
            data: (list) => list.isEmpty
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                    child: Text('No jobs recorded for this client yet.',
                        style: textTheme.bodyMedium
                            ?.copyWith(color: AppColors.textSecondary)),
                  )
                : _buildTable(context, list, textTheme),
          ),
        ],
      ),
    );
  }

  Widget _buildTable(
      BuildContext context, List<Job> jobs, TextTheme textTheme) {
    Widget headerCell(String label, {required int flex}) => Expanded(
          flex: flex,
          child: Text(label,
              style: textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600, letterSpacing: 0.5)),
        );

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 640),
        child: Column(
          children: [
            Container(
              color: AppColors.surfaceContainer,
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  headerCell('REFERENCE', flex: 2),
                  headerCell('SERVICE TYPE', flex: 3),
                  headerCell('STATUS', flex: 2),
                  headerCell('DATE', flex: 2),
                  headerCell('BOXES', flex: 1),
                ],
              ),
            ),
            for (final job in jobs)
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        '#JOB-${job.id.substring(0, job.id.length.clamp(0, 5)).toUpperCase()}',
                        style: textTheme.bodyMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Row(
                        children: [
                          Icon(
                            job.type == JobType.pickup
                                ? Icons.archive_outlined
                                : Icons.local_shipping_outlined,
                            size: 18,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            job.type == JobType.pickup
                                ? 'Pickup Service'
                                : 'Delivery Service',
                            style: textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: StatusChip(status: job.status.name),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        job.scheduledDate == null ? '' : DateFormat('MMM d, y').format(job.scheduledDate!),
                        style: textTheme.bodyMedium,
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text('${job.storageUnitIds.length}',
                          style: textTheme.bodyMedium),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
