import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:starapp/app/theme/app_theme.dart';
import 'package:starapp/core/constants/app_routes.dart';
import 'package:starapp/core/utils/formatters.dart';
import 'package:starapp/features/scout/data/provider/scout_providers.dart';
import 'package:starapp/features/scout/presentation/widgets/scout_style.dart';
import 'package:starapp/features/scout/presentation/widgets/scout_widgets.dart';
import 'package:starapp/shared/widgets/star_async_view.dart';
import 'package:starapp/shared/widgets/star_icon_button.dart';
import 'package:starapp/shared/widgets/star_screen_header.dart';

/// Scout Requests (Figma "Inbox — Requests"), inside the Messages tab:
/// pending requests from verified companies, each opening full screen.
class ScoutRequestsPage extends ConsumerWidget {
  const ScoutRequestsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requests = ref.watch(scoutRequestsProvider);
    final bottom = MediaQuery.paddingOf(context).bottom + 24;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: StarScreenHeader(
        title: 'Requests',
        leading: StarIconButton.back(
          onPressed: () => scoutBack(context, AppRoutes.messages),
        ),
      ),
      body: StarAsyncView(
        value: requests,
        onRetry: () => ref.invalidate(scoutRequestsProvider),
        builder: (items) {
          final pending = [
            for (final r in items)
              if (r.isPending) r,
          ];
          return RefreshIndicator(
            color: AppColors.brandNavy,
            onRefresh: () => ref.refresh(scoutRequestsProvider.future),
            child: ListView(
              padding: EdgeInsets.fromLTRB(24, 25, 24, bottom),
              children: [
                Text(
                  'Scout Requests from verified companies. Accept to start a '
                  'conversation.',
                  style: scoutText(
                    14,
                    color: AppColors.authTextSecondary,
                    height: 22 / 14,
                  ),
                ),
                const SizedBox(height: 12),
                if (pending.isEmpty)
                  const ScoutEmptyState('No Scout Requests right now.')
                else
                  ...withDividers([
                    for (final r in pending)
                      ScoutListRow(
                        key: ValueKey(r.id),
                        icon: ScoutIcons.briefcase,
                        title: r.company.name,
                        subtitle: r.roleTitle,
                        value: r.isNew ? 'New' : formatAge(r.sentAt),
                        onTap: () => context.push(AppRoutes.scoutRequest(r.id)),
                      ),
                  ]).expand((w) => [w, const SizedBox(height: 12)]),
              ],
            ),
          );
        },
      ),
    );
  }
}
