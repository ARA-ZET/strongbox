import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../enums/app_enums.dart';
import '../models/storage_unit.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_shadow.dart';
import '../theme/app_spacing.dart';
import 'status_chip.dart';

/// Inventory grid card for a [StorageUnit] (doc 11) — replaces the old
/// BoxCard. Photo URL is resolved by the parent (units store photoIds).
class StorageUnitCard extends StatelessWidget {
  const StorageUnitCard({
    super.key,
    required this.unit,
    required this.onTap,
    this.clientName,
    this.photoUrl,
  });

  final StorageUnit unit;
  final VoidCallback onTap;
  final String? clientName;
  final String? photoUrl;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isClosed = unit.type == UnitType.closed;

    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.md,
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadius.md,
          boxShadow: AppShadow.card,
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                SizedBox(
                  height: 150,
                  width: double.infinity,
                  child: photoUrl == null || photoUrl!.isEmpty
                      ? const _PhotoPlaceholder()
                      : CachedNetworkImage(
                          imageUrl: photoUrl!,
                          fit: BoxFit.cover,
                          placeholder: (_, _) => const ColoredBox(
                              color: AppColors.surfaceContainer),
                          errorWidget: (_, _, _) => const _PhotoPlaceholder(),
                        ),
                ),
                Positioned(
                  top: AppSpacing.sm,
                  left: AppSpacing.sm,
                  child: StatusChip(status: unit.status.name),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.sm + 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    unit.label.isNotEmpty ? unit.label : unit.qrCodeId,
                    style: textTheme.labelLarge
                        ?.copyWith(fontWeight: FontWeight.w700),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (clientName != null) ...[
                    const SizedBox(height: 2),
                    Text(clientName!,
                        style: textTheme.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                  ],
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: isClosed
                              ? AppColors.statusPendingBg
                              : AppColors.statusWarningBg,
                          borderRadius: AppRadius.pill,
                        ),
                        child: Text(
                          isClosed ? 'CLOSED' : 'OPEN',
                          style: textTheme.bodySmall?.copyWith(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: isClosed
                                ? AppColors.textSecondary
                                : AppColors.amberDark,
                          ),
                        ),
                      ),
                      const Spacer(),
                      if (unit.updatedAt != null)
                        Text(DateFormat.yMMMd().format(unit.updatedAt!),
                            style: textTheme.bodySmall),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PhotoPlaceholder extends StatelessWidget {
  const _PhotoPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: AppColors.surfaceContainer,
      child: Center(
        child: Icon(Icons.inventory_2_outlined,
            size: 40, color: AppColors.border),
      ),
    );
  }
}
