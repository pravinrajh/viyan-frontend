import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/utils/date_formatters.dart';
import '../../../shared/widgets/async_body.dart';
import '../models/app_notification.dart';
import '../providers/notification_providers.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(notificationsProvider);
    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 960),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: AsyncBody<List<AppNotification>>(
              value: async,
              emptyMessage: 'You are all caught up.',
              emptyIcon: Icons.notifications_outlined,
              loadingMessage: 'Loading notifications...',
              isEmpty: (items) => items.isEmpty,
              onRetry: () => ref.read(notificationsProvider.notifier).refresh(),
              data: (items) {
                final unread = items.where((item) => !item.isRead).length;
                return RefreshIndicator(
                  onRefresh: () =>
                      ref.read(notificationsProvider.notifier).refresh(),
                  child: ListView.builder(
                    itemCount: items.length + 1,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Notifications',
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineSmall
                                          ?.copyWith(
                                            fontWeight: FontWeight.w800,
                                          ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      unread == 0
                                          ? 'You are all caught up.'
                                          : '$unread unread notification${unread == 1 ? '' : 's'}.',
                                    ),
                                  ],
                                ),
                              ),
                              if (unread > 0)
                                TextButton(
                                  onPressed: () async {
                                    try {
                                      await ref
                                          .read(notificationsProvider.notifier)
                                          .markAllRead();
                                    } on AppException catch (error) {
                                      if (!context.mounted) return;
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(content: Text(error.message)),
                                      );
                                    }
                                  },
                                  child: const Text('Mark all read'),
                                ),
                              IconButton(
                                tooltip: 'Refresh notifications',
                                onPressed: () => ref
                                    .read(notificationsProvider.notifier)
                                    .refresh(),
                                icon: const Icon(Icons.refresh),
                              ),
                            ],
                          ),
                        );
                      }
                      final item = items[index - 1];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          onTap: item.isRead
                              ? null
                              : () async {
                                  try {
                                    await ref
                                        .read(notificationsProvider.notifier)
                                        .markRead(item.id);
                                  } on AppException catch (error) {
                                    if (!context.mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(error.message)),
                                    );
                                  }
                                },
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          leading: CircleAvatar(
                            backgroundColor:
                                (item.isRead
                                        ? AppTheme.mutedText
                                        : AppTheme.info)
                                    .withValues(alpha: 0.12),
                            child: Icon(
                              item.isRead
                                  ? Icons.notifications_none
                                  : Icons.notifications_active,
                              color: item.isRead
                                  ? AppTheme.mutedText
                                  : AppTheme.info,
                            ),
                          ),
                          title: Text(
                            item.title,
                            style: TextStyle(
                              fontWeight: item.isRead
                                  ? FontWeight.w500
                                  : FontWeight.w700,
                            ),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              '${item.body}\n${DateFormatters.dateTime(item.createdAt)}',
                            ),
                          ),
                          isThreeLine: true,
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
