import 'package:flutter/material.dart';

/// Row with a bold section title on the left and an optional action on the right.
class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.title, this.action});

  final String title;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        // Null check kept as `if`: build_runner's analyzer can't parse `?element` yet.
        // ignore: use_null_aware_elements
        if (action != null) action!,
      ],
    );
  }
}
