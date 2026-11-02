import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:starapp/app/theme/app_theme.dart';
import 'package:starapp/core/constants/app_routes.dart';
import 'package:starapp/core/network/api_exception.dart';
import 'package:starapp/features/wallet/data/models/wallet_transaction.dart';
import 'package:starapp/features/wallet/data/provider/wallet_providers.dart';
import 'package:starapp/features/wallet/presentation/widgets/wallet_style.dart';
import 'package:starapp/features/wallet/presentation/widgets/wallet_tile_row.dart';
import 'package:starapp/shared/widgets/star_async_view.dart';
import 'package:starapp/shared/widgets/star_icon_button.dart';
import 'package:starapp/shared/widgets/star_screen_header.dart';

/// Wallet — All Activity, inside the Profile tab: every transaction grouped
/// by month. The next page loads as the end of the list comes into view.
class WalletActivityPage extends ConsumerWidget {
  const WalletActivityPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activity = ref.watch(walletActivityProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: StarScreenHeader(
        title: 'All activity',
        leading: StarIconButton.back(onPressed: () => context.pop()),
      ),
      body: StarAsyncView(
        value: activity,
        onRetry: () => ref.invalidate(walletActivityProvider),
        builder: (items) => _ActivityList(
          items: items,
          hasMore: ref.read(walletActivityProvider.notifier).hasMore,
        ),
      ),
    );
  }
}

class _ActivityList extends StatelessWidget {
  const _ActivityList({required this.items, required this.hasMore});

  final List<WalletTransaction> items;
  final bool hasMore;

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom + 24;
    if (items.isEmpty) {
      return ListView(
        padding: EdgeInsets.fromLTRB(24, 25, 24, bottom),
        children: const [
          WalletEmptyState(
            icon: WalletIcons.wallet,
            title: 'No activity yet',
            message:
                'Prizes, fan tips, Scout payments and withdrawals will show '
                'up here.',
          ),
        ],
      );
    }

    // Month headings, rows and the dividers between rows of a month.
    final now = DateTime.now();
    final entries = <Widget>[];
    DateTime? month;
    for (final t in items) {
      final m = DateTime(t.createdAt.year, t.createdAt.month);
      if (m != month) {
        month = m;
        entries.add(
          WalletSectionTitle(
            DateFormat(m.year == now.year ? 'MMMM' : 'MMMM y').format(m),
          ),
        );
      } else {
        entries.add(const WalletDivider());
      }
      entries.add(
        WalletTileRow(
          icon: transactionIcon(t.type),
          title: t.title,
          subtitle: _subtitle(t, now),
          value: formatSignedAmount(t),
          onTap: () => context.push(AppRoutes.walletTransaction(t.id)),
        ),
      );
    }
    if (hasMore) entries.add(const _LoadMore());

    return ListView.separated(
      padding: EdgeInsets.fromLTRB(24, 25, 24, bottom),
      itemCount: entries.length,
      itemBuilder: (_, i) => entries[i],
      separatorBuilder: (_, _) => const SizedBox(height: 12),
    );
  }

  /// "Oct 1 · processing" for withdrawals, "48 fans · Sep 29" otherwise.
  static String _subtitle(WalletTransaction t, DateTime now) {
    final date = formatShortDate(t.createdAt, now: now);
    if (t.type == TransactionType.withdrawal) {
      return '$date · ${transactionStatusLabel(t).toLowerCase()}';
    }
    return t.subtitle.isEmpty ? date : '${t.subtitle} · $date';
  }
}

/// Built when the end of the list comes near: fetches the next page, and
/// offers a retry if that fails.
class _LoadMore extends ConsumerStatefulWidget {
  const _LoadMore();

  @override
  ConsumerState<_LoadMore> createState() => _LoadMoreState();
}

class _LoadMoreState extends ConsumerState<_LoadMore> {
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    if (!mounted) return;
    setState(() => _error = null);
    try {
      await ref.read(walletActivityProvider.notifier).loadMore();
    } catch (e) {
      if (mounted) setState(() => _error = describeError(e));
    }
  }

  @override
  Widget build(BuildContext context) {
    final error = _error;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Center(
        child: error == null
            ? const SizedBox.square(
                dimension: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: AppColors.brandNavy,
                ),
              )
            : TextButton(
                onPressed: _load,
                child: Text(
                  '$error Try again',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 20 / 14,
                    letterSpacing: 0,
                    fontWeight: FontWeight.w600,
                    color: AppColors.brandBlue,
                  ),
                ),
              ),
      ),
    );
  }
}
