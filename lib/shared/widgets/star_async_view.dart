import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starapp/app/theme/app_theme.dart';
import 'package:starapp/core/network/api_exception.dart';

/// Renders an [AsyncValue] from a feature provider: [builder] once data is
/// in, a navy spinner while loading, and the error's message (see
/// [describeError]) with a retry on error.
///
/// ```dart
/// final notifications = ref.watch(notificationsProvider);
/// return StarAsyncView(
///   value: notifications,
///   onRetry: () => ref.invalidate(notificationsProvider),
///   builder: (items) => NotificationsList(items: items),
/// );
/// ```
class StarAsyncView<T> extends StatelessWidget {
  const StarAsyncView({
    super.key,
    required this.value,
    required this.builder,
    this.onRetry,
    this.loading,
  });

  final AsyncValue<T> value;
  final Widget Function(T data) builder;
  final VoidCallback? onRetry;

  /// Replaces the default spinner, e.g. with a skeleton.
  final Widget? loading;

  @override
  Widget build(BuildContext context) {
    return value.when(
      // Keep showing the last data while a refresh is in flight.
      skipLoadingOnReload: true,
      data: builder,
      loading: () => loading ?? const _Loading(),
      error: (error, _) => _Error(error: error, onRetry: onRetry),
    );
  }
}

class _Loading extends StatelessWidget {
  const _Loading();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: SizedBox.square(
        dimension: 28,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          color: AppColors.brandNavy,
        ),
      ),
    );
  }
}

class _Error extends StatelessWidget {
  const _Error({required this.error, this.onRetry});

  final Object error;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 12,
          children: [
            Text(
              error is ApiException
                  ? describeError(error)
                  : "Couldn't load this right now.",
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                height: 1.21,
                letterSpacing: 0,
                color: AppColors.textSubtle,
              ),
            ),
            if (onRetry != null)
              TextButton(
                onPressed: onRetry,
                child: const Text(
                  'Try again',
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.21,
                    letterSpacing: 0,
                    fontWeight: FontWeight.w600,
                    color: AppColors.brandBlue,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
