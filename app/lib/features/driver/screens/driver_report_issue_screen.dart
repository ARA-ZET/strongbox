import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/photo_upload_zone.dart';
import '../../../core/enums/app_enums.dart';
import '../providers/issue_report_providers.dart';

/// Maintenance & support report form. Design:
/// driver_report_issue_maintenance/screen.png.
class DriverReportIssueScreen extends ConsumerStatefulWidget {
  const DriverReportIssueScreen({super.key});

  @override
  ConsumerState<DriverReportIssueScreen> createState() =>
      _DriverReportIssueScreenState();
}

class _DriverReportIssueScreenState
    extends ConsumerState<DriverReportIssueScreen> {
  final _description = TextEditingController();
  IssueType? _category;
  bool _urgent = false;
  List<Uint8List> _photos = [];
  bool _submitting = false;

  static const _categories = [
    (IssueType.vehicleBreakdown, 'Vehicle Breakdown'),
    (IssueType.cargoDamage, 'Cargo Damage'),
    (IssueType.deliveryFailed, 'Delivery Failed'),
    (IssueType.safetyConcern, 'Safety Concern'),
    (IssueType.other, 'Other'),
  ];

  @override
  void dispose() {
    _description.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_category == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select an issue category')),
      );
      return;
    }
    setState(() => _submitting = true);
    try {
      await ref.read(issueReportActionsProvider.notifier).submit(
            issueType: _category!,
            description: _description.text.trim(),
            isUrgent: _urgent,
            photos: _photos,
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Report submitted')),
        );
        context.go('/driver/account');
      }
    } catch (error) {
      if (mounted) {
        setState(() => _submitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not submit report: $error')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.scaffold,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/driver/account'),
        ),
        title: const Text('Report Issue'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('MAINTENANCE & SUPPORT',
              style: tt.bodySmall
                  ?.copyWith(fontWeight: FontWeight.w700, letterSpacing: 0.5)),
          const SizedBox(height: 4),
          Text(
            'Submit clear details to ensure a rapid dispatch of support or '
            'maintenance teams.',
            style: tt.bodyMedium?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 20),
          Text('Issue Type', style: tt.labelLarge),
          const SizedBox(height: 8),
          DropdownButtonFormField<IssueType>(
            initialValue: _category,
            hint: const Text('Select an issue category…'),
            items: [
              for (final (value, label) in _categories)
                DropdownMenuItem(value: value, child: Text(label)),
            ],
            onChanged: (value) => setState(() => _category = value),
          ),
          const SizedBox(height: 16),
          Text('Description of Issue', style: tt.labelLarge),
          const SizedBox(height: 8),
          TextField(
            controller: _description,
            maxLines: 5,
            decoration: const InputDecoration(
                hintText: 'Describe the situation in detail…'),
          ),
          const SizedBox(height: 16),
          Text('Attach Evidence', style: tt.labelLarge),
          const SizedBox(height: 8),
          PhotoUploadZone(
            photos: _photos,
            label: 'Add photos of the issue',
            onPhotosSelected: (bytes) =>
                setState(() => _photos = [..._photos, ...bytes]),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                const Icon(Icons.error_outline,
                    color: AppColors.statusError),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Urgent Assistance Required',
                          style: tt.bodyMedium
                              ?.copyWith(fontWeight: FontWeight.w700)),
                      Text('Flag this for immediate dispatcher attention',
                          style: tt.bodySmall),
                    ],
                  ),
                ),
                Switch(
                  value: _urgent,
                  activeThumbColor: AppColors.statusSuccess,
                  onChanged: (value) => setState(() => _urgent = value),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 52,
            child: ElevatedButton.icon(
              onPressed: _submitting ? null : _submit,
              icon: _submitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: AppColors.accentDeep),
                    )
                  : const Icon(Icons.send, size: 18),
              label: const Text('Submit Report'),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'All reports are logged with your timestamp for safety auditing.',
            textAlign: TextAlign.center,
            style: tt.bodySmall,
          ),
        ],
      ),
    );
  }
}
