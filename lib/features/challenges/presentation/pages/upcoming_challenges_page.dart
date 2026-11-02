import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:starapp/core/network/api_exception.dart';
import 'package:starapp/features/challenges/data/models/challenge.dart';
import 'package:starapp/features/challenges/data/provider/challenges_providers.dart';
import 'package:starapp/features/challenges/presentation/widgets/challenge_format.dart';
import 'package:starapp/features/challenges/presentation/widgets/challenge_list_tile.dart';
import 'package:starapp/shared/widgets/star_async_view.dart';
import 'package:starapp/shared/widgets/star_icon_button.dart';
import 'package:starapp/shared/widgets/star_screen_header.dart';
import 'package:starapp/shared/widgets/star_toast.dart';

/// Challenges tab page listing arenas that haven't opened yet, grouped by
/// the month they open, each with a "Remind me" toggle.
class UpcomingChallengesPage extends ConsumerWidget {
  const UpcomingChallengesPage({super.key});

  Future<void> _toggleReminder(
    BuildContext context,
    WidgetRef ref,
    Challenge challenge,
  ) async {
    try {
      final set = await ref
          .read(upcomingChallengesProvider.notifier)
          .toggleReminder(challenge.id);
      if (set && context.mounted) {
        showStarToast(context, "We'll remind you when it opens");
      }
    } catch (e) {
      if (context.mounted) showStarToast(context, describeError(e));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // The tab's bottom navigation floats over the page. The design starts the
    // list 25px below the header.
    final bottom = MediaQuery.paddingOf(context).bottom;
    final upcoming = ref.watch(upcomingChallengesProvider);

    return Scaffold(
      appBar: StarScreenHeader(
        title: 'Upcoming challenges',
        leading: StarIconButton.back(onPressed: () => context.pop()),
      ),
      body: StarAsyncView(
        value: upcoming,
        onRetry: () => ref.invalidate(upcomingChallengesProvider),
        builder: (upcoming) => SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(24, 25, 24, bottom + 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 12,
            children: [
              for (final (month, challenges) in _byMonth(upcoming)) ...[
                ChallengeListSectionTitle('Opening in $month'),
                for (final challenge in challenges)
                  ChallengeListTile(
                    icon: ChallengeListIcons.ofArena(challenge.arena),
                    title: challenge.title,
                    subtitle: joinDetails([
                      challenge.category,
                      if (challenge.opensAt case final opensAt?)
                        'opens ${formatDay(opensAt)}',
                    ]),
                    value: challenge.isReminderSet
                        ? 'Reminder set'
                        : 'Remind me',
                    onTap: () => _toggleReminder(context, ref, challenge),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// [challenges] in order, grouped under the month they open ("November").
List<(String, List<Challenge>)> _byMonth(List<Challenge> challenges) {
  final groups = <(String, List<Challenge>)>[];
  for (final challenge in challenges) {
    final opens = challenge.opensAt ?? challenge.endsAt;
    final month = DateFormat('MMMM').format(opens);
    if (groups.isNotEmpty && groups.last.$1 == month) {
      groups.last.$2.add(challenge);
    } else {
      groups.add((month, [challenge]));
    }
  }
  return groups;
}
