import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:starapp/core/config/app_config.dart';
import 'package:starapp/features/wallet/data/models/statement.dart';
import 'package:starapp/features/wallet/data/provider/wallet_providers.dart';
import 'package:starapp/features/wallet/presentation/widgets/wallet_style.dart';
import 'package:starapp/features/wallet/presentation/widgets/wallet_tile_row.dart';
import 'package:starapp/shared/widgets/star_async_view.dart';
import 'package:starapp/shared/widgets/star_icon_button.dart';
import 'package:starapp/shared/widgets/star_screen_header.dart';
import 'package:starapp/shared/widgets/star_toast.dart';
import 'package:url_launcher/url_launcher.dart';

/// Wallet — Statements, inside the Profile tab: one PDF per month. A row
/// opens its PDF outside the app; mock mode has no real file, so it shows
/// the "Saved to your files" toast instead.
class StatementsPage extends ConsumerWidget {
  const StatementsPage({super.key});

  Future<void> _download(
    BuildContext context,
    WidgetRef ref,
    Statement statement,
  ) async {
    if (ref.read(appConfigProvider).useMockData) {
      showStarToast(context, 'Saved to your files');
      return;
    }
    final uri = Uri.tryParse(statement.pdfUrl);
    var opened = false;
    if (uri != null) {
      try {
        opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
      } catch (_) {
        opened = false;
      }
    }
    if (!opened && context.mounted) {
      showStarToast(context, "Couldn't open this statement. Please try again.");
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statements = ref.watch(statementsProvider);
    final bottom = MediaQuery.paddingOf(context).bottom + 24;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: StarScreenHeader(
        title: 'Statements',
        leading: StarIconButton.back(onPressed: () => context.pop()),
      ),
      body: StarAsyncView(
        value: statements,
        onRetry: () => ref.invalidate(statementsProvider),
        builder: (statements) => ListView(
          padding: EdgeInsets.fromLTRB(24, 25, 24, bottom),
          children: [
            const WalletIntro(
              'Monthly statements for taxes and your records. Each one lists '
              'prizes, tips, Scout payments and withdrawals.',
            ),
            const SizedBox(height: 12),
            if (statements.isEmpty)
              const WalletEmptyState(
                icon: WalletIcons.fileNavy,
                title: 'No statements yet',
                message:
                    'Your first statement is ready after your first '
                    'full month of earnings.',
              ),
            for (var i = 0; i < statements.length; i++) ...[
              if (i > 0) ...[
                const SizedBox(height: 12),
                const WalletDivider(),
                const SizedBox(height: 12),
              ],
              WalletTileRow(
                icon: WalletIcons.fileNavy,
                title: DateFormat(
                  'MMMM y',
                ).format(DateTime(statements[i].year, statements[i].month)),
                subtitle:
                    'Closing balance '
                    '${formatAmount(statements[i].closingBalance)}',
                value: 'PDF',
                onTap: () => _download(context, ref, statements[i]),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
