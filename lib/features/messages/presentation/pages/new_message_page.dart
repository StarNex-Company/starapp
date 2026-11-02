import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:starapp/app/theme/app_theme.dart';
import 'package:starapp/core/constants/app_routes.dart';
import 'package:starapp/core/network/api_exception.dart';
import 'package:starapp/features/messages/data/models/direct_conversation.dart';
import 'package:starapp/features/messages/data/models/participant.dart';
import 'package:starapp/features/messages/data/provider/messages_providers.dart';
import 'package:starapp/features/messages/presentation/widgets/messages_style.dart';
import 'package:starapp/features/messages/presentation/widgets/recipient_row.dart';
import 'package:starapp/shared/widgets/star_async_view.dart';
import 'package:starapp/shared/widgets/star_form_fields.dart';
import 'package:starapp/shared/widgets/star_icon_button.dart';
import 'package:starapp/shared/widgets/star_screen_header.dart';
import 'package:starapp/shared/widgets/star_toast.dart';

/// Picks someone to message (Figma "Inbox — New Message"): suggestions,
/// then search results as the user types. "Message" opens the thread, or
/// sends a message request when the recipient only takes those.
///
/// With [toUserId] (a creator profile's Message button, `?to=`), it opens
/// that person's thread straight away.
class NewMessagePage extends ConsumerStatefulWidget {
  const NewMessagePage({super.key, this.toUserId});

  final String? toUserId;

  @override
  ConsumerState<NewMessagePage> createState() => _NewMessagePageState();
}

class _NewMessagePageState extends ConsumerState<NewMessagePage> {
  final _search = TextEditingController();
  Timer? _debounce;
  String _query = '';

  @override
  void initState() {
    super.initState();
    final to = widget.toUserId;
    if (to != null && to.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _message(to);
      });
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _search.dispose();
    super.dispose();
  }

  void _onSearch(String text) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 250), () {
      if (mounted) setState(() => _query = text.trim());
    });
  }

  void _back() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.messages);
    }
  }

  Future<void> _message(String userId) async {
    if (ref.read(directConversationProvider) != null) return;
    try {
      final result = await ref
          .read(directConversationProvider.notifier)
          .open(userId);
      if (!mounted) return;
      switch (result.status) {
        case DirectConversationStatus.opened:
          context.pushReplacement(
            AppRoutes.conversation(result.conversationId!),
          );
        case DirectConversationStatus.messageRequestSent:
          showStarToast(context, 'Message request sent');
          _back();
      }
    } catch (e) {
      if (mounted) showStarToast(context, describeError(e));
    }
  }

  @override
  Widget build(BuildContext context) {
    final opening = ref.watch(directConversationProvider);
    final resolvingTo = opening != null && opening == widget.toUserId;
    final bottom = MediaQuery.paddingOf(context).bottom + 24;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: StarScreenHeader(
        title: 'New message',
        leading: StarIconButton.back(onPressed: _back),
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(24, 25, 24, bottom),
        children: [
          const StarSectionLabel('To'),
          const SizedBox(height: 8),
          _ToField(
            controller: _search,
            onChanged: _onSearch,
            busy: resolvingTo,
          ),
          const SizedBox(height: 12),
          if (_query.isEmpty)
            _Suggestions(opening: opening, onMessage: _message)
          else
            _Results(query: _query, opening: opening, onMessage: _message),
        ],
      ),
    );
  }
}

class _ToField extends StatelessWidget {
  const _ToField({
    required this.controller,
    required this.onChanged,
    required this.busy,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  /// Opening the `?to=` recipient's thread.
  final bool busy;

  static const _border = OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(12)),
    borderSide: BorderSide(color: AppColors.borderField),
  );

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      enabled: !busy,
      textInputAction: TextInputAction.search,
      style: messagesText(15, height: 22 / 15),
      decoration: InputDecoration(
        hintText: busy ? 'Opening conversation…' : 'Search people',
        hintStyle: messagesText(
          15,
          height: 22 / 15,
          color: AppColors.textFaint,
        ),
        isDense: true,
        filled: true,
        fillColor: Colors.white,
        constraints: const BoxConstraints(minHeight: 52),
        contentPadding: const EdgeInsets.fromLTRB(16, 15, 16, 15),
        suffixIcon: busy
            ? const Padding(
                padding: EdgeInsets.all(17),
                child: SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.brandNavy,
                  ),
                ),
              )
            : null,
        enabledBorder: _border,
        disabledBorder: _border,
        border: _border,
        focusedBorder: _border.copyWith(
          borderSide: const BorderSide(color: AppColors.brandBlue, width: 1.5),
        ),
      ),
    );
  }
}

class _Suggestions extends ConsumerWidget {
  const _Suggestions({required this.opening, required this.onMessage});

  final String? opening;
  final ValueChanged<String> onMessage;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final suggested = ref.watch(suggestedRecipientsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 12,
      children: [
        Text(
          'Suggested',
          style: messagesText(
            18,
            weight: FontWeight.w600,
            color: AppColors.brandBlue,
          ),
        ),
        if (suggested.hasValue)
          for (final p in suggested.requireValue) _row(p)
        else
          SizedBox(
            height: 200,
            child: StarAsyncView(
              value: suggested,
              onRetry: () => ref.invalidate(suggestedRecipientsProvider),
              builder: (_) => const SizedBox.shrink(),
            ),
          ),
      ],
    );
  }

  Widget _row(Participant p) => RecipientRow(
    key: ValueKey(p.id),
    participant: p,
    busy: opening == p.id,
    onMessage: opening == null ? () => onMessage(p.id) : null,
  );
}

class _Results extends ConsumerWidget {
  const _Results({
    required this.query,
    required this.opening,
    required this.onMessage,
  });

  final String query;
  final String? opening;
  final ValueChanged<String> onMessage;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final results = ref.watch(recipientSearchProvider(query));

    return StarAsyncView(
      value: results,
      onRetry: () => ref.invalidate(recipientSearchProvider(query)),
      loading: const Padding(
        padding: EdgeInsets.only(top: 40),
        child: Center(
          child: SizedBox.square(
            dimension: 28,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: AppColors.brandNavy,
            ),
          ),
        ),
      ),
      builder: (people) => people.isEmpty
          ? Padding(
              padding: const EdgeInsets.only(top: 40),
              child: Text(
                'No one matches “$query”.',
                textAlign: TextAlign.center,
                style: messagesText(14, color: AppColors.textSubtle),
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 12,
              children: [
                for (final p in people)
                  RecipientRow(
                    key: ValueKey(p.id),
                    participant: p,
                    busy: opening == p.id,
                    onMessage: opening == null ? () => onMessage(p.id) : null,
                  ),
              ],
            ),
    );
  }
}
