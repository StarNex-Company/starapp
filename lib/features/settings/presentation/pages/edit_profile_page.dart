import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:starapp/app/theme/app_theme.dart';
import 'package:starapp/core/constants/app_routes.dart';
import 'package:starapp/core/network/api_exception.dart';
import 'package:starapp/core/session/data/models/current_user.dart';
import 'package:starapp/core/session/data/provider/session_providers.dart';
import 'package:starapp/features/settings/data/models/settings.dart';
import 'package:starapp/features/settings/data/provider/settings_providers.dart';
import 'package:starapp/features/settings/presentation/widgets/add_talent_sheet.dart';
import 'package:starapp/features/settings/presentation/widgets/change_cover_sheet.dart';
import 'package:starapp/features/settings/presentation/widgets/change_photo_sheet.dart';
import 'package:starapp/features/settings/presentation/widgets/edit_profile_fields.dart';
import 'package:starapp/features/settings/presentation/widgets/edit_profile_media.dart';
import 'package:starapp/features/settings/presentation/widgets/edit_profile_media_sheet.dart';
import 'package:starapp/features/settings/presentation/widgets/edit_profile_opportunities_card.dart';
import 'package:starapp/features/settings/presentation/widgets/edit_profile_talents.dart';
import 'package:starapp/features/settings/presentation/widgets/settings_icons.dart';
import 'package:starapp/shared/widgets/star_async_view.dart';
import 'package:starapp/shared/widgets/star_icon_button.dart';
import 'package:starapp/shared/widgets/star_screen_header.dart';
import 'package:starapp/shared/widgets/star_toast.dart';

typedef _EditData = (CurrentUser, ProfileDetails, ProfileMediaPresets);

/// Edit Profile (Figma "Edit Profile" `1465:5860`, identical from Settings
/// `1613:5875`). Edits are a local draft of `currentUserProvider` and
/// `profileDetailsProvider`; the header action saves them ("Save" while there
/// are changes, "Saved" otherwise) and returns to the previous screen. Fields
/// the server rejects show its message under them.
class EditProfilePage extends ConsumerStatefulWidget {
  const EditProfilePage({super.key});

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  final _name = TextEditingController();
  final _handle = TextEditingController();
  final _bio = TextEditingController();
  final _link = TextEditingController();
  late final Listenable _fields = Listenable.merge([
    _name,
    _handle,
    _bio,
    _link,
  ]);

  // Draft of the non-text fields, seeded from the saved profile.
  String _avatar = '';
  String? _cover;
  List<String> _talents = const [];
  bool _openToOpportunities = false;

  bool _userSeeded = false;
  bool _detailsSeeded = false;
  bool _saving = false;

  /// The server's message per rejected field (`fullName`, `handle`, `bio`,
  /// `portfolioLink`), cleared as that field is edited.
  Map<String, String> _errors = const {};

  @override
  void initState() {
    super.initState();
    _clearErrorOnEdit(_name, 'fullName');
    _clearErrorOnEdit(_handle, 'handle');
    _clearErrorOnEdit(_bio, 'bio');
    _clearErrorOnEdit(_link, 'portfolioLink');
    ref.listenManual<AsyncValue<CurrentUser>>(currentUserProvider, (_, next) {
      final user = next.value;
      if (user == null || _userSeeded) return;
      _userSeeded = true;
      _name.text = user.fullName;
      _handle.text = user.handle;
      _bio.text = user.bio;
      _avatar = user.avatarUrl ?? '';
      _cover = user.coverUrl;
      _talents = [...user.talents];
    }, fireImmediately: true);
    ref.listenManual<AsyncValue<ProfileDetails>>(profileDetailsProvider, (
      _,
      next,
    ) {
      final details = next.value;
      if (details == null || _detailsSeeded) return;
      _detailsSeeded = true;
      _link.text = details.portfolioLink;
      _openToOpportunities = details.openToOpportunities;
    }, fireImmediately: true);
  }

  @override
  void dispose() {
    _name.dispose();
    _handle.dispose();
    _bio.dispose();
    _link.dispose();
    super.dispose();
  }

  void _clearErrorOnEdit(TextEditingController controller, String field) {
    var text = controller.text;
    controller.addListener(() {
      if (controller.text == text) return;
      text = controller.text;
      if (_errors.containsKey(field)) {
        setState(() => _errors = {..._errors}..remove(field));
      }
    });
  }

  void _back() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.profile);
    }
  }

  bool _isDirty(CurrentUser user, ProfileDetails details) {
    return _name.text.trim() != user.fullName ||
        _handle.text.trim() != user.handle ||
        _bio.text.trim() != user.bio ||
        _avatar != (user.avatarUrl ?? '') ||
        _cover != user.coverUrl ||
        !listEquals(_talents, user.talents) ||
        _link.text.trim() != details.portfolioLink ||
        _openToOpportunities != details.openToOpportunities;
  }

  /// [user] with the draft applied.
  CurrentUser _applyDraft(CurrentUser user) {
    return user.copyWith(
      fullName: _name.text.trim(),
      handle: _handle.text.trim(),
      avatarUrl: _avatar,
      coverUrl: _cover,
      clearCover: _cover == null,
      bio: _bio.text.trim(),
      talents: List.unmodifiable(_talents),
    );
  }

  void _warn(String message) => showStarToast(
    context,
    message,
    badge: const StarToastBadge(glyph: '!', color: AppColors.danger),
  );

  Future<void> _save(CurrentUser user, ProfileDetails details) async {
    if (_name.text.trim().isEmpty) {
      _warn('Add your display name');
      return;
    }
    if (_handle.text.trim().isEmpty) {
      _warn('Add a username');
      return;
    }
    setState(() {
      _saving = true;
      _errors = const {};
    });
    try {
      // A photo or cover picked from the device uploads first; presets are
      // already URLs.
      final uploader = ref.read(profileImageUploaderProvider);
      final avatar = await uploader.avatar(_avatar);
      final cover = await uploader.cover(_cover);
      if (!mounted) return;
      // Saved as URLs now, so a retry doesn't upload them again.
      _avatar = avatar ?? '';
      _cover = cover;
      await ref
          .read(currentUserProvider.notifier)
          .updateProfile(_applyDraft(user));
      await ref
          .read(profileDetailsProvider.notifier)
          .save(
            ProfileDetails(
              portfolioLink: _link.text.trim(),
              openToOpportunities: _openToOpportunities,
            ),
          );
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        if (error is ValidationException) _errors = error.fieldErrors;
      });
      _warn(describeError(error));
      return;
    }
    if (!mounted) return;
    setState(() => _saving = false);
    showStarToast(context, 'Changes saved');
    _back();
  }

  /// The sample after [current] in [samples] (stand-in for a picker).
  String _nextSample(List<String> samples, String? current) {
    final index = samples.indexOf(current ?? '');
    return samples[(index + 1) % samples.length];
  }

  Future<void> _changePhoto(ProfileMediaPresets media) async {
    final action = await showChangePhotoSheet(context);
    if (action == null || !mounted) return;
    switch (action) {
      case MediaSheetAction.takePhoto:
      case MediaSheetAction.chooseFromGallery:
        setState(() => _avatar = _nextSample(media.photoUrls, _avatar));
        showStarToast(context, 'Profile photo updated');
      case MediaSheetAction.remove:
        setState(() => _avatar = media.defaultPhotoUrl ?? '');
        showStarToast(context, 'Profile photo removed');
    }
  }

  Future<void> _changeCover(ProfileMediaPresets media) async {
    final action = await showChangeCoverSheet(context);
    if (action == null || !mounted) return;
    switch (action) {
      case MediaSheetAction.takePhoto:
      case MediaSheetAction.chooseFromGallery:
        setState(() => _cover = _nextSample(media.coverUrls, _cover));
        showStarToast(context, 'Cover photo updated');
      case MediaSheetAction.remove:
        setState(() => _cover = null);
        showStarToast(context, 'Cover photo removed');
    }
  }

  void _removeTalent(String talent) {
    setState(() => _talents = [..._talents]..remove(talent));
    showStarToast(context, 'Talent removed from profile');
  }

  Future<void> _addTalent() async {
    final catalogue = await ref.read(talentCatalogueProvider.future);
    if (!mounted) return;
    final picked = await showAddTalentSheet(
      context,
      catalogue: catalogue,
      selected: _talents,
    );
    if (picked == null || !mounted) return;
    setState(() => _talents = picked);
  }

  @override
  Widget build(BuildContext context) {
    final data = _combine(
      ref.watch(currentUserProvider),
      ref.watch(profileDetailsProvider),
      ref.watch(profileMediaProvider),
    );
    final loaded = data.value;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: StarScreenHeader(
        title: 'Edit profile',
        leading: StarIconButton.back(onPressed: _back),
        trailing: loaded == null
            ? null
            : ListenableBuilder(
                listenable: _fields,
                builder: (context, _) {
                  final (user, details, _) = loaded;
                  final dirty = _isDirty(user, details);
                  return _HeaderAction(
                    label: dirty ? 'Save' : 'Saved',
                    onTap: dirty && !_saving
                        ? () => _save(user, details)
                        : null,
                  );
                },
              ),
      ),
      body: StarAsyncView(
        value: data,
        onRetry: () {
          ref.invalidate(currentUserProvider);
          ref.invalidate(profileDetailsProvider);
          ref.invalidate(profileMediaProvider);
        },
        builder: (data) {
          final (_, _, media) = data;
          return _form(context, media);
        },
      ),
    );
  }

  Widget _form(BuildContext context, ProfileMediaPresets media) {
    final bottom = MediaQuery.paddingOf(context).bottom + 32;

    return SingleChildScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: EdgeInsets.fromLTRB(24, 24, 24, bottom),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 12,
        children: [
          EditProfileCover(
            image: _cover ?? media.defaultCoverUrl,
            onChange: () => _changeCover(media),
          ),
          EditProfileAvatar(
            image: _avatar,
            onChange: () => _changePhoto(media),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 16,
            children: [
              EditProfileTextField(
                label: 'Display name',
                controller: _name,
                errorText: _errors['fullName'],
                maxLength: 50,
                keyboardType: TextInputType.name,
              ),
              EditProfileTextField(
                label: 'Username',
                controller: _handle,
                errorText: _errors['handle'],
                prefixText: '@',
                maxLength: 30,
                inputFormatters: [
                  FilteringTextInputFormatter.deny(RegExp(r'[\s@]')),
                ],
              ),
              EditProfileBioField(controller: _bio, errorText: _errors['bio']),
              EditProfileTalents(
                talents: _talents,
                onRemove: _removeTalent,
                onAdd: _addTalent,
              ),
              EditProfileTextField(
                label: 'Portfolio link',
                controller: _link,
                errorText: _errors['portfolioLink'],
                prefixIcon: SettingsIcons.link,
                keyboardType: TextInputType.url,
                textInputAction: TextInputAction.done,
              ),
            ],
          ),
          EditProfileOpportunitiesCard(
            value: _openToOpportunities,
            onChanged: (value) => setState(() => _openToOpportunities = value),
          ),
        ],
      ),
    );
  }
}

AsyncValue<_EditData> _combine(
  AsyncValue<CurrentUser> user,
  AsyncValue<ProfileDetails> details,
  AsyncValue<ProfileMediaPresets> media,
) {
  if (user.hasValue && details.hasValue && media.hasValue) {
    return AsyncData((
      user.requireValue,
      details.requireValue,
      media.requireValue,
    ));
  }
  for (final value in [user, details, media]) {
    if (value.hasError) {
      return AsyncError(value.error!, value.stackTrace ?? StackTrace.empty);
    }
  }
  return const AsyncLoading();
}

/// "Save" / "Saved" text action in the header's trailing slot.
class _HeaderAction extends StatelessWidget {
  const _HeaderAction({required this.label, required this.onTap});

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: onTap != null,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              height: 20 / 14,
              letterSpacing: 0,
              fontWeight: FontWeight.w500,
              color: AppColors.brandNavy,
            ),
          ),
        ),
      ),
    );
  }
}
