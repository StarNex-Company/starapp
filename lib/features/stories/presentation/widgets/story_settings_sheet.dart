import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:starapp/app/theme/app_theme.dart';
import 'package:starapp/features/stories/data/models/new_story.dart';
import 'package:starapp/features/stories/presentation/widgets/story_icons.dart';
import 'package:starapp/features/stories/presentation/widgets/story_style.dart';
import 'package:starapp/shared/widgets/star_bottom_sheet.dart';
import 'package:starapp/shared/widgets/star_buttons.dart';
import 'package:starapp/shared/widgets/star_radio_card.dart';

/// "Story settings" sheet: who can see the story and how long it stays up.
/// Resolves to the new settings when "Done" is tapped, or null if dismissed.
Future<StorySettings?> showStorySettingsSheet(
  BuildContext context, {
  StorySettings initial = const StorySettings(),
}) {
  return showStarSheet<StorySettings>(
    context: context,
    builder: (_) => StorySettingsSheet(initial: initial),
  );
}

class StorySettingsSheet extends StatefulWidget {
  const StorySettingsSheet({super.key, this.initial = const StorySettings()});

  final StorySettings initial;

  @override
  State<StorySettingsSheet> createState() => _StorySettingsSheetState();
}

class _StorySettingsSheetState extends State<StorySettingsSheet> {
  late StorySettings _settings = widget.initial;

  static const _icons = {
    StoryAudience.everyone: StoryIcons.globe,
    StoryAudience.followers: StoryIcons.users,
    StoryAudience.closeFriends: StoryIcons.star18,
  };

  @override
  Widget build(BuildContext context) {
    return StarSheet(
      title: 'Story settings',
      subtitle: 'Choose who sees it and how long it stays',
      children: [
        const _Label('WHO CAN SEE THIS STORY'),
        Column(
          spacing: 8,
          children: [
            for (final audience in StoryAudience.values)
              _AudienceOption(
                audience: audience,
                icon: _icons[audience]!,
                selected: audience == _settings.audience,
                onTap: () => setState(
                  () => _settings = _settings.copyWith(audience: audience),
                ),
              ),
          ],
        ),
        const _Label('KEEP IT UP FOR'),
        Row(
          spacing: 8,
          children: [
            for (final duration in StoryDuration.values)
              Expanded(
                child: _DurationOption(
                  duration: duration,
                  selected: duration == _settings.duration,
                  onTap: () => setState(
                    () => _settings = _settings.copyWith(duration: duration),
                  ),
                ),
              ),
          ],
        ),
        Text(
          'Shorter stories create urgency; 48 hours is great for challenge entries.',
          style: storyText(
            12,
            weight: FontWeight.w500,
            color: StoryColors.sheetLabel,
          ),
        ),
        StarPrimaryButton(
          label: 'Done',
          onPressed: () => Navigator.of(context).pop(_settings),
        ),
      ],
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: storyText(
        13,
        weight: FontWeight.w700,
        color: StoryColors.sheetLabel,
      ),
    );
  }
}

class _AudienceOption extends StatelessWidget {
  const _AudienceOption({
    required this.audience,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final StoryAudience audience;
  final String icon;
  final bool selected;
  final VoidCallback onTap;

  static const _radius = BorderRadius.all(Radius.circular(16));

  @override
  Widget build(BuildContext context) {
    return Semantics(
      inMutuallyExclusiveGroup: true,
      checked: selected,
      button: true,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: 60,
        decoration: BoxDecoration(
          color: selected ? AppColors.brandTint : StoryColors.optionFill,
          borderRadius: _radius,
          border: selected
              ? Border.all(color: AppColors.brandBlue, width: 1.5)
              : Border.all(color: StoryColors.optionBorder),
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            borderRadius: _radius,
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Row(
                spacing: 12,
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: selected ? AppColors.brandBlue : Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: SvgPicture.asset(
                      icon,
                      width: 18,
                      height: 18,
                      colorFilter: selected
                          ? const ColorFilter.mode(
                              Colors.white,
                              BlendMode.srcIn,
                            )
                          : null,
                    ),
                  ),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 2,
                      children: [
                        Text(
                          audience.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: storyText(
                            15,
                            weight: FontWeight.w600,
                            color: AppColors.ink,
                          ),
                        ),
                        Text(
                          audience.subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: storyText(
                            12,
                            weight: FontWeight.w500,
                            color: StoryColors.sheetLabel,
                          ),
                        ),
                      ],
                    ),
                  ),
                  StarRadioDot(selected: selected),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DurationOption extends StatelessWidget {
  const _DurationOption({
    required this.duration,
    required this.selected,
    required this.onTap,
  });

  final StoryDuration duration;
  final bool selected;
  final VoidCallback onTap;

  static const _radius = BorderRadius.all(Radius.circular(14));

  @override
  Widget build(BuildContext context) {
    return Semantics(
      inMutuallyExclusiveGroup: true,
      checked: selected,
      button: true,
      child: Material(
        color: selected ? AppColors.brandBlue : StoryColors.durationFill,
        borderRadius: _radius,
        child: InkWell(
          borderRadius: _radius,
          onTap: onTap,
          child: SizedBox(
            height: 44,
            child: Center(
              child: Text(
                duration.label,
                style: storyText(
                  15,
                  weight: selected ? FontWeight.w700 : FontWeight.w600,
                  color: selected ? Colors.white : StoryColors.durationText,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
