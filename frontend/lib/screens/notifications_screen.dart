import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/notification_provider.dart';
import 'package:timeago/timeago.dart' as timeago;

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      if (auth.accessToken != null) {
        Provider.of<NotificationProvider>(context, listen: false)
            .fetchNotifications(auth.accessToken!);
      }
    });
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'LIKE':
        return Icons.favorite_rounded;
      case 'COMMENT':
        return Icons.chat_bubble_rounded;
      case 'FOLLOW':
        return Icons.person_add_rounded;
      case 'TRIP_REMINDER':
        return Icons.event_available_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }

  Color _getColorForType(String type) {
    switch (type) {
      case 'LIKE':
        return Colors.red;
      case 'COMMENT':
        return Colors.blue;
      case 'FOLLOW':
        return Colors.green;
      case 'TRIP_REMINDER':
        return Colors.amber;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = Provider.of<NotificationProvider>(context);
    final auth = Provider.of<AuthProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          if (provider.notifications.isNotEmpty)
            TextButton(
              onPressed: () {
                if (auth.accessToken != null) {
                  provider.markAllAsRead(auth.accessToken!);
                }
              },
              child: const Text('Mark all as read'),
            ),
        ],
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.errorMessage != null
              ? Center(child: Text(provider.errorMessage!))
              : provider.notifications.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.notifications_off_rounded,
                            size: 64,
                            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'No notifications yet',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      itemCount: provider.notifications.length,
                      separatorBuilder: (ctx, i) => const Divider(height: 1),
                      itemBuilder: (ctx, index) {
                        final notification = provider.notifications[index];
                        final isRead = notification['isRead'] ?? false;
                        final sender = notification['sender'];

                        return ListTile(
                          onTap: () {
                            if (!isRead && auth.accessToken != null) {
                              provider.markAsRead(auth.accessToken!, notification['_id']);
                            }
                            // Normally you would navigate to the related item here (Post, User profile, etc.)
                          },
                          tileColor: isRead ? null : theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                          leading: Stack(
                            children: [
                              CircleAvatar(
                                backgroundImage: (sender != null && sender['profileImage'] != null && sender['profileImage'].isNotEmpty)
                                    ? NetworkImage(sender['profileImage'])
                                    : null,
                                child: (sender == null || sender['profileImage'] == null || sender['profileImage'].isEmpty)
                                    ? const Icon(Icons.person)
                                    : null,
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                    color: theme.scaffoldBackgroundColor,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    _getIconForType(notification['type']),
                                    size: 12,
                                    color: _getColorForType(notification['type']),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          title: Text(
                            notification['message'] ?? '',
                            style: TextStyle(
                              fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            timeago.format(DateTime.parse(notification['createdAt'])),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: isRead ? null : theme.colorScheme.primary,
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}
