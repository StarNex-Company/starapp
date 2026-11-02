import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:starapp/app/theme/app_theme.dart';
import 'package:starapp/features/search/presentation/widgets/search_style.dart';

/// "Search Row" component: clock tile, the past query and a remove ×.
/// Removing collapses and fades the row out, then calls [onRemoved].
class SearchRecentRow extends StatefulWidget {
  const SearchRecentRow({
    super.key,
    required this.query,
    required this.onTap,
    required this.onRemoved,
    this.topGap = 0,
  });

  final String query;
  final VoidCallback onTap;
  final VoidCallback onRemoved;

  /// Space above the row that collapses with it (the list's 12px gap).
  final double topGap;

  @override
  State<SearchRecentRow> createState() => _SearchRecentRowState();
}

class _SearchRecentRowState extends State<SearchRecentRow>
    with SingleTickerProviderStateMixin {
  late final AnimationController _visible;
  bool _removing = false;

  @override
  void initState() {
    super.initState();
    _visible = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
      value: 1,
    );
  }

  @override
  void dispose() {
    _visible.dispose();
    super.dispose();
  }

  Future<void> _remove() async {
    if (_removing) return;
    _removing = true;
    await _visible.reverse();
    if (mounted) widget.onRemoved();
  }

  @override
  Widget build(BuildContext context) {
    final curve = CurvedAnimation(parent: _visible, curve: Curves.easeInOut);
    return SizeTransition(
      sizeFactor: curve,
      alignment: Alignment.topCenter,
      child: FadeTransition(
        opacity: curve,
        child: Padding(
          padding: EdgeInsets.only(top: widget.topGap),
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              onTap: _removing ? null : widget.onTap,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.brandTint,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: SvgPicture.asset(
                        SearchIcons.clock,
                        width: 20,
                        height: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.query,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15,
                          height: searchLeading,
                          letterSpacing: 0,
                          fontWeight: FontWeight.w500,
                          color: AppColors.ink,
                        ),
                      ),
                    ),
                    // 32×40 hit area; the 16px × sits 2px in from the edge.
                    Semantics(
                      button: true,
                      label: 'Remove ${widget.query}',
                      child: InkResponse(
                        onTap: _remove,
                        radius: 18,
                        child: SizedBox(
                          width: 32,
                          height: 40,
                          child: Padding(
                            padding: const EdgeInsets.only(right: 2),
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: SvgPicture.asset(
                                SearchIcons.remove,
                                width: 16,
                                height: 16,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Grey pill with a trending query.
class SearchChip extends StatelessWidget {
  const SearchChip({super.key, required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.closeButtonBg,
      shape: const StadiumBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: 34,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Center(
            widthFactor: 1,
            child: Text(
              label,
              maxLines: 1,
              style: const TextStyle(
                fontSize: 13,
                height: searchLeading,
                letterSpacing: 0,
                fontWeight: FontWeight.w500,
                color: AppColors.textBody,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
