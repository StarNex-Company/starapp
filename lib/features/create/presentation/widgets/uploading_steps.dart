import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:starapp/app/theme/app_theme.dart';
import 'package:starapp/features/create/presentation/widgets/uploading_card.dart';

const _checkIcon = 'assets/vectors/create/uploading_ic_check.svg';
const _spinnerIcon = 'assets/vectors/create/uploading_status_spinner.svg';

enum UploadStepState { done, active, pending }

class UploadStepData {
  const UploadStepData({
    required this.title,
    required this.subtitle,
    required this.state,
  });

  final String title;
  final String subtitle;
  final UploadStepState state;
}

/// Card listing the pipeline steps with a done / active / pending marker.
class UploadingSteps extends StatelessWidget {
  const UploadingSteps({super.key, required this.steps});

  final List<UploadStepData> steps;

  @override
  Widget build(BuildContext context) {
    return UploadingPanel(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        spacing: 4,
        children: [for (final step in steps) _StepRow(step)],
      ),
    );
  }
}

class _StepRow extends StatelessWidget {
  const _StepRow(this.step);

  final UploadStepData step;

  @override
  Widget build(BuildContext context) {
    final pending = step.state == UploadStepState.pending;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        spacing: 12,
        children: [
          switch (step.state) {
            UploadStepState.done => const _DoneMarker(),
            UploadStepState.active => const _ActiveMarker(),
            UploadStepState.pending => const _PendingMarker(),
          },
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 3,
              children: [
                Text(
                  step.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: pending ? AppColors.textSubtle : AppColors.ink,
                  ),
                ),
                Text(
                  step.subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSubtle,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DoneMarker extends StatelessWidget {
  const _DoneMarker();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: AppColors.successTint,
        shape: BoxShape.circle,
      ),
      child: SvgPicture.asset(_checkIcon, width: 15, height: 15),
    );
  }
}

class _PendingMarker extends StatelessWidget {
  const _PendingMarker();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.borderMuted, width: 1.5),
      ),
    );
  }
}

/// Navy arc on a tinted track, turning while the step runs.
class _ActiveMarker extends StatefulWidget {
  const _ActiveMarker();

  @override
  State<_ActiveMarker> createState() => _ActiveMarkerState();
}

class _ActiveMarkerState extends State<_ActiveMarker>
    with SingleTickerProviderStateMixin {
  late final AnimationController _spin = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat();

  @override
  void dispose() {
    _spin.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _spin,
      child: SvgPicture.asset(_spinnerIcon, width: 28, height: 28),
    );
  }
}
