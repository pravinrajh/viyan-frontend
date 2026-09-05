import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/errors/app_exception.dart';
import 'empty_view.dart';
import 'error_view.dart';
import 'loading_view.dart';

/// Maps Riverpod [AsyncValue] into explicit loading / data / error / empty UI.
class AsyncBody<T> extends StatelessWidget {
  const AsyncBody({
    super.key,
    required this.value,
    required this.data,
    this.isEmpty,
    this.emptyMessage = 'Nothing to show yet',
    this.emptyIcon,
    this.onRetry,
    this.loadingMessage = 'Loading',
  });

  final AsyncValue<T> value;
  final Widget Function(T data) data;
  final bool Function(T data)? isEmpty;
  final String emptyMessage;
  final IconData? emptyIcon;
  final VoidCallback? onRetry;
  final String loadingMessage;

  @override
  Widget build(BuildContext context) {
    return value.when(
      loading: () => LoadingView(message: loadingMessage),
      error: (error, _) => ErrorView(
        message: error is AppException
            ? error.message
            : 'Something went wrong. Please try again.',
        onRetry: onRetry,
      ),
      data: (loaded) {
        if (isEmpty?.call(loaded) ?? false) {
          return EmptyView(
            message: emptyMessage,
            icon: emptyIcon ?? Icons.inbox_outlined,
          );
        }
        return data(loaded);
      },
    );
  }
}
