import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:starapp/app/theme/app_theme.dart';
import 'package:starapp/core/models/company_summary.dart';
import 'package:starapp/features/messages/data/models/participant.dart';
import 'package:starapp/features/messages/presentation/widgets/messages_style.dart';
import 'package:starapp/shared/widgets/star_image.dart';

/// A round picture for someone in the inbox: a creator's photo, a company's
/// logo (or its initials on a colour picked from its id), or the Star App
/// mark for the team.
class MessagesAvatar extends StatelessWidget {
  const MessagesAvatar({
    super.key,
    required this.id,
    required this.name,
    required this.kind,
    required this.size,
    this.imageUrl,
  });

  MessagesAvatar.participant(Participant p, {super.key, required this.size})
    : id = p.id,
      name = p.displayName,
      kind = p.kind,
      imageUrl = p.avatarUrl;

  MessagesAvatar.company(CompanySummary c, {super.key, required this.size})
    : id = c.id,
      name = c.name,
      kind = ParticipantKind.company,
      imageUrl = c.logoUrl;

  final String id;
  final String name;
  final ParticipantKind kind;
  final double size;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final image = imageUrl;
    if (kind == ParticipantKind.system) return _StarAppMark(size: size);
    if (kind == ParticipantKind.creator ||
        (image != null && image.isNotEmpty)) {
      return StarAvatar(image, size: size, semanticLabel: name);
    }
    return _Initials(id: id, name: name, size: size);
  }
}

/// 48px avatar for recipient rows: brand ring, 2px white gap, 40px picture.
class RingedAvatar extends StatelessWidget {
  const RingedAvatar({super.key, required this.participant});

  final Participant participant;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 48,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SvgPicture.asset(MessagesIcons.ring, width: 48, height: 48),
          SvgPicture.asset(MessagesIcons.ringGap, width: 44, height: 44),
          MessagesAvatar.participant(participant, size: 40),
        ],
      ),
    );
  }
}

class _Initials extends StatelessWidget {
  const _Initials({required this.id, required this.name, required this.size});

  final String id;
  final String name;
  final double size;

  @override
  Widget build(BuildContext context) {
    final words = name.trim().split(RegExp(r'\s+'));
    final initials = words
        .take(2)
        .map((w) => w.isEmpty ? '' : w[0])
        .join()
        .toUpperCase();
    final palette = MessagesColors.companyGradients;
    final colors =
        palette[id.codeUnits.fold(0, (a, b) => a + b) % palette.length];

    return Semantics(
      label: name,
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: colors,
          ),
        ),
        child: ExcludeSemantics(
          child: Text(
            initials,
            style: messagesText(
              size * 0.36,
              weight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

class _StarAppMark extends StatelessWidget {
  const _StarAppMark({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Star App',
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: AppColors.brandGradient,
        ),
        child: SvgPicture.asset(
          MessagesIcons.starAppLogo,
          width: size * 28 / 52,
          height: size * 25 / 52,
        ),
      ),
    );
  }
}
