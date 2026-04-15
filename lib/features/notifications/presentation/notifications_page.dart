import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/di/app_providers.dart';
import '../../../shared/models/app_notification.dart';
import '../../../shared/widgets/async_value_widget.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(16),
      child: NotificationsListView(),
    );
  }
}

class NotificationsListView extends ConsumerWidget {
  const NotificationsListView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(notificationsProvider);

    return AsyncValueWidget(
      value: notifications,
      data: (items) => ListView.separated(
        shrinkWrap: true,
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final item = items[index];
          final isRead =
              ref.watch(viewedNotificationIdsProvider).contains(item.id);
          return NotificationCard(
            notification: item,
            isRead: isRead,
            onTap: () async {
              final next = {
                ...ref.read(viewedNotificationIdsProvider),
                item.id,
              };
              ref.read(viewedNotificationIdsProvider.notifier).state = next;
              await ref
                  .read(localAppStorageProvider)
                  .saveViewedNotificationIds(next);
            },
          );
        },
      ),
    );
  }
}

class NotificationCard extends StatelessWidget {
  const NotificationCard({
    required this.notification,
    required this.isRead,
    required this.onTap,
    super.key,
  });

  final AppNotification notification;
  final bool isRead;
  final VoidCallback onTap;

  IconData _icon() {
    switch (notification.type) {
      case AppNotificationType.booking:
        return Icons.event_available_outlined;
      case AppNotificationType.geofence:
        return Icons.gpp_maybe_outlined;
      case AppNotificationType.reminder:
        return Icons.alarm_on_outlined;
      case AppNotificationType.system:
        return Icons.info_outline;
    }
  }

  Color _color(BuildContext context) {
    switch (notification.type) {
      case AppNotificationType.booking:
        return const Color(0xFF0D7A6C);
      case AppNotificationType.geofence:
        return Colors.orange;
      case AppNotificationType.reminder:
        return Colors.blue;
      case AppNotificationType.system:
        return Theme.of(context).colorScheme.secondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final formatter = DateFormat('dd.MM.yyyy HH:mm');
    final color = _color(context);
    final backgroundAlpha = isRead ? 0.06 : 0.2;
    final foregroundAlpha = isRead ? 0.58 : 1.0;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: color.withValues(alpha: backgroundAlpha),
          border: Border.all(
            color: color.withValues(alpha: isRead ? 0.08 : 0.35),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: color.withValues(alpha: 0.18),
                foregroundColor: color.withValues(alpha: foregroundAlpha),
                child: Icon(_icon()),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: foregroundAlpha),
                            fontWeight:
                                isRead ? FontWeight.w600 : FontWeight.w900,
                          ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      notification.message,
                      style: TextStyle(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: isRead ? 0.58 : 0.86),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      formatter.format(notification.createdAt),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
