import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:starapp/app/theme/app_theme.dart';
import 'package:starapp/features/search/presentation/widgets/search_style.dart';
import 'package:starapp/shared/widgets/star_icon_button.dart';

/// Search top bar: back button, pill search field and "Cancel". Use as
/// `Scaffold.appBar`; it pads itself below the status bar like
/// `StarScreenHeader`.
class SearchHeader extends StatelessWidget implements PreferredSizeWidget {
  const SearchHeader({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onBack,
    required this.onCancel,
    required this.onSubmitted,
    this.autofocus = true,
  });

  static const barHeight = 67.0;

  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onBack;
  final VoidCallback onCancel;
  final ValueChanged<String> onSubmitted;
  final bool autofocus;

  @override
  Size get preferredSize => const Size.fromHeight(barHeight);

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Color(0x40000000),
              offset: Offset(0, 4),
              blurRadius: 4,
            ),
          ],
        ),
        child: SafeArea(
          bottom: false,
          child: SizedBox(
            height: barHeight,
            child: Padding(
              padding: const EdgeInsets.only(left: 24, right: 20),
              child: Row(
                children: [
                  StarIconButton.back(onPressed: onBack),
                  const SizedBox(width: 7),
                  Expanded(
                    child: _SearchField(
                      controller: controller,
                      focusNode: focusNode,
                      autofocus: autofocus,
                      onSubmitted: onSubmitted,
                    ),
                  ),
                  const SizedBox(width: 22),
                  _CancelButton(onTap: onCancel),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.controller,
    required this.focusNode,
    required this.autofocus,
    required this.onSubmitted,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool autofocus;
  final ValueChanged<String> onSubmitted;

  static const _textStyle = TextStyle(
    fontSize: 16,
    height: searchLeading,
    letterSpacing: 0,
    fontWeight: FontWeight.w500,
    color: AppColors.ink,
  );

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: focusNode.requestFocus,
      child: Container(
        height: 42,
        padding: const EdgeInsets.only(left: 16),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: AppColors.iconButtonBg,
          borderRadius: BorderRadius.circular(38),
        ),
        child: Row(
          children: [
            SvgPicture.asset(SearchIcons.search, width: 22, height: 22),
            const SizedBox(width: 5),
            Expanded(
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                autofocus: autofocus,
                onSubmitted: onSubmitted,
                textInputAction: TextInputAction.search,
                style: _textStyle,
                cursorColor: AppColors.brandBlue,
                cursorWidth: 2,
                cursorHeight: 20,
                maxLines: 1,
                decoration: InputDecoration(
                  isCollapsed: true,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.only(left: 2),
                  hint: Text(
                    'Search creators, talents, challenges',
                    maxLines: 1,
                    softWrap: false,
                    overflow: TextOverflow.clip,
                    style: _textStyle.copyWith(color: SearchColors.placeholder),
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

class _CancelButton extends StatelessWidget {
  const _CancelButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: const Padding(
          padding: EdgeInsets.symmetric(vertical: 10),
          child: Text(
            'Cancel',
            style: TextStyle(
              fontSize: 15,
              height: searchLeading,
              letterSpacing: 0,
              fontWeight: FontWeight.w600,
              color: AppColors.brandNavy,
            ),
          ),
        ),
      ),
    );
  }
}
