import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/enums/app_enums.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/photo_upload_zone.dart';
import '../providers/clients_providers.dart';
import '../providers/inventory_providers.dart';

/// Register-a-box modal: client, type, label, photos.
/// Returns the new box id on save.
class AddBoxDialog extends ConsumerStatefulWidget {
  const AddBoxDialog({super.key, this.initialClientId});

  /// Pre-selects the client (e.g. when opened from a client detail page).
  final String? initialClientId;

  static Future<String?> show(BuildContext context,
      {String? initialClientId}) {
    return showDialog<String>(
      context: context,
      builder: (_) => AddBoxDialog(initialClientId: initialClientId),
    );
  }

  @override
  ConsumerState<AddBoxDialog> createState() => _AddBoxDialogState();
}

class _AddBoxDialogState extends ConsumerState<AddBoxDialog> {
  final _label = TextEditingController();
  late String? _clientId = widget.initialClientId;
  UnitType _type = UnitType.closed;
  List<Uint8List> _photos = [];
  bool _saving = false;

  @override
  void dispose() {
    _label.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final clientId = _clientId;
    if (clientId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select a client first')),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      final id = await ref.read(unitMutationsProvider.notifier).addUnit(
            clientId: clientId,
            type: _type,
            label: _label.text.trim(),
            photos: _photos,
          );
      if (mounted) Navigator.of(context).pop(id);
    } catch (error) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not add box: $error')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final clients = ref.watch(clientsProvider).valueOrNull ?? [];
    final textTheme = Theme.of(context).textTheme;

    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Add New Box', style: textTheme.headlineSmall),
              const SizedBox(height: 4),
              Text('Quickly register a new container into the system.',
                  style: textTheme.bodyMedium
                      ?.copyWith(color: AppColors.textSecondary)),
              const SizedBox(height: 20),
              Text('Client', style: textTheme.labelLarge),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                initialValue: _clientId,
                hint: const Text('Select client'),
                items: [
                  for (final client in clients)
                    DropdownMenuItem(
                        value: client.id, child: Text(client.displayName)),
                ],
                onChanged: (value) => setState(() => _clientId = value),
              ),
              const SizedBox(height: 16),
              Text('Box Type', style: textTheme.labelLarge),
              const SizedBox(height: 6),
              SegmentedButton<UnitType>(
                segments: const [
                  ButtonSegment(
                      value: UnitType.closed, label: Text('Closed Box')),
                  ButtonSegment(value: UnitType.open, label: Text('Open Box')),
                ],
                selected: {_type},
                onSelectionChanged: (selection) =>
                    setState(() => _type = selection.first),
                style: SegmentedButton.styleFrom(
                  selectedBackgroundColor: AppColors.amber,
                  selectedForegroundColor: AppColors.amberDark,
                ),
              ),
              const SizedBox(height: 16),
              Text('Label', style: textTheme.labelLarge),
              const SizedBox(height: 6),
              TextField(
                controller: _label,
                decoration: const InputDecoration(
                    hintText: 'e.g. Legal Documents — Archive 2024'),
              ),
              const SizedBox(height: 16),
              Text('Photos', style: textTheme.labelLarge),
              const SizedBox(height: 6),
              PhotoUploadZone(
                photos: _photos,
                onPhotosSelected: (bytes) =>
                    setState(() => _photos = [..._photos, ...bytes]),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed:
                        _saving ? null : () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _saving ? null : _save,
                    child: _saving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: AppColors.amberDark),
                          )
                        : const Text('Register Box'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
