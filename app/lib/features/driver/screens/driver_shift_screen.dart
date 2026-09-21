import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/models/app_user.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/models/driver_shift.dart';
import '../providers/shift_providers.dart';

/// Shift management + facility-access E-ID. Design:
/// driver_shift_management_id/screen.png.
class DriverShiftScreen extends ConsumerWidget {
  const DriverShiftScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shift = ref.watch(activeShiftProvider);
    final user = ref.watch(currentUserProvider).valueOrNull;
    final tt = Theme.of(context).textTheme;

    return shift.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
        child: Text('Could not load shift: $error',
            style: tt.bodyMedium?.copyWith(color: AppColors.statusError)),
      ),
      data: (model) => ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          Row(
            children: [
              Text('Shift Status', style: tt.headlineSmall),
              const Spacer(),
              if (model != null)
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: model.onBreak
                            ? AppColors.statusWarning
                            : AppColors.statusSuccess,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(model.onBreak ? 'On Break' : 'Active Now',
                        style: tt.bodyMedium?.copyWith(
                          color: model.onBreak
                              ? AppColors.statusWarning
                              : AppColors.statusSuccess,
                          fontWeight: FontWeight.w600,
                        )),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 16),
          if (model == null)
            _StartShiftCard()
          else ...[
            _ElapsedCard(shift: model),
            const SizedBox(height: 24),
            Text('E-Identification', style: tt.headlineSmall),
            const SizedBox(height: 12),
            _EidCard(user: user),
          ],
        ],
      ),
    );
  }
}

class _StartShiftCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.navy,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          const Icon(Icons.play_circle_outline,
              color: AppColors.sky, size: 48),
          const SizedBox(height: 12),
          Text('No active shift',
              style: tt.titleMedium?.copyWith(color: Colors.white)),
          const SizedBox(height: 4),
          Text('Clock in to access your E-ID and facility gates.',
              textAlign: TextAlign.center,
              style: tt.bodySmall?.copyWith(color: Colors.white70)),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () =>
                  ref.read(shiftActionsProvider.notifier).startShift(),
              child: const Text('Start Shift'),
            ),
          ),
        ],
      ),
    );
  }
}

class _ElapsedCard extends ConsumerStatefulWidget {
  const _ElapsedCard({required this.shift});

  final DriverShift shift;

  @override
  ConsumerState<_ElapsedCard> createState() => _ElapsedCardState();
}

class _ElapsedCardState extends ConsumerState<_ElapsedCard> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(
        const Duration(seconds: 1), (_) => setState(() {}));
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _elapsed() {
    final diff = DateTime.now().difference(widget.shift.startedAt ?? DateTime.now());
    final h = diff.inHours.toString().padLeft(2, '0');
    final m = (diff.inMinutes % 60).toString().padLeft(2, '0');
    final s = (diff.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final shift = widget.shift;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.navy,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('ELAPSED TIME',
              style: tt.bodySmall
                  ?.copyWith(color: Colors.white54, letterSpacing: 1)),
          const SizedBox(height: 8),
          Text(
            _elapsed(),
            style: GoogleFonts.robotoMono(
              fontSize: 44,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.statusError,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () => ref
                      .read(shiftActionsProvider.notifier)
                      .endShift(shift.id),
                  icon: const Icon(Icons.stop_circle_outlined, size: 18),
                  label: const Text('End Shift'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white54),
                  ),
                  onPressed: () => ref
                      .read(shiftActionsProvider.notifier)
                      .setBreak(shift.id, onBreak: !shift.onBreak),
                  icon: Icon(
                      shift.onBreak
                          ? Icons.play_arrow
                          : Icons.pause_circle_outline,
                      size: 18),
                  label: Text(shift.onBreak ? 'Resume' : 'Break'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EidCard extends StatelessWidget {
  const _EidCard({required this.user});

  final AppUser? user;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final uid = user?.id ?? '';
    final employeeId =
        'SB-${uid.substring(0, uid.length.clamp(0, 6)).toUpperCase()}';
    final gateCode = 'DRV-${uid.substring(0, uid.length.clamp(0, 8))}';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [AppTheme.cardShadow],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.badge,
                    color: AppColors.navy, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Driver Name', style: tt.bodySmall),
                    Text(user?.name ?? 'Driver', style: tt.titleMedium),
                    const SizedBox(height: 8),
                    Text('Employee ID', style: tt.bodySmall),
                    Text(employeeId,
                        style: tt.bodyMedium
                            ?.copyWith(fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.statusWarningBg,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text('Clearance: Level 4',
                style: tt.bodySmall?.copyWith(
                    color: AppColors.statusPastDue,
                    fontWeight: FontWeight.w600)),
          ),
          const Divider(height: 32),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.accentDeep, width: 2),
            ),
            child: QrImageView(
              data: gateCode,
              size: 160,
              dataModuleStyle: const QrDataModuleStyle(
                dataModuleShape: QrDataModuleShape.square,
                color: AppColors.navy,
              ),
              eyeStyle: const QrEyeStyle(
                eyeShape: QrEyeShape.square,
                color: AppColors.navy,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Present this code at Gate Sensors or Security Terminals for '
            'facility access.',
            textAlign: TextAlign.center,
            style: tt.bodySmall,
          ),
        ],
      ),
    );
  }
}
