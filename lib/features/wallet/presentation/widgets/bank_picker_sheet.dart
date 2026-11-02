import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starapp/app/theme/app_theme.dart';
import 'package:starapp/features/wallet/data/models/payout_method.dart';
import 'package:starapp/features/wallet/data/provider/wallet_providers.dart';
import 'package:starapp/features/wallet/presentation/widgets/wallet_form.dart';
import 'package:starapp/shared/widgets/star_async_view.dart';
import 'package:starapp/shared/widgets/star_bottom_sheet.dart';

/// A searchable list of banks in the app's sheet style. Pops with the
/// chosen [Bank].
Future<Bank?> showBankPickerSheet(
  BuildContext context, {
  String? selectedCode,
}) {
  return showStarSheet<Bank>(
    context: context,
    builder: (_) => _BankPicker(selectedCode: selectedCode),
  );
}

class _BankPicker extends ConsumerStatefulWidget {
  const _BankPicker({this.selectedCode});

  final String? selectedCode;

  @override
  ConsumerState<_BankPicker> createState() => _BankPickerState();
}

class _BankPickerState extends ConsumerState<_BankPicker> {
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final banks = ref.watch(banksProvider);
    final query = _search.text.trim().toLowerCase();

    return Padding(
      // Keep the list above the keyboard while searching.
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.85,
        ),
        child: StarSheet(
          title: 'Choose your bank',
          spacing: 12,
          children: [
            WalletTextInput(
              controller: _search,
              hintText: 'Search banks',
              textInputAction: TextInputAction.search,
              onChanged: (_) => setState(() {}),
            ),
            StarAsyncView(
              value: banks,
              onRetry: () => ref.invalidate(banksProvider),
              builder: (banks) {
                final matches = [
                  for (final bank in banks)
                    if (bank.name.toLowerCase().contains(query)) bank,
                ];
                if (matches.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      'No bank matches that name.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        height: 20 / 14,
                        letterSpacing: 0,
                        color: AppColors.textSubtle,
                      ),
                    ),
                  );
                }
                return Column(
                  children: [
                    for (final bank in matches)
                      WalletSheetOption(
                        label: bank.name,
                        selected: bank.code == widget.selectedCode,
                        onTap: () => Navigator.of(context).pop(bank),
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
