import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Rounded search input with a leading search icon and optional filter action.
class AppSearchBar extends StatelessWidget {
  const AppSearchBar({
    super.key,
    required this.hint,
    required this.onChanged,
    this.onFilter,
    this.controller,
  });

  final String hint;
  final ValueChanged<String> onChanged;
  final VoidCallback? onFilter;
  final TextEditingController? controller;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon:
            const Icon(Icons.search, color: AppColors.textSecondary, size: 20),
        suffixIcon: onFilter != null
            ? IconButton(
                icon: const Icon(Icons.tune,
                    color: AppColors.textSecondary, size: 20),
                onPressed: onFilter,
              )
            : null,
      ),
    );
  }
}
