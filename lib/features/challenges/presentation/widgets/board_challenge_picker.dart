import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:starapp/app/theme/app_theme.dart';
import 'package:starapp/core/utils/formatters.dart';
import 'package:starapp/features/challenges/data/models/challenge.dart';
import 'package:starapp/features/challenges/presentation/widgets/board_icons.dart';
import 'package:starapp/features/challenges/presentation/widgets/challenge_format.dart';
import 'package:starapp/shared/widgets/star_image.dart';
import 'package:starapp/shared/widgets/star_radio_card.dart';

const _menuBorder = Color(0xFFE4E8F0); // border/default/e4e8f0
const _menuMeta = Color(0xFF8A93A6); // text/secondary/8a93a6
const _menuGap = 4.5;

/// Card naming the challenge the board shows. Tapping it drops a menu of the
/// other challenges over the content below; picking one reports its index.
class BoardChallengePicker extends StatefulWidget {
  const BoardChallengePicker({
    super.key,
    required this.challenges,
    required this.selected,
    required this.onSelected,
  });

  final List<Challenge> challenges;
  final int selected;
  final ValueChanged<int> onSelected;

  @override
  State<BoardChallengePicker> createState() => _BoardChallengePickerState();
}

class _BoardChallengePickerState extends State<BoardChallengePicker>
    with SingleTickerProviderStateMixin {
  final _portal = OverlayPortalController();
  final _link = LayerLink();
  late final AnimationController _menu;
  bool _open = false;
  double _width = 0;

  @override
  void initState() {
    super.initState();
    _menu = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );
  }

  @override
  void dispose() {
    _menu.dispose();
    super.dispose();
  }

  void _toggle() => _open ? _close() : _show();

  void _show() {
    setState(() => _open = true);
    _portal.show();
    _menu.forward(from: 0);
  }

  Future<void> _close() async {
    if (!_open) return;
    setState(() => _open = false);
    await _menu.reverse();
    if (mounted && !_open) _portal.hide();
  }

  void _pick(int index) {
    if (index != widget.selected) widget.onSelected(index);
    _close();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        _width = constraints.maxWidth;
        return CompositedTransformTarget(
          link: _link,
          child: OverlayPortal(
            controller: _portal,
            overlayChildBuilder: _buildMenu,
            child: _PickerCard(
              challenge: widget.challenges[widget.selected],
              open: _open,
              onTap: _toggle,
            ),
          ),
        );
      },
    );
  }

  Widget _buildMenu(BuildContext context) {
    final curved = CurvedAnimation(parent: _menu, curve: Curves.easeOutCubic);
    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _close,
          ),
        ),
        CompositedTransformFollower(
          link: _link,
          targetAnchor: Alignment.bottomLeft,
          offset: const Offset(0, _menuGap),
          child: SizedBox(
            width: _width,
            child: FadeTransition(
              opacity: curved,
              child: SlideTransition(
                position: Tween(
                  begin: const Offset(0, -0.06),
                  end: Offset.zero,
                ).animate(curved),
                child: _Menu(
                  challenges: widget.challenges,
                  selected: widget.selected,
                  onPick: _pick,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PickerCard extends StatelessWidget {
  const _PickerCard({
    required this.challenge,
    required this.open,
    required this.onTap,
  });

  final Challenge challenge;
  final bool open;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      expanded: open,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: StarDividedCard.decoration.copyWith(
          border: Border.all(
            color: open ? AppColors.brandBlue : AppColors.borderField,
            width: open ? 1.5 : 1,
          ),
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: onTap,
            child: Padding(
              // Keeps the card 66px tall whatever the border width; the
              // design gives the title 237px, so the chevron side is tighter.
              padding: open
                  ? const EdgeInsets.fromLTRB(9.5, 9.5, 7.5, 9.5)
                  : const EdgeInsets.fromLTRB(10, 10, 8, 10),
              child: Row(
                spacing: 12,
                children: [
                  _Thumbnail(asset: challenge.coverUrl),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 2,
                      children: [
                        Text(
                          challenge.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            height: 1.21,
                            letterSpacing: 0,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.ink,
                          ),
                        ),
                        Text(
                          _meta(challenge),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            height: 1.21,
                            letterSpacing: 0,
                            fontSize: 12,
                            color: AppColors.textSubtle,
                          ),
                        ),
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    turns: open ? 0.5 : 0,
                    duration: const Duration(milliseconds: 180),
                    child: SvgPicture.asset(
                      BoardIcons.chevronDown,
                      width: 20,
                      height: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Thumbnail extends StatelessWidget {
  const _Thumbnail({required this.asset});

  final String? asset;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: SizedBox.square(
        dimension: 44,
        child: asset == null
            ? ColoredBox(
                color: AppColors.brandTint,
                child: Center(
                  child: SvgPicture.asset(
                    BoardIcons.trophyOutline,
                    width: 20,
                    height: 20,
                  ),
                ),
              )
            : Stack(
                fit: StackFit.expand,
                children: [
                  StarImage(asset),
                  const Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    height: 22,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0x0007090D), Color(0xB307090D)],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _Menu extends StatelessWidget {
  const _Menu({
    required this.challenges,
    required this.selected,
    required this.onPick,
  });

  final List<Challenge> challenges;
  final int selected;
  final ValueChanged<int> onPick;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _menuBorder),
        boxShadow: const [
          BoxShadow(
            color: Color(0x29031A5E),
            offset: Offset(0, 10),
            blurRadius: 14,
          ),
        ],
      ),
      child: Material(
        type: MaterialType.transparency,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 2,
          children: [
            for (var i = 0; i < challenges.length; i++)
              _MenuOption(
                challenge: challenges[i],
                selected: i == selected,
                onTap: () => onPick(i),
              ),
          ],
        ),
      ),
    );
  }
}

class _MenuOption extends StatelessWidget {
  const _MenuOption({
    required this.challenge,
    required this.selected,
    required this.onTap,
  });

  final Challenge challenge;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: selected,
      inMutuallyExclusiveGroup: true,
      child: Ink(
        decoration: BoxDecoration(
          color: selected ? AppColors.brandTint : null,
          borderRadius: BorderRadius.circular(10),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
            child: Row(
              spacing: 10,
              children: [
                SvgPicture.asset(
                  _isLive(challenge)
                      ? BoardIcons.live
                      : BoardIcons.trophyOutline,
                  width: 16,
                  height: 16,
                ),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 2,
                    children: [
                      Text(
                        challenge.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          height: 1.21,
                          letterSpacing: 0,
                          fontSize: 14,
                          fontWeight: selected
                              ? FontWeight.w600
                              : FontWeight.w400,
                          color: selected ? AppColors.brandBlue : AppColors.ink,
                        ),
                      ),
                      Text(
                        _isLive(challenge)
                            ? 'Live · ${_meta(challenge)}'
                            : _meta(challenge),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          height: 1.21,
                          letterSpacing: 0,
                          fontSize: 11,
                          color: _menuMeta,
                        ),
                      ),
                    ],
                  ),
                ),
                if (selected)
                  SvgPicture.asset(BoardIcons.check, width: 15, height: 15),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

bool _isLive(Challenge challenge) => challenge.status == ChallengeStatus.live;

/// "890 entries · ends in 4d 18h", or "Ended Sep 2026 · see the winners".
String _meta(Challenge challenge) => _isLive(challenge)
    ? '${formatGrouped(challenge.entryCount)} entries · '
          'ends in ${formatTimeLeft(challenge.endsAt)}'
    : 'Ended ${formatMonth(challenge.endsAt)} · see the winners';
