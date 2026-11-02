import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:starapp/app/theme/app_theme.dart';
import 'package:starapp/core/navigation/creator_navigation.dart';
import 'package:starapp/core/network/api_exception.dart';
import 'package:starapp/core/utils/formatters.dart';
import 'package:starapp/features/videos/data/models/video_comment.dart';
import 'package:starapp/features/videos/data/provider/videos_providers.dart';
import 'package:starapp/features/videos/presentation/widgets/video_style.dart';
import 'package:starapp/features/videos/presentation/widgets/videos_icons.dart';
import 'package:starapp/shared/widgets/star_async_view.dart';
import 'package:starapp/shared/widgets/star_bottom_sheet.dart';
import 'package:starapp/shared/widgets/star_image.dart';
import 'package:starapp/shared/widgets/star_toast.dart';

const _titleInk = Color(0xFF111827); // text/primary/111827
const _bodyInk = Color(0xFF1F2937); // text/body/1f2937
const _replyInk = Color(0xFF374151); // text/body/374151
const _hairline = Color(0xFFF3F4F6); // border/default/f3f4f6
const _inputFill = Color(0xFFF1F4FA); // surface/muted/f1f4fa
const _authorTint = Color(0xFFEFF6FF); // surface/brand-tint/eff6ff

/// Opens the comments sheet for one video. [count] is the video's comment
/// count from the feed; the header adds the ones the user posts.
Future<void> showVideoComments(
  BuildContext context, {
  required String videoId,
  required int count,
}) {
  return showStarSheet<void>(
    context: context,
    builder: (_) => VideoCommentsSheet(videoId: videoId, count: count),
  );
}

/// Bottom sheet listing a video's comments, with a reply/compose pill at the
/// bottom. It reads the thread from `videoCommentsProvider`, which the feed
/// keeps alive so new comments survive closing the sheet.
class VideoCommentsSheet extends ConsumerStatefulWidget {
  const VideoCommentsSheet({
    super.key,
    required this.videoId,
    required this.count,
  });

  final String videoId;

  /// The video's comment count from the feed.
  final int count;

  @override
  ConsumerState<VideoCommentsSheet> createState() => _VideoCommentsSheetState();
}

class _VideoCommentsSheetState extends ConsumerState<VideoCommentsSheet> {
  final _input = TextEditingController();
  final _focus = FocusNode();
  final _scroll = ScrollController();
  VideoComment? _replyTo;

  /// Comments whose further replies are showing.
  final _expanded = <String>{};

  /// How many replies each opened comment showed before it was opened, so
  /// "Hide replies" folds back to them.
  final _preview = <String, int>{};

  /// Comments whose next replies are loading.
  final _loadingReplies = <String>{};

  /// Set when the user posts a comment, until the list scrolls to it.
  bool _scrollToNew = false;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
  }

  @override
  void dispose() {
    _input.dispose();
    _focus.dispose();
    _scroll.dispose();
    super.dispose();
  }

  VideoCommentsNotifier get _thread =>
      ref.read(videoCommentsProvider(widget.videoId).notifier);

  static String _firstName(VideoComment comment) =>
      comment.author.name.split(' ').first;

  /// Loads the next page of comments as the list's end comes into view.
  void _onScroll() {
    if (_scroll.position.extentAfter < 200) _thread.loadMore().ignore();
  }

  /// Awaits a change to the thread and says why if it failed.
  Future<void> _guard(Future<void> change) async {
    try {
      await change;
    } catch (e) {
      if (mounted) showStarToast(context, describeError(e));
    }
  }

  void _star(VideoComment comment) {
    if (!comment.isLiked) {
      showStarToast(context, 'You gave this comment a Star');
    }
    _guard(_thread.toggleLike(comment.id));
  }

  /// Opens the author's profile over the sheet; back returns to it.
  void _openAuthor(VideoComment comment) =>
      context.pushCreator(comment.author.id);

  void _reply(VideoComment comment) {
    setState(() => _replyTo = comment);
    _focus.requestFocus();
  }

  /// Opens a comment's further replies, loading the next ones if any are
  /// left, or folds them away again.
  void _toggleMore(VideoComment comment) {
    final id = comment.id;
    final open = _expanded.contains(id);
    if (open && !_thread.hasMoreReplies(comment)) {
      setState(() => _expanded.remove(id));
      return;
    }
    setState(() {
      _expanded.add(id);
      _preview.putIfAbsent(id, () => comment.replies.length);
    });
    _loadReplies(comment);
  }

  Future<void> _loadReplies(VideoComment comment) async {
    if (!_thread.hasMoreReplies(comment) || !_loadingReplies.add(comment.id)) {
      return;
    }
    setState(() {});
    await _guard(_thread.loadReplies(comment.id));
    if (mounted) setState(() => _loadingReplies.remove(comment.id));
  }

  void _send() {
    final text = _input.text.trim();
    if (text.isEmpty) {
      _focus.requestFocus();
      return;
    }
    final target = _replyTo;
    if (target != null) {
      // Open the thread so the new reply is in view.
      _expanded.add(target.id);
      _preview.putIfAbsent(target.id, () => target.replies.length);
      _guard(_thread.post(text, replyTo: target.id));
      showStarToast(context, 'Reply sent to ${_firstName(target)}');
    } else {
      _scrollToNew = true;
      _guard(_thread.post(text));
      showStarToast(context, 'Comment posted');
    }
    _input.clear();
    setState(() => _replyTo = null);
  }

  /// Scrolls to a comment the user posted once it is in the list.
  void _onThreadChanged(
    AsyncValue<VideoCommentThread>? previous,
    AsyncValue<VideoCommentThread> next,
  ) {
    final added =
        (next.value?.comments.length ?? 0) >
        (previous?.value?.comments.length ?? 0);
    if (!_scrollToNew || !added) return;
    _scrollToNew = false;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final comments = ref.watch(videoCommentsProvider(widget.videoId));
    ref.listen(videoCommentsProvider(widget.videoId), _onThreadChanged);
    final keyboard = MediaQuery.viewInsetsOf(context).bottom;
    final safeBottom = MediaQuery.viewPaddingOf(context).bottom;
    // The design leaves 36px under the pill on a 34px-inset phone.
    final bottomGap = keyboard > 0 ? 12.0 : math.max(safeBottom + 2, 16.0);

    return Padding(
      padding: EdgeInsets.fromLTRB(1.5, 0, 1.5, keyboard),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 606.56),
        child: DecoratedBox(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
            boxShadow: [
              BoxShadow(
                color: Color(0x40000000),
                offset: Offset(0, 25),
                blurRadius: 50,
                spreadRadius: -12,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.borderMuted,
                  borderRadius: BorderRadius.circular(9999),
                ),
              ),
              const SizedBox(height: 8),
              _Header(
                title:
                    '${formatCompactCount(widget.count + (comments.value?.added ?? 0))} comments',
                onClose: () => Navigator.of(context).pop(),
              ),
              Flexible(
                child: SizedBox(
                  height: 369,
                  child: StarAsyncView(
                    value: comments,
                    onRetry: () =>
                        ref.invalidate(videoCommentsProvider(widget.videoId)),
                    builder: (thread) => ListView.separated(
                      controller: _scroll,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      itemCount: thread.comments.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 16),
                      itemBuilder: (context, i) {
                        final comment = thread.comments[i];
                        final open = _expanded.contains(comment.id);
                        return _CommentTile(
                          comment: comment,
                          replies: open
                              ? comment.replies
                              : comment.replies
                                    .take(
                                      _preview[comment.id] ??
                                          comment.replies.length,
                                    )
                                    .toList(),
                          open: open,
                          loadingReplies: _loadingReplies.contains(comment.id),
                          onStar: () => _star(comment),
                          onReply: () => _reply(comment),
                          onToggleMore: () => _toggleMore(comment),
                          onAuthor: _openAuthor,
                        );
                      },
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(16, 8, 16, bottomGap),
                child: _ComposePill(
                  controller: _input,
                  focusNode: _focus,
                  hint: _replyTo == null
                      ? 'Add a comment...'
                      : 'Reply to ${_firstName(_replyTo!)}...',
                  onSend: _send,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.title, required this.onClose});

  final String title;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 13),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: _hairline)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: videoText(
                18,
                weight: FontWeight.w500,
                color: _titleInk,
                lineHeight: 27,
                letterSpacing: -0.45,
              ),
            ),
          ),
          Tooltip(
            message: 'Close comments',
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onClose,
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: SvgPicture.asset(
                  VideosIcons.commentsClose,
                  width: 20,
                  height: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CommentTile extends StatelessWidget {
  const _CommentTile({
    required this.comment,
    required this.replies,
    required this.open,
    required this.loadingReplies,
    required this.onStar,
    required this.onReply,
    required this.onToggleMore,
    required this.onAuthor,
  });

  final VideoComment comment;

  /// The replies on show.
  final List<VideoComment> replies;

  /// Whether the replies past the first few are showing.
  final bool open;
  final bool loadingReplies;
  final VoidCallback onStar;
  final VoidCallback onReply;
  final VoidCallback onToggleMore;

  /// Opens the profile of this comment's or a reply's author.
  final ValueChanged<VideoComment> onAuthor;

  @override
  Widget build(BuildContext context) {
    final c = comment;
    // Replies not on show: folded away, or not loaded yet.
    final hidden = c.replyCount - replies.length;
    final toggle = open && (hidden <= 0 || loadingReplies)
        ? 'Hide replies'
        : hidden > 0
        ? 'View $hidden ${open ? 'more ' : ''}replies'
        : null;
    final meta = videoText(
      12,
      weight: FontWeight.w500,
      color: AppColors.textFaint,
      lineHeight: 18,
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _AuthorTap(
          comment: c,
          onTap: onAuthor,
          child: _CommentAvatar(
            name: c.author.name,
            image: c.author.avatarUrl,
            size: 36,
            ring: _hairline,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 2,
            children: [
              Row(
                children: [
                  Expanded(
                    child: _AuthorTap(
                      comment: c,
                      onTap: onAuthor,
                      child: Text(
                        c.author.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: videoText(
                          14,
                          weight: FontWeight.w500,
                          color: AppColors.voidBlack,
                          lineHeight: 17.5,
                        ),
                      ),
                    ),
                  ),
                  Semantics(
                    button: true,
                    toggled: c.isLiked,
                    label: 'Star comment',
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: onStar,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        spacing: 4,
                        children: [
                          SvgPicture.asset(
                            c.isLiked
                                ? VideosIcons.commentsStarActive
                                : VideosIcons.commentsStar,
                            width: 14,
                            height: 14,
                          ),
                          Text(
                            formatCompact(c.likes),
                            style: videoText(
                              11,
                              weight: FontWeight.w500,
                              color: AppColors.textFaint,
                              lineHeight: 16.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Text(
                c.text,
                style: videoText(14, color: _bodyInk, lineHeight: 19.25),
              ),
              Padding(
                padding: EdgeInsets.only(
                  top: 2,
                  bottom: replies.isEmpty ? 0 : 8,
                ),
                child: Row(
                  spacing: 12,
                  children: [
                    Text(formatAge(c.createdAt), style: meta),
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: onReply,
                      child: Text('Reply', style: meta),
                    ),
                  ],
                ),
              ),
              if (replies.isNotEmpty)
                Container(
                  padding: const EdgeInsets.only(left: 14),
                  decoration: const BoxDecoration(
                    border: Border(
                      left: BorderSide(color: _hairline, width: 2),
                    ),
                  ),
                  child: Column(
                    spacing: 10,
                    children: [
                      for (final r in replies)
                        _ReplyTile(reply: r, onAuthor: onAuthor),
                    ],
                  ),
                ),
              if (toggle != null)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: onToggleMore,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      spacing: 6,
                      children: [
                        Container(
                          width: 12,
                          height: 1,
                          color: AppColors.borderMuted,
                        ),
                        Text(
                          toggle,
                          style: videoText(
                            11,
                            weight: FontWeight.w600,
                            color: AppColors.textFaint,
                            lineHeight: 16.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ReplyTile extends StatelessWidget {
  const _ReplyTile({required this.reply, required this.onAuthor});

  final VideoComment reply;
  final ValueChanged<VideoComment> onAuthor;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _AuthorTap(
          comment: reply,
          onTap: onAuthor,
          child: _CommentAvatar(
            name: reply.author.name,
            image: reply.author.avatarUrl,
            size: 24,
            ring: reply.isAuthor ? videoCobaltRing : _hairline,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 2,
            children: [
              Row(
                spacing: 6,
                children: [
                  Flexible(
                    child: _AuthorTap(
                      comment: reply,
                      onTap: onAuthor,
                      child: Text(
                        reply.author.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: videoText(
                          12,
                          weight: FontWeight.w500,
                          color: AppColors.voidBlack,
                          lineHeight: 18,
                        ),
                      ),
                    ),
                  ),
                  if (reply.isAuthor)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: _authorTint,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'AUTHOR',
                        style: videoText(
                          9,
                          weight: FontWeight.w600,
                          color: videoCobalt,
                          lineHeight: 13.5,
                          letterSpacing: 0.225,
                        ),
                      ),
                    ),
                ],
              ),
              Text(
                reply.text,
                style: videoText(12, color: _replyInk, lineHeight: 18),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Makes an author's photo or name open their profile.
class _AuthorTap extends StatelessWidget {
  const _AuthorTap({
    required this.comment,
    required this.onTap,
    required this.child,
  });

  final VideoComment comment;
  final ValueChanged<VideoComment> onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: "View ${comment.author.name}'s profile",
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onTap(comment),
        child: child,
      ),
    );
  }
}

class _CommentAvatar extends StatelessWidget {
  const _CommentAvatar({
    required this.name,
    required this.image,
    required this.size,
    required this.ring,
  });

  final String name;
  final String? image;
  final double size;
  final Color ring;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.brandTint,
        boxShadow: [BoxShadow(color: ring, spreadRadius: 1)],
      ),
      clipBehavior: Clip.antiAlias,
      alignment: Alignment.center,
      child: image != null
          ? StarImage(image, width: size, height: size)
          : Text(
              name.characters.first.toUpperCase(),
              style: videoText(
                size * 0.4,
                weight: FontWeight.w600,
                color: AppColors.brandBlue,
              ),
            ),
    );
  }
}

class _ComposePill extends StatelessWidget {
  const _ComposePill({
    required this.controller,
    required this.focusNode,
    required this.hint,
    required this.onSend,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final String hint;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 11),
      decoration: BoxDecoration(
        color: _inputFill,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _hairline),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            offset: Offset(0, 1),
            blurRadius: 1,
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 3, bottom: 4),
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => onSend(),
                cursorColor: AppColors.brandBlue,
                style: videoText(14, color: _titleInk),
                decoration: InputDecoration.collapsed(
                  hintText: hint,
                  hintStyle: videoText(14, color: AppColors.textFaint),
                ),
              ),
            ),
          ),
          SvgPicture.asset(VideosIcons.commentsSmile, width: 15.5, height: 16),
          Tooltip(
            message: 'Send comment',
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onSend,
              child: SizedBox.square(
                dimension: 20,
                child: Transform.rotate(
                  angle: -math.pi / 4,
                  child: SvgPicture.asset(
                    VideosIcons.commentsSend,
                    width: 20,
                    height: 20,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
