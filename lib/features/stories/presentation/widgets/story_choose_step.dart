import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:starapp/app/theme/app_theme.dart';
import 'package:starapp/core/utils/formatters.dart';
import 'package:starapp/features/stories/data/models/new_story.dart';
import 'package:starapp/features/stories/presentation/widgets/story_circle_button.dart';
import 'package:starapp/features/stories/presentation/widgets/story_icons.dart';
import 'package:starapp/features/stories/presentation/widgets/story_style.dart';

enum _GalleryTab {
  recents('Recents'),
  photos('Photos'),
  videos('Videos');

  const _GalleryTab(this.label);

  final String label;
}

/// Step 1 of story creation, "Add to story": pick one photo or video from the
/// sample camera roll, then "Next".
class StoryChooseStep extends StatefulWidget {
  const StoryChooseStep({
    super.key,
    required this.media,
    required this.selected,
    required this.onSelect,
    required this.onClose,
    required this.onNext,
  });

  final List<StoryMedia> media;
  final StoryMedia? selected;
  final ValueChanged<StoryMedia?> onSelect;
  final VoidCallback onClose;

  /// Only enabled once something is selected.
  final VoidCallback onNext;

  @override
  State<StoryChooseStep> createState() => _StoryChooseStepState();
}

class _StoryChooseStepState extends State<StoryChooseStep> {
  _GalleryTab _tab = _GalleryTab.recents;

  List<StoryMedia> get _visible => switch (_tab) {
    _GalleryTab.recents => widget.media,
    _GalleryTab.photos => widget.media.where((m) => !m.isVideo).toList(),
    _GalleryTab.videos => widget.media.where((m) => m.isVideo).toList(),
  };

  @override
  Widget build(BuildContext context) {
    final padding = MediaQuery.viewPaddingOf(context);
    final top = math.max(padding.top, 24.0);
    final items = _visible;
    final selected = widget.selected;

    return ColoredBox(
      color: AppColors.voidBlack,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: top + 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SizedBox(
              height: 40,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Text(
                    'Add to story',
                    style: storyText(18, weight: FontWeight.w700),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: StoryCircleButton(
                      icon: StoryIcons.close20,
                      label: 'Close',
                      color: const Color(0x24FFFFFF),
                      onTap: widget.onClose,
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: _NextButton(
                      onTap: selected == null ? null : widget.onNext,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              spacing: 8,
              children: [
                for (final tab in _GalleryTab.values)
                  _TabPill(
                    label: tab.label,
                    active: tab == _tab,
                    onTap: () => setState(() => _tab = tab),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Photos or videos up to 30 seconds',
              style: storyText(
                12,
                weight: FontWeight.w500,
                color: const Color(0x99FFFFFF),
              ),
            ),
          ),
          const SizedBox(height: 11),
          Expanded(
            child: GridView.builder(
              padding: EdgeInsets.only(bottom: padding.bottom),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 3,
                crossAxisSpacing: 3,
                childAspectRatio: 129 / 172,
              ),
              itemCount: items.length,
              itemBuilder: (context, i) {
                final item = items[i];
                final isSelected = identical(item, selected);
                return _GalleryTile(
                  media: item,
                  selected: isSelected,
                  onTap: () => widget.onSelect(isSelected ? null : item),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _GalleryTile extends StatelessWidget {
  const _GalleryTile({
    required this.media,
    required this.selected,
    required this.onTap,
  });

  final StoryMedia media;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: media.isVideo
          ? 'Video, ${formatDuration(media.duration!)}'
          : 'Photo',
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onTap,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Bundled samples until a gallery plugin supplies the device's files.
            Image.asset(media.path, fit: BoxFit.cover, cacheWidth: 390),
            if (media.isVideo)
              Positioned(
                right: 6,
                bottom: 6,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0x8C000000),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    spacing: 4,
                    children: [
                      SvgPicture.asset(StoryIcons.play9, width: 9, height: 9),
                      Text(
                        formatDuration(media.duration!),
                        style: storyText(11, weight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ),
            if (selected)
              const DecoratedBox(
                decoration: BoxDecoration(
                  border: Border.fromBorderSide(
                    BorderSide(color: AppColors.gold, width: 3),
                  ),
                ),
              ),
            Positioned(
              top: 6,
              right: 6,
              child: selected
                  ? Container(
                      width: 22,
                      height: 22,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        color: AppColors.gold,
                        shape: BoxShape.circle,
                      ),
                      child: SvgPicture.asset(
                        StoryIcons.check13,
                        width: 13,
                        height: 13,
                      ),
                    )
                  : SvgPicture.asset(
                      StoryIcons.selectRing,
                      width: 22,
                      height: 22,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TabPill extends StatelessWidget {
  const _TabPill({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: active,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: active ? Colors.white : const Color(0x1FFFFFFF),
            borderRadius: BorderRadius.circular(99),
          ),
          child: Text(
            label,
            style: storyText(
              13,
              weight: FontWeight.w600,
              color: active ? AppColors.ink : Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

class _NextButton extends StatelessWidget {
  const _NextButton({required this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: onTap == null ? 0.4 : 1,
      child: Material(
        color: AppColors.gold,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: SizedBox(
            width: 72,
            height: 36,
            child: Center(
              child: Text(
                'Next',
                style: storyText(
                  14,
                  weight: FontWeight.w700,
                  color: StoryColors.onGold,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
