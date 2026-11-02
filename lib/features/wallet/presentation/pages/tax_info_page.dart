import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:starapp/core/network/api_exception.dart';
import 'package:starapp/features/wallet/data/models/payout_settings.dart';
import 'package:starapp/features/wallet/data/provider/wallet_providers.dart';
import 'package:starapp/features/wallet/presentation/widgets/wallet_form.dart';
import 'package:starapp/features/wallet/presentation/widgets/wallet_style.dart';
import 'package:starapp/features/wallet/presentation/widgets/wallet_tile_row.dart';
import 'package:starapp/shared/widgets/star_async_view.dart';
import 'package:starapp/shared/widgets/star_bottom_sheet.dart';
import 'package:starapp/shared/widgets/star_buttons.dart';
import 'package:starapp/shared/widgets/star_icon_button.dart';
import 'package:starapp/shared/widgets/star_screen_header.dart';
import 'package:starapp/shared/widgets/star_toast.dart';

/// Countries of residence payouts are offered in, by ISO code.
const taxCountries = {
  'NG': 'Nigeria',
  'GH': 'Ghana',
  'KE': 'Kenya',
  'ZA': 'South Africa',
  'US': 'United States',
};

/// Settings — Tax Information, inside the Profile tab: TIN, legal name and
/// country of residence. Checked here first, then by the server, whose
/// field errors show under the fields.
class TaxInfoPage extends ConsumerWidget {
  const TaxInfoPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(payoutSettingsProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: StarScreenHeader(
        title: 'Tax information',
        leading: StarIconButton.back(onPressed: () => context.pop()),
      ),
      body: StarAsyncView(
        value: settings,
        onRetry: () => ref.invalidate(payoutSettingsProvider),
        builder: (settings) => _TaxForm(settings: settings),
      ),
    );
  }
}

class _TaxForm extends ConsumerStatefulWidget {
  const _TaxForm({required this.settings});

  final PayoutSettings settings;

  @override
  ConsumerState<_TaxForm> createState() => _TaxFormState();
}

class _TaxFormState extends ConsumerState<_TaxForm> {
  late final _tin = TextEditingController(text: widget.settings.taxInfo?.tin);
  late final _legalName = TextEditingController(
    text: widget.settings.taxInfo?.legalName,
  );
  late String _country = widget.settings.taxInfo?.countryCode ?? 'NG';
  bool _saving = false;
  Map<String, String> _errors = const {};

  @override
  void dispose() {
    _tin.dispose();
    _legalName.dispose();
    super.dispose();
  }

  /// The TIN as sent: digits and hyphens, spaces removed.
  String get _tinValue => _tin.text.replaceAll(' ', '');

  Map<String, String> _validate() {
    final digits = _tinValue.replaceAll('-', '');
    return {
      if (digits.length < 8 || digits.length > 15) 'tin': 'Enter a valid TIN.',
      if (_legalName.text.trim().length < 2)
        'legalName': 'Enter your name as it appears on your ID.',
      if (!taxCountries.containsKey(_country))
        'countryCode': 'Choose your country of residence.',
    };
  }

  Future<void> _pickCountry() async {
    final picked = await showStarSheet<String>(
      context: context,
      builder: (context) => StarSheet(
        title: 'Country of residence',
        children: [
          for (final MapEntry(key: code, value: name) in taxCountries.entries)
            WalletSheetOption(
              label: name,
              selected: code == _country,
              onTap: () => Navigator.of(context).pop(code),
            ),
        ],
      ),
    );
    if (picked == null || !mounted) return;
    setState(() {
      _country = picked;
      _errors = {..._errors}..remove('countryCode');
    });
  }

  Future<void> _save() async {
    final errors = _validate();
    setState(() => _errors = errors);
    if (errors.isNotEmpty) return;

    setState(() => _saving = true);
    try {
      await ref
          .read(payoutSettingsProvider.notifier)
          .saveTaxInfo(
            TaxInfo(
              tin: _tinValue,
              legalName: _legalName.text.trim(),
              countryCode: _country,
            ),
          );
      if (!mounted) return;
      showStarToast(context, 'Tax details saved');
      context.pop();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        if (e is ValidationException) _errors = e.fieldErrors;
      });
      final hasFieldErrors =
          e is ValidationException && e.fieldErrors.keys.any(_fields.contains);
      if (!hasFieldErrors) showStarToast(context, describeError(e));
    }
  }

  static const _fields = {'tin', 'legalName', 'countryCode'};

  void _clear(String field) {
    if (_errors.containsKey(field)) {
      setState(() => _errors = {..._errors}..remove(field));
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom + 24;
    final threshold = formatAmount(widget.settings.taxThreshold);

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(24, 25, 24, bottom),
      child: AutofillGroup(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 12,
          children: [
            WalletIntro(
              'Needed once your yearly payouts pass $threshold. We never '
              "share it outside Star App's payment partner.",
            ),
            WalletField(
              label: 'Tax ID (TIN)',
              error: _errors['tin'],
              child: WalletTextInput(
                controller: _tin,
                hintText: 'Your taxpayer ID',
                hasError: _errors['tin'] != null,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9 -]')),
                  LengthLimitingTextInputFormatter(20),
                ],
                onChanged: (_) => _clear('tin'),
              ),
            ),
            WalletField(
              label: 'Legal name',
              error: _errors['legalName'],
              child: WalletTextInput(
                controller: _legalName,
                hintText: 'As it appears on your ID',
                hasError: _errors['legalName'] != null,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.name],
                onChanged: (_) => _clear('legalName'),
              ),
            ),
            WalletField(
              label: 'Country of residence',
              error: _errors['countryCode'],
              child: WalletFieldBox(
                value: taxCountries[_country],
                hint: 'Choose your country',
                semanticLabel: 'Country of residence',
                hasError: _errors['countryCode'] != null,
                onTap: _saving ? null : _pickCountry,
              ),
            ),
            StarPrimaryButton(
              label: _saving ? 'Saving…' : 'Save tax details',
              onPressed: _saving ? null : _save,
            ),
          ],
        ),
      ),
    );
  }
}
