import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/dialog_actions.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/models/client.dart';
import '../providers/clients_providers.dart';

/// Add / edit client modal. Returns the client id on save (new id for adds).
class ClientFormDialog extends ConsumerStatefulWidget {
  const ClientFormDialog({super.key, this.existing});

  /// When set, the dialog edits this client instead of creating one.
  final Client? existing;

  static Future<String?> show(BuildContext context,
      {Client? existing}) {
    return showDialog<String>(
      context: context,
      builder: (_) => ClientFormDialog(existing: existing),
    );
  }

  @override
  ConsumerState<ClientFormDialog> createState() => _ClientFormDialogState();
}

class _ClientFormDialogState extends ConsumerState<ClientFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.existing?.displayName);
  late final _email = TextEditingController(text: widget.existing?.email);
  late final _phone = TextEditingController(text: widget.existing?.phone);
  late final _address = TextEditingController(text: widget.existing?.address.line1);
  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _address.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final mutations = ref.read(clientMutationsProvider.notifier);
    try {
      final String id;
      if (widget.existing == null) {
        id = await mutations.addClient(
          name: _name.text.trim(),
          email: _email.text.trim(),
          phone: _phone.text.trim(),
          address: _address.text.trim(),
        );
      } else {
        id = widget.existing!.id;
        await mutations.updateClient(
          id,
          name: _name.text.trim(),
          email: _email.text.trim(),
          phone: _phone.text.trim(),
          address: _address.text.trim(),
        );
      }
      if (mounted) Navigator.of(context).pop(id);
    } catch (error) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not save client: $error')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.existing != null;
    final textTheme = Theme.of(context).textTheme;

    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(editing ? 'Edit Client' : 'New Client',
                    style: textTheme.headlineSmall),
                const SizedBox(height: 20),
                _field('Full Name', _name,
                    validator: (value) => (value ?? '').trim().isEmpty
                        ? 'Name is required'
                        : null),
                _field('Email Address', _email,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) =>
                        (value ?? '').contains('@') ? null : 'Enter a valid email'),
                _field('Phone Number', _phone,
                    keyboardType: TextInputType.phone),
                _field('Address', _address, maxLines: 2),
                const SizedBox(height: 8),
                DialogActions(
                saving: _saving, onSave: _save, saveLabel: editing ? 'Save Changes' : 'Create Client'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _field(
    String label,
    TextEditingController controller, {
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 6),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            validator: validator,
            maxLines: maxLines,
          ),
        ],
      ),
    );
  }
}
