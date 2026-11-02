import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:starapp/app/theme/app_theme.dart';
import 'package:starapp/core/models/company_summary.dart';
import 'package:starapp/core/utils/formatters.dart';
import 'package:starapp/features/messages/data/models/inbox.dart';
import 'package:starapp/features/messages/presentation/widgets/messages_avatar.dart';
import 'package:starapp/features/messages/presentation/widgets/messages_style.dart';
import 'package:starapp/shared/widgets/star_tabs.dart';

/// 46px grey search field with a leading magnifier ("Search conversations").
class InboxSearchField extends StatelessWidget {
  const InboxSearchField({
    super.key,
    required this.controller,
    required this.onChanged,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  static const _border = OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(12)),
    borderSide: BorderSide(color: AppColors.borderField),
  );

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      textInputAction: TextInputAction.search,
      style: messagesText(15, height: 22 / 15),
      decoration: InputDecoration(
        hintText: 'Search conversations',
        hintStyle: messagesText(
          15,
          height: 22 / 15,
          color: AppColors.textFaint,
        ),
        isDense: true,
        filled: true,
        fillColor: AppColors.closeButtonBg,
        constraints: const BoxConstraints(minHeight: 46),
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 16, right: 10),
          child: SvgPicture.asset(MessagesIcons.search, width: 18, height: 18),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 44),
        enabledBorder: _border,
        border: _border,
        focusedBorder: _border.copyWith(
          borderSide: const BorderSide(color: AppColors.brandBlue, width: 1.5),
        ),
      ),
    );
  }
}

/// All / Scout / Requests. "All" is this inbox; the other two open their
/// own pages, so the bar always shows "All" selected here.
class InboxSegments extends StatelessWidget {
  const InboxSegments({
    super.key,
    required this.requestCount,
    required this.onScout,
    required this.onRequests,
  });

  final int requestCount;
  final VoidCallback onScout;
  final VoidCallback onRequests;

  @override
  Widget build(BuildContext context) {
    return StarTabBar(
      tabs: [
        const StarTab(label: 'All'),
        const StarTab(label: 'Scout'),
        StarTab(
          label: 'Requests',
          count: requestCount > 0 ? requestCount : null,
        ),
      ],
      selected: 0,
      onSelected: (i) => switch (i) {
        1 => onScout(),
        2 => onRequests(),
        _ => null,
      },
    );
  }
}

/// "2 new Scout Requests" with the companies' logos.
class ScoutRequestsBanner extends StatelessWidget {
  const ScoutRequestsBanner({
    super.key,
    required this.summary,
    required this.onTap,
  });

  final InboxSummary summary;
  final VoidCallback onTap;

  static String _names(List<CompanySummary> companies, int total) {
    final names = companies.map((c) => c.name).toList();
    final others = total - names.length;
    if (names.isEmpty) return '';
    if (others > 0) return '${names.join(', ')} and $others more';
    if (names.length == 1) return names.first;
    return '${names.take(names.length - 1).join(', ')} and ${names.last}';
  }

  @override
  Widget build(BuildContext context) {
    final count = summary.pendingScoutRequests;
    final logos = summary.requestPreview.take(2).toList();
    final names = _names(logos, count);
    final radius = BorderRadius.circular(16);

    return Material(
      color: AppColors.brandTint,
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: const BorderSide(color: MessagesColors.bannerOutline),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            spacing: 12,
            children: [
              if (logos.isNotEmpty)
                SizedBox(
                  width: 36 + (logos.length - 1) * 26,
                  height: 36,
                  child: Stack(
                    children: [
                      for (var i = 0; i < logos.length; i++)
                        Positioned(
                          left: i * 26,
                          child: MessagesAvatar.company(logos[i], size: 36),
                        ),
                    ],
                  ),
                ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 2,
                  children: [
                    Text(
                      '$count new Scout Request${count == 1 ? '' : 's'}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: messagesText(
                        15,
                        weight: FontWeight.w600,
                        color: AppColors.brandBlue,
                      ),
                    ),
                    if (names.isNotEmpty)
                      Text(
                        names,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: messagesText(12, color: AppColors.textBody),
                      ),
                  ],
                ),
              ),
              SvgPicture.asset(
                MessagesIcons.chevronBrand,
                width: 20,
                height: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// One inbox row: avatar, name, last message, time, unread badge and the
/// muted mark. Unread rows are bolder with a brand time.
class ConversationRow extends StatelessWidget {
  const ConversationRow({
    super.key,
    required this.conversation,
    required this.onTap,
  });

  final ConversationSummary conversation;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = conversation;
    final unread = c.unreadCount > 0;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          spacing: 12,
          children: [
            MessagesAvatar.participant(c.counterpart, size: 52),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 3,
                children: [
                  Text(
                    c.counterpart.displayName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: messagesText(
                      15,
                      weight: unread ? FontWeight.w700 : FontWeight.w600,
                    ),
                  ),
                  Text(
                    c.lastMessagePreview,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: messagesText(
                      12,
                      color: unread ? AppColors.ink : AppColors.textSubtle,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              spacing: 6,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  spacing: 4,
                  children: [
                    if (c.isMuted)
                      Semantics(
                        label: 'Muted',
                        child: SvgPicture.asset(
                          MessagesIcons.slash,
                          width: 12,
                          height: 12,
                          colorFilter: const ColorFilter.mode(
                            AppColors.textFaint,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    Text(
                      formatAge(c.lastMessageAt),
                      style: messagesText(
                        12,
                        weight: unread && !c.isMuted
                            ? FontWeight.w600
                            : FontWeight.w400,
                        color: unread && !c.isMuted
                            ? AppColors.brandBlue
                            : AppColors.textFaint,
                      ),
                    ),
                  ],
                ),
                if (unread)
                  _UnreadBadge(count: c.unreadCount, muted: c.isMuted)
                else
                  const SizedBox(height: 20),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _UnreadBadge extends StatelessWidget {
  const _UnreadBadge({required this.count, required this.muted});

  final int count;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$count unread',
      child: Container(
        height: 20,
        constraints: const BoxConstraints(minWidth: 20),
        padding: const EdgeInsets.symmetric(horizontal: 5),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: muted ? AppColors.textFaint : AppColors.brandBlue,
          borderRadius: BorderRadius.circular(10),
        ),
        child: ExcludeSemantics(
          child: Text(
            count > 99 ? '99+' : '$count',
            style: messagesText(
              11,
              weight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
