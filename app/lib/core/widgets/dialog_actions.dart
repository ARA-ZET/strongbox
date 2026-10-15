import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// Cancel + primary action row for the bottom of a custom [Dialog].
///
/// The app theme makes elevated buttons full-width (infinite minimum
/// width), which cannot lay out inside a Row — the whole row disappears.
/// This gives the primary button a normal width; use it instead of a
/// hand-built Row of buttons.
class DialogActions extends StatelessWidget {
  const DialogActions({
    super.key,
    required this.saveLabel,
    required this.onSave,
    this.saving = false,
    this.onCancel,
  });

  final String saveLabel;
  final VoidCallback onSave;

  /// Shows a spinner on the primary button and disables both.
  final bool saving;

  /// Defaults to closing the dialog.
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: saving
              ? null
              : onCancel ?? () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        const SizedBox(width: AppSpacing.sm + 4),
        ElevatedButton(
          style: ElevatedButton.styleFrom(minimumSize: const Size(96, 48)),
          onPressed: saving ? null : onSave,
          child: saving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.accentDeep,
                  ),
                )
              : Text(saveLabel),
        ),
      ],
    );
  }
}
