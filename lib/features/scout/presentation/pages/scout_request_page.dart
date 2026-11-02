import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:starapp/app/theme/app_theme.dart';
import 'package:starapp/core/constants/app_routes.dart';
import 'package:starapp/core/models/attachment.dart';
import 'package:starapp/core/models/company_summary.dart';
import 'package:starapp/core/navigation/tab_navigation.dart';
import 'package:starapp/core/network/api_exception.dart';
import 'package:starapp/core/utils/formatters.dart';
import 'package:starapp/features/scout/data/models/scout_request.dart';
import 'package:starapp/features/scout/data/provider/scout_providers.dart';
import 'package:starapp/features/scout/presentation/widgets/scout_style.dart';
import 'package:starapp/features/scout/presentation/widgets/scout_widgets.dart';
import 'package:starapp/shared/widgets/star_async_view.dart';
import 'package:starapp/shared/widgets/star_bottom_bar.dart';
import 'package:starapp/shared/widgets/star_buttons.dart';
import 'package:starapp/shared/widgets/star_form_fields.dart';
import 'package:starapp/shared/widgets/star_icon_button.dart';
import 'package:starapp/shared/widgets/star_image.dart';
import 'package:starapp/shared/widgets/star_screen_header.dart';
import 'package:starapp/shared/widgets/star_toast.dart';

const _reportedMessage = 'Reported · our team will review this request';

enum _Action { accept, ask }

/// Scout Request (Figma "Scout — Request Received"), full screen on the
/// root navigator: the company, the Stars bonus, the role, the recruiter's
/// message with attachments, and Decline / Ask / Accept. Answered and
/// expired requests are read-only. Links into the Messages tab go through
/// `pushInTab`.
class ScoutRequestPage extends ConsumerStatefulWidget {
  const ScoutRequestPage({super.key, required this.requestId});

  final String requestId;

  @override
  ConsumerState<ScoutRequestPage> createState() => _ScoutRequestPageState();
}

class _ScoutRequestPageState extends ConsumerState<ScoutRequestPage> {
  _Action? _busy;

  ScoutRequestNotifier get _notifier =>
      ref.read(scoutRequestProvider(widget.requestId).notifier);

  void _openCompany(CompanySummary company) =>
      context.pushInTab(AppRoutes.company(company.id));

  void _openConversation(String id) => context.push(AppRoutes.conversation(id));

  /// Accept or Ask: both wait for the conversation, then open it.
  Future<void> _run(_Action action) async {
    if (_busy != null) return;
    setState(() => _busy = action);
    try {
      final conversationId = await switch (action) {
        _Action.accept => _notifier.accept(),
        _Action.ask => _notifier.ask(),
      };
      if (mounted) _openConversation(conversationId);
    } catch (e) {
      if (mounted) showStarToast(context, describeError(e));
    } finally {
      if (mounted) setState(() => _busy = null);
    }
  }

  Future<void> _decline() async {
    final declining = _notifier.decline();
    showStarToast(context, 'Request declined');
    try {
      await declining;
    } catch (e) {
      if (mounted) showStarToast(context, describeError(e));
    }
  }

  Future<void> _report() async {
    final reporting = _notifier.report();
    showStarToast(context, _reportedMessage);
    try {
      await reporting;
    } catch (e) {
      if (mounted) showStarToast(context, describeError(e));
    }
  }

  @override
  Widget build(BuildContext context) {
    final request = ref.watch(scoutRequestProvider(widget.requestId));
    final loaded = request.value;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: StarScreenHeader(
        title: 'Scout Request',
        leading: StarIconButton.back(
          onPressed: () => scoutBack(context, AppRoutes.messageRequests),
        ),
        trailing: loaded == null
            ? null
            : StarIconButton(
                icon: ScoutIcons.flag,
                tooltip: 'Report',
                onPressed: _report,
              ),
      ),
      bottomNavigationBar: loaded == null
          ? null
          : _ActionBar(
              request: loaded,
              busy: _busy,
              onDecline: _decline,
              onAsk: () => _run(_Action.ask),
              onAccept: () => _run(_Action.accept),
              onOpenConversation: _openConversation,
            ),
      body: StarAsyncView(
        value: request,
        onRetry: () => ref.invalidate(scoutRequestProvider(widget.requestId)),
        builder: (r) => ListView(
          padding: const EdgeInsets.fromLTRB(24, 25, 24, 24),
          children: [
            for (final child in _content(r)) ...[
              child,
              const SizedBox(height: 16),
            ],
          ],
        ),
      ),
    );
  }

  List<Widget> _content(ScoutRequest r) => [
    _CompanyCard(company: r.company, onTap: () => _openCompany(r.company)),
    if (r.starsBonus > 0)
      ScoutNotice(
        icon: ScoutIcons.sparkle,
        title: '+${formatGrouped(r.starsBonus)} Stars · company interest',
        body:
            'A verified company scouted you, so we added a bonus to your '
            'Star count.',
        background: ScoutColors.starsTint,
        titleColor: AppColors.goldText,
      ),
    const StarSectionLabel('Role offered'),
    Text(
      r.roleTitle,
      style: scoutText(20, weight: FontWeight.w700, height: 26 / 20),
    ),
    _Details(request: r),
    const StarSectionLabel('Message'),
    _MessageCard(
      request: r,
      onSender: () => _openCompany(r.company),
      onAttachment: (a) => context.pushInTab(AppRoutes.attachment(a.id)),
    ),
    const ScoutNotice(
      icon: ScoutIcons.shieldAmber,
      title: 'Stay safe',
      body:
          'Never pay to apply or share bank PINs. Star App and real '
          'companies will never ask for them.',
      background: ScoutColors.amberTint,
      titleColor: ScoutColors.amberText,
    ),
  ];
}

/// Banner, logo, name, and the company's record as pills.
class _CompanyCard extends ConsumerWidget {
  const _CompanyCard({required this.company, required this.onTap});

  final CompanySummary company;
  final VoidCallback onTap;

  static const _radius = BorderRadius.all(Radius.circular(20));

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Artists signed and creators hired come with the company page.
    final details = ref.watch(companyProvider(company.id)).value;
    final line = [
      company.type,
      company.locationLabel,
      if (details != null && details.artistsSignedCount > 0)
        '${formatGrouped(details.artistsSignedCount)} artists signed',
    ].where((p) => p.isNotEmpty).join(' · ');
    final hired = details?.creatorsHiredCount ?? 0;

    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: _radius,
        boxShadow: [
          BoxShadow(
            color: Color(0x0F0B1020),
            offset: Offset(0, 4),
            blurRadius: 18,
          ),
        ],
      ),
      child: Material(
        color: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: _radius,
          side: BorderSide(color: AppColors.borderField),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    height: 84,
                    child: ClipRect(
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: ScoutColors.logoGradient(
                                company.id,
                                degrees: 166.32,
                                size: const Size(345, 84),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 8,
                            right: 10,
                            child: SvgPicture.asset(ScoutIcons.bannerLogo),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 10,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 73, top: 3),
                          child: CompanyNameRow(
                            company: company,
                            badgeSize: 18,
                            gap: 6,
                            style: scoutText(19, weight: FontWeight.w700),
                          ),
                        ),
                        if (line.isNotEmpty)
                          Text(
                            line,
                            style: scoutText(13, color: AppColors.textSubtle),
                          ),
                        if (company.isVerified || hired > 0)
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: [
                              if (company.isVerified)
                                const _Pill(
                                  label: 'Verified company',
                                  icon: ScoutIcons.shieldCheck,
                                  background: AppColors.successTint,
                                  color: ScoutColors.successText,
                                ),
                              if (hired > 0)
                                _Pill(
                                  label:
                                      'Hired ${formatGrouped(hired)} '
                                      '${hired == 1 ? 'creator' : 'creators'}',
                                  background: AppColors.brandTint,
                                  color: AppColors.brandBlue,
                                ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              Positioned(
                left: 15,
                top: 51,
                child: CompanyLogo(
                  company: company,
                  size: 64,
                  radius: 18,
                  border: 4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({
    required this.label,
    required this.background,
    required this.color,
    this.icon,
  });

  final String label;
  final Color background;
  final Color color;
  final String? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 24,
      padding: const EdgeInsets.symmetric(horizontal: 9),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 4,
        children: [
          if (icon != null) ScoutSvg(icon!, box: 11),
          Text(
            label,
            style: scoutText(11, weight: FontWeight.w600, color: color),
          ),
        ],
      ),
    );
  }
}

/// Budget, shoot dates, location and contract in a 2×2 grid.
class _Details extends StatelessWidget {
  const _Details({required this.request});

  final ScoutRequest request;

  @override
  Widget build(BuildContext context) {
    final days = request.contractDays;
    final contract = [
      request.isPaid ? 'Paid' : 'Unpaid',
      if (days > 0) '$days ${days == 1 ? 'day' : 'days'}',
    ].join(' · ');

    Widget pair(Widget a, Widget b) => IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 10,
        children: [
          Expanded(child: a),
          Expanded(child: b),
        ],
      ),
    );

    return Column(
      spacing: 10,
      children: [
        pair(
          _DetailTile(
            icon: ScoutIcons.wallet14,
            label: 'Budget',
            value: request.budget.format(),
          ),
          // The design's calendar glyph is an add-to-calendar button; with
          // no calendar integration it is left out.
          _DetailTile(
            label: 'Shoot dates',
            value: formatDateRange(request.shootStart, request.shootEnd),
          ),
        ),
        pair(
          _DetailTile(
            icon: ScoutIcons.pin14,
            label: 'Location',
            value: request.location,
          ),
          _DetailTile(
            icon: ScoutIcons.file14,
            label: 'Contract',
            value: contract,
          ),
        ),
      ],
    );
  }
}

class _DetailTile extends StatelessWidget {
  const _DetailTile({required this.label, required this.value, this.icon});

  final String label;
  final String value;
  final String? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.brandTintSoft,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderField),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 6,
        children: [
          Row(
            spacing: 6,
            children: [
              if (icon != null) ScoutSvg(icon!, box: 14),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: scoutText(12, color: AppColors.textSubtle),
                ),
              ),
            ],
          ),
          Text(value, style: scoutText(15, weight: FontWeight.w600)),
        ],
      ),
    );
  }
}

/// The recruiter, their note, and the files they attached.
class _MessageCard extends StatelessWidget {
  const _MessageCard({
    required this.request,
    required this.onSender,
    required this.onAttachment,
  });

  final ScoutRequest request;
  final VoidCallback onSender;
  final ValueChanged<Attachment> onAttachment;

  @override
  Widget build(BuildContext context) {
    final byline = [
      request.senderTitle,
      formatAgo(request.sentAt),
    ].where((p) => p.isNotEmpty).join(' · ');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderField),
        boxShadow: const [ScoutColors.cardShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 10,
        children: [
          Semantics(
            button: true,
            child: InkWell(
              onTap: onSender,
              borderRadius: BorderRadius.circular(8),
              child: Row(
                spacing: 12,
                children: [
                  StarAvatar(request.senderAvatarUrl, size: 36),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 3,
                      children: [
                        Text(
                          request.senderName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: scoutText(14, weight: FontWeight.w600),
                        ),
                        Text(
                          byline,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: scoutText(12, color: AppColors.textSubtle),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (request.message.isNotEmpty)
            Text(
              request.message,
              style: scoutText(14, color: AppColors.textBody, height: 21 / 14),
            ),
          for (final attachment in request.attachments)
            _AttachmentRow(
              attachment: attachment,
              onTap: () => onAttachment(attachment),
            ),
        ],
      ),
    );
  }
}

class _AttachmentRow extends StatelessWidget {
  const _AttachmentRow({required this.attachment, required this.onTap});

  final Attachment attachment;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final details = [
      if (attachment.sizeBytes > 0) attachment.sizeLabel,
      if (attachment.extension.isNotEmpty) attachment.extension,
    ].join(' · ');

    return Semantics(
      button: true,
      child: Material(
        color: AppColors.closeButtonBg,
        borderRadius: BorderRadius.circular(12),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              spacing: 12,
              children: [
                const ScoutIconTile(
                  icon: ScoutIcons.fileRed,
                  background: AppColors.dangerTint,
                  iconBox: 18,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 3,
                    children: [
                      Text(
                        attachment.fileName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: scoutText(13, weight: FontWeight.w600),
                      ),
                      if (details.isNotEmpty)
                        Text(
                          details,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: scoutText(12, color: AppColors.textSubtle),
                        ),
                    ],
                  ),
                ),
                SvgPicture.asset(ScoutIcons.download),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Decline / Ask / Accept while pending; "Open conversation" once
/// accepted; a quiet status line when declined or expired.
class _ActionBar extends StatelessWidget {
  const _ActionBar({
    required this.request,
    required this.busy,
    required this.onDecline,
    required this.onAsk,
    required this.onAccept,
    required this.onOpenConversation,
  });

  final ScoutRequest request;
  final _Action? busy;
  final VoidCallback onDecline;
  final VoidCallback onAsk;
  final VoidCallback onAccept;
  final ValueChanged<String> onOpenConversation;

  @override
  Widget build(BuildContext context) {
    final conversationId = request.conversationId;
    final child = switch (request.status) {
      ScoutRequestStatus.pending => Row(
        spacing: 12,
        children: [
          Expanded(
            flex: 96,
            child: _BarButton(
              label: 'Decline',
              style: _BarStyle.danger,
              onPressed: busy == null ? onDecline : null,
            ),
          ),
          Expanded(
            flex: 96,
            child: _BarButton(
              label: 'Ask',
              icon: ScoutIcons.message,
              style: _BarStyle.outlined,
              busy: busy == _Action.ask,
              onPressed: busy == null ? onAsk : null,
            ),
          ),
          Expanded(
            flex: 129,
            child: _BarButton(
              label: 'Accept',
              icon: ScoutIcons.check,
              style: _BarStyle.primary,
              busy: busy == _Action.accept,
              onPressed: busy == null ? onAccept : null,
            ),
          ),
        ],
      ),
      ScoutRequestStatus.accepted => StarPrimaryButton(
        label: 'Open conversation',
        onPressed: conversationId == null
            ? null
            : () => onOpenConversation(conversationId),
      ),
      ScoutRequestStatus.declined => const _StatusLine(
        'You declined this request',
      ),
      ScoutRequestStatus.expired => const _StatusLine(
        'This request has expired',
      ),
    };
    return StarBottomBar(child: child);
  }
}

class _StatusLine extends StatelessWidget {
  const _StatusLine(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: Center(
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: scoutText(
            14,
            weight: FontWeight.w500,
            color: AppColors.textSubtle,
          ),
        ),
      ),
    );
  }
}

enum _BarStyle { danger, outlined, primary }

class _BarButton extends StatelessWidget {
  const _BarButton({
    required this.label,
    required this.style,
    required this.onPressed,
    this.icon,
    this.busy = false,
  });

  final String label;
  final _BarStyle style;
  final VoidCallback? onPressed;
  final String? icon;
  final bool busy;

  static const _radius = BorderRadius.all(Radius.circular(12));

  @override
  Widget build(BuildContext context) {
    final color = switch (style) {
      _BarStyle.danger => AppColors.danger,
      _BarStyle.outlined => AppColors.brandBlue,
      _BarStyle.primary => Colors.white,
    };
    final content = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: 8,
      children: [
        if (busy)
          ScoutSpinner(color: color)
        else if (icon != null)
          SvgPicture.asset(icon!),
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: scoutText(15, weight: FontWeight.w600, color: color),
          ),
        ),
      ],
    );

    return Opacity(
      opacity: onPressed == null && !busy ? 0.6 : 1,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: switch (style) {
            _BarStyle.danger => AppColors.dangerTint,
            _BarStyle.outlined => Colors.white,
            _BarStyle.primary => null,
          },
          gradient: style == _BarStyle.primary ? AppColors.brandGradient : null,
          borderRadius: _radius,
          border: style == _BarStyle.outlined
              ? Border.all(color: AppColors.brandBlue, width: 1.5)
              : null,
          boxShadow: style == _BarStyle.primary
              ? const [
                  BoxShadow(
                    color: Color(0x2E032886),
                    offset: Offset(0, 6),
                    blurRadius: 8,
                  ),
                ]
              : null,
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            borderRadius: _radius,
            onTap: onPressed,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: content,
            ),
          ),
        ),
      ),
    );
  }
}
