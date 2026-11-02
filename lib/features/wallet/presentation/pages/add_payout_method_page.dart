import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:starapp/core/network/api_exception.dart';
import 'package:starapp/features/wallet/data/models/payout_method.dart';
import 'package:starapp/features/wallet/data/provider/wallet_providers.dart';
import 'package:starapp/features/wallet/presentation/widgets/bank_picker_sheet.dart';
import 'package:starapp/features/wallet/presentation/widgets/wallet_form.dart';
import 'package:starapp/features/wallet/presentation/widgets/wallet_tile_row.dart';
import 'package:starapp/shared/widgets/star_buttons.dart';
import 'package:starapp/shared/widgets/star_icon_button.dart';
import 'package:starapp/shared/widgets/star_screen_header.dart';
import 'package:starapp/shared/widgets/star_toast.dart';

/// NGN bank accounts are 10-digit NUBANs.
const _nubanLength = 10;

/// Settings — Add Payout Method, inside the Profile tab (and full screen
/// from Withdraw via its mirror). Once a bank is chosen and the account
/// number is complete, the bank's name for the account fills in; saving is
/// possible only after that.
class AddPayoutMethodPage extends ConsumerStatefulWidget {
  const AddPayoutMethodPage({super.key});

  @override
  ConsumerState<AddPayoutMethodPage> createState() =>
      _AddPayoutMethodPageState();
}

class _AddPayoutMethodPageState extends ConsumerState<AddPayoutMethodPage> {
  final _accountNumber = TextEditingController();
  Bank? _bank;
  bool _saving = false;

  /// Errors the server returned on save, by field.
  Map<String, String> _fieldErrors = const {};

  String get _digits => _accountNumber.text.replaceAll(' ', '');

  @override
  void dispose() {
    _accountNumber.dispose();
    super.dispose();
  }

  Future<void> _pickBank() async {
    final bank = await showBankPickerSheet(context, selectedCode: _bank?.code);
    if (bank == null || !mounted) return;
    setState(() {
      _bank = bank;
      _fieldErrors = const {};
    });
  }

  Future<void> _save(Bank bank, String accountNumber) async {
    setState(() {
      _saving = true;
      _fieldErrors = const {};
    });
    try {
      await ref
          .read(payoutMethodsProvider.notifier)
          .add(bankCode: bank.code, accountNumber: accountNumber);
      if (!mounted) return;
      showStarToast(context, 'Payout method saved');
      context.pop();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        if (e is ValidationException) _fieldErrors = e.fieldErrors;
      });
      showStarToast(context, describeError(e));
    }
  }

  @override
  Widget build(BuildContext context) {
    final bank = _bank;
    final digits = _digits;
    final complete = bank != null && digits.length == _nubanLength;
    final resolved = complete
        ? ref.watch(
            resolvedAccountProvider((
              bankCode: bank.code,
              accountNumber: digits,
            )),
          )
        : null;
    final name = resolved?.value?.accountName;

    String? numberError = _fieldErrors['accountNumber'];
    if (numberError == null && resolved != null && resolved.hasError) {
      final error = resolved.error!;
      numberError = error is ValidationException
          ? error.fieldErrors['accountNumber'] ?? error.message
          : describeError(error);
    }
    final canSave = complete && name != null && !_saving;
    final bottom = MediaQuery.paddingOf(context).bottom + 24;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: StarScreenHeader(
        title: 'Add payout method',
        leading: StarIconButton.back(onPressed: () => context.pop()),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(24, 25, 24, bottom),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 12,
          children: [
            const WalletIntro(
              'Prize money and Scout payments are sent here. We verify the '
              'account name with your bank before saving.',
            ),
            WalletField(
              label: 'Bank',
              error: _fieldErrors['bankCode'],
              child: WalletFieldBox(
                value: bank?.name,
                hint: 'Choose your bank',
                semanticLabel: 'Bank',
                hasError: _fieldErrors['bankCode'] != null,
                onTap: _saving ? null : _pickBank,
              ),
            ),
            WalletField(
              label: 'Account number',
              error: numberError,
              child: WalletTextInput(
                controller: _accountNumber,
                hintText: '10-digit account number',
                hasError: numberError != null,
                keyboardType: TextInputType.number,
                inputFormatters: const [NubanFormatter()],
                onChanged: (_) => setState(() => _fieldErrors = const {}),
              ),
            ),
            WalletField(
              label: 'Account name',
              child: WalletFieldBox(
                value: name == null ? null : '$name · verified ✓',
                hint: resolved != null && resolved.isLoading
                    ? 'Checking with your bank…'
                    : 'Filled in by your bank',
                trailing: resolved != null && resolved.isLoading
                    ? const WalletFieldSpinner()
                    : null,
              ),
            ),
            StarPrimaryButton(
              label: _saving ? 'Saving…' : 'Save payout method',
              onPressed: canSave ? () => _save(bank, digits) : null,
            ),
          ],
        ),
      ),
    );
  }
}

/// Digits only, at most ten, grouped as the design shows: "0123 456 789".
class NubanFormatter extends TextInputFormatter {
  const NubanFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (digits.length > _nubanLength) {
      digits = digits.substring(0, _nubanLength);
    }
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i == 4 || i == 7) buffer.write(' ');
      buffer.write(digits[i]);
    }
    final text = buffer.toString();
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
