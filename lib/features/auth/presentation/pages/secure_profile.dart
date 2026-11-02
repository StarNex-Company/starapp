import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:starapp/app/theme/app_theme.dart';
import 'package:starapp/core/constants/app_routes.dart';
import 'package:starapp/features/auth/data/provider/auth_providers.dart';
import 'package:starapp/features/auth/presentation/widgets/auth_kit.dart';

// lets-icons:date-fill and uil:arrow (rotated -90°) from the Figma field.
const _calendarIcon = 'assets/vectors/auth_calendar.svg';
const _upDownIcon = 'assets/vectors/auth_chevron_up_down.svg';

/// Light green of the unmet password rule (galaxy-green, faded).
const _ruleOff = Color(0xFF7CC899);

/// Registration step 3 of 4 — "Secure Your Profile" (Figma `216:408`).
///
/// Username (green tick once it's valid and free), date of birth (read-only,
/// opens a navy Material 3 date picker — Figma "Modal date picker" `403:2419`)
/// and password with the "at least 8 characters with letters and numbers"
/// rule. The username's availability is checked with the auth repository as
/// you type. Continue validates, records the username and date of birth in
/// `registrationProvider` and pushes [AppRoutes.registerPhoto].
class SecureProfileScreen extends ConsumerStatefulWidget {
  const SecureProfileScreen({super.key});

  @override
  ConsumerState<SecureProfileScreen> createState() =>
      _SecureProfileScreenState();
}

class _SecureProfileScreenState extends ConsumerState<SecureProfileScreen> {
  static final _usernamePattern = RegExp(r'^[A-Za-z0-9_]+$');
  static final _hasLetter = RegExp('[A-Za-z]');
  static final _hasDigit = RegExp(r'\d');

  final _formKey = GlobalKey<FormState>();
  final _usernameCtrl = TextEditingController();
  final _dobCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  // The date field is tap-only: it never takes focus or shows a caret.
  final _dobFocus = FocusNode(canRequestFocus: false, skipTraversal: true);

  DateTime? _dob;
  bool _submitted = false;

  /// The last username the availability check answered for, and its answer.
  String? _checkedUsername;
  bool _checkedAvailable = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Keep the shown date in the current locale's month names.
    if (_dob != null) _dobCtrl.text = _formatDate(_dob!);
  }

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _dobCtrl.dispose();
    _passwordCtrl.dispose();
    _dobFocus.dispose();
    super.dispose();
  }

  String get _username => _usernameCtrl.text.trim();

  /// Whether the check has answered for the username as typed now.
  bool get _usernameChecked => _checkedUsername == _username;

  bool get _usernameTaken => _usernameChecked && !_checkedAvailable;

  /// Well-formed and reported free by the availability check.
  bool get _usernameAvailable =>
      _validateUsername(_username) == null &&
      _usernameChecked &&
      _checkedAvailable;

  void _onUsernameChanged(String _) {
    setState(() {});
    _checkUsername();
  }

  /// Asks the repository whether the (well-formed) username is free.
  Future<void> _checkUsername() async {
    final username = _username;
    if (_validateUsername(username) != null) return;
    final available = await ref
        .read(authRepositoryProvider)
        .checkUsername(username);
    // Drop answers for text that has since changed.
    if (!mounted || username != _username) return;
    setState(() {
      _checkedUsername = username;
      _checkedAvailable = available;
    });
  }

  bool get _passwordOk {
    final v = _passwordCtrl.text;
    return v.length >= 8 && _hasLetter.hasMatch(v) && _hasDigit.hasMatch(v);
  }

  static String? _validateUsername(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Choose a username';
    if (v.length < 3) return 'Use at least 3 characters';
    if (!_usernamePattern.hasMatch(v)) {
      return 'Use only letters, numbers and underscores';
    }
    return null;
  }

  String _formatDate(DateTime date) {
    final tag = Localizations.localeOf(context).toLanguageTag();
    final locale = DateFormat.localeExists(tag) ? tag : 'en';
    return DateFormat('d MMMM, y', locale).format(date);
  }

  Future<void> _pickDate() async {
    FocusScope.of(context).unfocus();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final picked = await showDatePicker(
      context: context,
      initialDate: _dob ?? DateTime(today.year - 18, today.month, today.day),
      firstDate: DateTime(1900),
      lastDate: today,
      builder: (context, child) => _DatePickerTheme(child: child!),
    );
    if (picked == null || !mounted) return;
    setState(() {
      _dob = picked;
      _dobCtrl.text = _formatDate(picked);
    });
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    setState(() => _submitted = true);
    final valid = _formKey.currentState?.validate() ?? false;
    final dob = _dob;
    if (!valid || dob == null || !_passwordOk) return;
    if (!_usernameChecked) await _checkUsername();
    if (!mounted || !_usernameAvailable) return;
    ref
        .read(registrationProvider.notifier)
        .setProfile(username: _username, dateOfBirth: dob);
    context.push(AppRoutes.registerPhoto);
  }

  @override
  Widget build(BuildContext context) {
    final showUsernameTick = _usernameAvailable;
    return AuthScaffold(
      step: 3,
      footer: AuthFooterLink(
        prompt: 'Already have an account?',
        action: 'Login here',
        onTap: () => context.go(AppRoutes.signIn),
      ),
      child: Form(
        key: _formKey,
        autovalidateMode: _submitted
            ? AutovalidateMode.onUserInteraction
            : AutovalidateMode.disabled,
        child: AutofillGroup(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const AuthHeading(
                title: 'Secure Your Profile',
                subtitle:
                    'Set up your profile details and choose how people '
                    'will find you.',
              ),
              const SizedBox(height: 20),
              AuthTextField(
                label: 'Username',
                hint: 'Choose a username',
                icon: AuthAssets.person,
                controller: _usernameCtrl,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.newUsername],
                inputFormatters: [
                  FilteringTextInputFormatter.deny(RegExp(r'\s')),
                ],
                maxLength: 30,
                validator: _validateUsername,
                // The (mock) availability check runs as you type.
                errorText:
                    _validateUsername(_username) == null && _usernameTaken
                    ? 'This username is already taken'
                    : null,
                onChanged: _onUsernameChanged,
                trailing: showUsernameTick
                    ? Semantics(
                        label: 'Username available',
                        child: SvgPicture.asset(
                          AuthAssets.fieldCheck,
                          width: 22,
                          height: 22,
                        ),
                      )
                    : null,
              ),
              const SizedBox(height: 20),
              AuthTextField(
                label: 'Date of Birth',
                hint: 'Select your date of birth',
                icon: _calendarIcon,
                controller: _dobCtrl,
                focusNode: _dobFocus,
                readOnly: true,
                onTap: _pickDate,
                onTrailingTap: _pickDate,
                validator: AuthValidators.required('Select your date of birth'),
                trailing: SvgPicture.asset(_upDownIcon, width: 22, height: 22),
              ),
              const SizedBox(height: 20),
              AuthPasswordField(
                label: 'Password',
                hint: 'Create a password',
                controller: _passwordCtrl,
                autofillHints: const [AutofillHints.newPassword],
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Enter a password' : null,
                onChanged: (_) => setState(() {}),
                onFieldSubmitted: (_) => _submit(),
              ),
              const SizedBox(height: 10),
              _PasswordRule(
                met: _passwordOk,
                error:
                    _submitted && !_passwordOk && _passwordCtrl.text.isNotEmpty,
              ),
              const SizedBox(height: 25),
              AuthPrimaryButton(label: 'Continue', onPressed: _submit),
            ],
          ),
        ),
      ),
    );
  }
}

/// "✓ Use at least 8 characters with letters and numbers": 17px tick (2px
/// gap) + 10 Regular #000207. Green when met, faded green while unmet, red
/// after a failed Continue.
class _PasswordRule extends StatelessWidget {
  const _PasswordRule({required this.met, required this.error});

  final bool met;
  final bool error;

  @override
  Widget build(BuildContext context) {
    final Color? tint = met ? null : (error ? AppColors.authError : _ruleOff);
    return Semantics(
      liveRegion: true,
      label: met ? 'Password requirement met' : 'Password requirement not met',
      child: Row(
        children: [
          SvgPicture.asset(
            AuthAssets.fieldCheck,
            width: 17,
            height: 17,
            colorFilter: tint == null
                ? null
                : ColorFilter.mode(tint, BlendMode.srcIn),
          ),
          const SizedBox(width: 2),
          Flexible(
            child: Text(
              'Use at least 8 characters with letters and numbers',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 10,
                fontWeight: FontWeight.w400,
                height: 1.21,
                letterSpacing: 0,
                color: error ? AppColors.authError : AppColors.voidBlack,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Navy take on the Material 3 "Modal date picker" (`403:2419` / `403:4850`):
/// same layout (Select date / headline / month-year toggle / grid /
/// Cancel–OK), brand navy instead of the M3 baseline purple, Inter type.
class _DatePickerTheme extends StatelessWidget {
  const _DatePickerTheme({required this.child});

  final Widget child;

  static TextStyle _inter(double size, FontWeight weight, double lineHeight) =>
      TextStyle(
        fontFamily: 'Inter',
        fontSize: size,
        fontWeight: weight,
        height: lineHeight / size,
        letterSpacing: 0,
      );

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context);
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.brandNavy,
      primary: AppColors.brandNavy,
      onPrimary: Colors.white,
      onSurface: AppColors.voidBlack,
    );
    final label = _inter(14, FontWeight.w500, 20);
    final body = _inter(16, FontWeight.w400, 24);
    final buttonStyle = TextButton.styleFrom(
      foregroundColor: AppColors.brandNavy,
      textStyle: label,
    );
    return Theme(
      data: base.copyWith(
        colorScheme: scheme,
        textTheme: base.textTheme.copyWith(
          titleSmall: label, // "May 2026" month/year toggle
          bodyLarge: body,
          labelLarge: label,
        ),
        textButtonTheme: TextButtonThemeData(style: buttonStyle),
        datePickerTheme: DatePickerThemeData(
          backgroundColor: scheme.surfaceContainerHigh,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          // Drives both "Select date" and the headline; the design's headline
          // is the dark on-surface colour.
          headerForegroundColor: AppColors.voidBlack,
          headerHelpStyle: label,
          headerHeadlineStyle: _inter(
            32,
            FontWeight.w400,
            40,
          ).copyWith(color: AppColors.voidBlack),
          weekdayStyle: body,
          dayStyle: body,
          yearStyle: body,
          dividerColor: scheme.outlineVariant,
          cancelButtonStyle: buttonStyle,
          confirmButtonStyle: buttonStyle,
        ),
      ),
      child: child,
    );
  }
}
