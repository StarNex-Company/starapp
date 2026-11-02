import 'package:flutter/material.dart';
import 'package:starapp/features/challenges/presentation/widgets/detail_style.dart';
import 'package:starapp/shared/widgets/star_form_fields.dart';

const _unitLabel = Color(0xFFAFC0F5); // text/on-brand/afc0f5

/// "ENTRY CLOSES IN" with navy Days / Hrs / Min / Sec blocks for [remaining].
class DetailCountdown extends StatelessWidget {
  const DetailCountdown({super.key, required this.remaining});

  final Duration remaining;

  @override
  Widget build(BuildContext context) {
    final left = remaining.isNegative ? Duration.zero : remaining;
    final units = [
      (left.inDays, 'Days'),
      (left.inHours.remainder(24), 'Hrs'),
      (left.inMinutes.remainder(60), 'Min'),
      (left.inSeconds.remainder(60), 'Sec'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 10,
      children: [
        const StarSectionLabel('Entry closes in'),
        Row(
          spacing: 8,
          children: [
            for (final (value, label) in units)
              Expanded(
                child: _Block(value: value, label: label),
              ),
          ],
        ),
      ],
    );
  }
}

class _Block extends StatelessWidget {
  const _Block({required this.value, required this.label});

  final int value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      decoration: const BoxDecoration(
        gradient: DetailGradients.navy,
        borderRadius: BorderRadius.all(Radius.circular(14)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 2,
        children: [
          Text(
            value.toString().padLeft(2, '0'),
            style: const TextStyle(
              height: detailLeading,
              letterSpacing: 0,
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              height: detailLeading,
              letterSpacing: 0.66,
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: _unitLabel,
            ),
          ),
        ],
      ),
    );
  }
}
