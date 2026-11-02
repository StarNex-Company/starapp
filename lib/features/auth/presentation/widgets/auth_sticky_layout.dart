import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:starapp/app/theme/app_theme.dart';

/// Search icon (`fluent:search-24-filled`, 22×22, #000207).
const String kAuthSearchIcon = 'assets/vectors/auth_search.svg';

/// Shadow of the sticky panels: #000 @ 25%, blur 2, 4px towards the content.
const Color _shadowColor = Color(0x40000000);

/// Search placeholder colour (text/secondary/mist-gray).
const Color _hintColor = Color(0xFF808692);

/// Page body with a sticky [header] and a sticky [bottomBar] around a
/// scrolling [body] (Figma "Interest" and "Language Selection").
///
/// The header and bar are laid out at their natural height; [body] gets the
/// space between them. They paint over the body, so their drop shadows fall
/// on the content as it scrolls underneath.
///
/// ```dart
/// AuthStickyLayout(
///   header: AuthStickyPanel(children: [title, AuthSearchField(...)]),
///   body: ListView(...),
///   bottomBar: AuthActionBar(secondary: ..., primary: ...),
/// )
/// ```
class AuthStickyLayout extends StatelessWidget {
  const AuthStickyLayout({
    super.key,
    required this.header,
    required this.body,
    required this.bottomBar,
  });

  final Widget header;
  final Widget body;
  final Widget bottomBar;

  @override
  Widget build(BuildContext context) {
    // Paint order = list order: body first, so the chrome's shadows sit on it.
    return CustomMultiChildLayout(
      delegate: _StickyLayoutDelegate(),
      children: [
        LayoutId(id: _Slot.body, child: body),
        LayoutId(id: _Slot.header, child: header),
        LayoutId(id: _Slot.bottom, child: bottomBar),
      ],
    );
  }
}

enum _Slot { header, body, bottom }

class _StickyLayoutDelegate extends MultiChildLayoutDelegate {
  @override
  void performLayout(Size size) {
    final width = size.width;
    final header = layoutChild(
      _Slot.header,
      BoxConstraints(minWidth: width, maxWidth: width, maxHeight: size.height),
    );
    final bottom = layoutChild(
      _Slot.bottom,
      BoxConstraints(
        minWidth: width,
        maxWidth: width,
        maxHeight: math.max(0, size.height - header.height),
      ),
    );
    final bodyHeight = math.max(
      0.0,
      size.height - header.height - bottom.height,
    );
    layoutChild(_Slot.body, BoxConstraints.tight(Size(width, bodyHeight)));

    positionChild(_Slot.header, Offset.zero);
    positionChild(_Slot.body, Offset(0, header.height));
    positionChild(_Slot.bottom, Offset(0, size.height - bottom.height));
  }

  @override
  bool shouldRelayout(_StickyLayoutDelegate oldDelegate) => false;
}

/// Sticky header panel: #F7F7F8, 15px bottom corners, drop shadow
/// (0, 4, blur 2, #000 @ 25%), 24px sides, 13px bottom padding and 10px
/// between [children] (heading, then the search field).
class AuthStickyPanel extends StatelessWidget {
  const AuthStickyPanel({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.lunarWhite,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(15)),
        boxShadow: [
          BoxShadow(color: _shadowColor, offset: Offset(0, 4), blurRadius: 2),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 13),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 10,
          children: children,
        ),
      ),
    );
  }
}

/// Sticky bottom bar with two side-by-side actions (Figma "Action btn"):
/// #F7F7F8 with an upward shadow, 24px sides, 12px top, 10px gap; 80 high on
/// a phone with a 34px home indicator (bottom padding = inset − 11, min 10).
///
/// ```dart
/// AuthActionBar(
///   secondary: AuthSecondaryButton(label: 'Cancel', size: AuthButtonSize.compact, onPressed: ...),
///   primary: AuthPrimaryButton(label: 'Done', size: AuthButtonSize.compact, onPressed: ...),
/// )
/// ```
class AuthActionBar extends StatelessWidget {
  const AuthActionBar({
    super.key,
    required this.secondary,
    required this.primary,
  });

  final Widget secondary;
  final Widget primary;

  @override
  Widget build(BuildContext context) {
    final inset = MediaQuery.paddingOf(context).bottom;
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.lunarWhite,
        boxShadow: [
          BoxShadow(color: _shadowColor, offset: Offset(0, -4), blurRadius: 2),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(24, 12, 24, math.max(10, inset - 11)),
        child: Row(
          spacing: 10,
          children: [
            Expanded(child: secondary),
            Expanded(child: primary),
          ],
        ),
      ),
    );
  }
}

/// Bordered search input of the Interest / Language screens.
///
/// 45 high, radius 12, #F7F7F8 fill, 1px #000207 border (1.5px #001F6E when
/// focused); 22px search icon 15px from the left, 8px before the text;
/// placeholder 14 Italic #808692, value 14 Regular #000207.
class AuthSearchField extends StatelessWidget {
  const AuthSearchField({
    super.key,
    required this.hint,
    this.controller,
    this.onChanged,
    this.focusNode,
  });

  final String hint;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final FocusNode? focusNode;

  static const double _height = 45;
  static const double _iconSize = 22;
  static const double _side = 15;
  static const double _gap = 8;

  static const TextStyle _valueStyle = TextStyle(
    fontFamily: 'Inter',
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.21,
    letterSpacing: 0,
    color: AppColors.voidBlack,
  );

  static const TextStyle _hintStyle = TextStyle(
    fontFamily: 'Inter',
    fontSize: 14,
    fontWeight: FontWeight.w400,
    fontStyle: FontStyle.italic,
    height: 1.21,
    letterSpacing: 0,
    color: _hintColor,
  );

  static OutlineInputBorder _border(Color color, double width) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: color, width: width),
      );

  @override
  Widget build(BuildContext context) {
    final vPad = (_height - _valueStyle.fontSize! * _valueStyle.height!) / 2;
    // Material 3 adds 4px between a prefix icon and the text.
    final iconGap = Theme.of(context).useMaterial3 ? 4.0 : 0.0;

    return TextField(
      controller: controller,
      focusNode: focusNode,
      onChanged: onChanged,
      style: _valueStyle,
      cursorColor: AppColors.brandNavy,
      cursorHeight: 16,
      textInputAction: TextInputAction.search,
      textAlignVertical: TextAlignVertical.center,
      decoration: InputDecoration(
        isDense: true,
        filled: true,
        fillColor: AppColors.lunarWhite,
        hintText: hint,
        hintStyle: _hintStyle,
        hintMaxLines: 1,
        contentPadding: EdgeInsets.fromLTRB(0, vPad, _side - 4, vPad),
        prefixIcon: Padding(
          padding: EdgeInsets.only(left: _side, right: _gap - iconGap),
          child: SvgPicture.asset(
            kAuthSearchIcon,
            width: _iconSize,
            height: _iconSize,
          ),
        ),
        prefixIconConstraints: BoxConstraints.tightFor(
          width: _side + _iconSize + _gap - iconGap,
          height: _height,
        ),
        border: _border(AppColors.voidBlack, 1),
        enabledBorder: _border(AppColors.voidBlack, 1),
        focusedBorder: _border(AppColors.brandNavy, 1.5),
      ),
    );
  }
}
