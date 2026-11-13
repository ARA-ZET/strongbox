import 'package:flutter/material.dart';

import '../enums/app_enums.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../utils/account_closure.dart';

/// What has to happen before an account can close: one line per check,
/// ticked when done, with what's left to do when not. Worded for the
/// client ([forClient]) or an admin.
class ClosureChecklist extends StatelessWidget {
  const ClosureChecklist({
    super.key,
    required this.blockers,
    required this.forClient,
  });

  /// From [closureBlockers] — empty when everything is done.
  final List<ClosureBlocker> blockers;
  final bool forClient;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final byKind = {for (final b in blockers) b.kind: b};

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final kind in ClosureBlockerKind.values)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  byKind[kind] == null
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked,
                  size: 20,
                  color: byKind[kind] == null
                      ? AppColors.statusSuccess
                      : AppColors.statusPastDue,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(closureCheckLabel(kind), style: tt.labelLarge),
                      if (byKind[kind] != null)
                        Text(
                          closureBlockerText(
                            byKind[kind]!,
                            forClient: forClient,
                          ),
                          style: tt.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
