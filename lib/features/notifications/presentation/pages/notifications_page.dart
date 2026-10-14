import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/app_snackbar.dart';
import '../../../../injection_container.dart';
import '../bloc/notification_bloc.dart';
import '../bloc/notification_event.dart';
import '../bloc/notification_state.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // If NotificationBloc is already provided globally, reuse it; otherwise create it.
    try {
      context.read<NotificationBloc>();
      return const NotificationsView();
    } catch (_) {
      return BlocProvider(
        create: (_) => InjectionContainer.createNotificationBloc()
          ..add(const LoadNotifications()),
        child: const NotificationsView(),
      );
    }
  }
}

class NotificationsView extends StatefulWidget {
  const NotificationsView({super.key});

  @override
  State<NotificationsView> createState() => _NotificationsViewState();
}

class _NotificationsViewState extends State<NotificationsView> {
  String _selectedFilter = 'All';

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0 && now.day == date.day) {
      final hour = date.hour == 0
          ? 12
          : (date.hour > 12 ? date.hour - 12 : date.hour);
      final period = date.hour >= 12 ? 'PM' : 'AM';
      final minute = date.minute.toString().padLeft(2, '0');
      return 'Today, $hour:$minute $period';
    } else if (difference.inDays == 1 ||
        (difference.inDays == 0 && now.day != date.day)) {
      final hour = date.hour == 0
          ? 12
          : (date.hour > 12 ? date.hour - 12 : date.hour);
      final period = date.hour >= 12 ? 'PM' : 'AM';
      final minute = date.minute.toString().padLeft(2, '0');
      return 'Yesterday, $hour:$minute $period';
    }

    final hour =
        date.hour == 0 ? 12 : (date.hour > 12 ? date.hour - 12 : date.hour);
    final period = date.hour >= 12 ? 'PM' : 'AM';
    final minute = date.minute.toString().padLeft(2, '0');
    return '${date.day}/${date.month}/${date.year} $hour:$minute $period';
  }

  void _openSendNotificationSheet(BuildContext context) {
    final titleController = TextEditingController();
    final messageController = TextEditingController();
    String selectedCategory = 'message';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (modalContext, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(modalContext).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 44,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF3B82F6).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.send_rounded,
                            color: Color(0xFF2563EB),
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Send Notification Message',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                            Text(
                              'Broadcast Firebase push message',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Notification Title
                    TextField(
                      controller: titleController,
                      decoration: InputDecoration(
                        labelText: 'Notification Title',
                        hintText: 'e.g. Passenger Waiting',
                        prefixIcon: const Icon(Icons.title_rounded, size: 20),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Notification Message Body
                    TextField(
                      controller: messageController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: 'Message Body',
                        hintText: 'e.g. Driver is waiting at Pickup Point A.',
                        prefixIcon: const Icon(Icons.chat_bubble_outline_rounded, size: 20),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Category Selector
                    const Text(
                      'Notification Category',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF334155),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: ['message', 'ride', 'payment', 'system'].map((cat) {
                        final isSelected = selectedCategory == cat;
                        return ChoiceChip(
                          label: Text(
                            cat[0].toUpperCase() + cat.substring(1),
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.black87,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                          selected: isSelected,
                          selectedColor: const Color(0xFF2563EB),
                          backgroundColor: const Color(0xFFF1F5F9),
                          onSelected: (val) {
                            if (val) {
                              setModalState(() {
                                selectedCategory = cat;
                              });
                            }
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 22),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.send_rounded, size: 18),
                        label: const Text(
                          'Send Notification Now',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                        onPressed: () {
                          final title = titleController.text.trim();
                          final body = messageController.text.trim();

                          if (title.isEmpty || body.isEmpty) {
                            AppSnackBar.showError(
                              modalContext,
                              'Please enter both title and message body.',
                            );
                            return;
                          }

                          context.read<NotificationBloc>().add(
                                SendNotificationEvent(
                                  title: title,
                                  message: body,
                                  type: selectedCategory,
                                ),
                              );

                          Navigator.of(modalContext).pop();
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showTokenDialog(BuildContext context, String? token) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.vpn_key_rounded, color: Color(0xFF2563EB)),
            SizedBox(width: 8),
            Text('FCM Push Token'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Use this device token to send push notifications via Firebase Console or API:',
              style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: SelectableText(
                token ?? 'Fetching FCM token...',
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                  color: Color(0xFF0F172A),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text('Close'),
          ),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF2563EB),
              side: const BorderSide(color: Color(0xFF2563EB)),
            ),
            icon: const Icon(Icons.refresh_rounded, size: 16),
            label: const Text('Refresh'),
            onPressed: () {
              Navigator.of(dialogCtx).pop();
              context.read<NotificationBloc>().add(const RefreshFcmToken());
              AppSnackBar.showInfo(context, 'Refreshing FCM push token...');
            },
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
              foregroundColor: Colors.white,
            ),
            icon: const Icon(Icons.copy_rounded, size: 16),
            label: const Text('Copy Token'),
            onPressed: () {
              if (token != null && token.isNotEmpty) {
                Clipboard.setData(ClipboardData(text: token));
                Navigator.of(dialogCtx).pop();
                AppSnackBar.showSuccess(context, 'FCM token copied to clipboard!');
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<NotificationBloc, NotificationState>(
      listener: (context, state) {
        if (state is NotificationLoaded) {
          if (state.sendSuccessMessage != null) {
            AppSnackBar.showSuccess(context, state.sendSuccessMessage!);
          } else if (state.newlyReceived != null) {
            AppSnackBar.showInfo(
              context,
              'New Notification: ${state.newlyReceived!.title}',
            );
          }
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          title: const Text(
            'Notifications',
            style: TextStyle(
              color: Color(0xFF1E293B),
              fontWeight: FontWeight.w700,
              fontSize: 22,
              letterSpacing: -0.5,
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: false,
          iconTheme: const IconThemeData(color: Color(0xFF1E293B)),
          actions: [
            BlocBuilder<NotificationBloc, NotificationState>(
              builder: (context, state) {
                final token = state is NotificationLoaded ? state.fcmToken : null;
                return IconButton(
                  tooltip: 'View FCM Token',
                  icon: const Icon(Icons.token_rounded, color: Color(0xFF2563EB)),
                  onPressed: () => _showTokenDialog(context, token),
                );
              },
            ),
            IconButton(
              tooltip: 'Refresh Notifications',
              icon: const Icon(Icons.refresh_rounded, color: Color(0xFF64748B)),
              onPressed: () {
                context.read<NotificationBloc>().add(const LoadNotifications());
              },
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: const Color(0xFF2563EB),
          foregroundColor: Colors.white,
          icon: const Icon(Icons.add_comment_rounded),
          label: const Text('Send Message'),
          onPressed: () => _openSendNotificationSheet(context),
        ),
        body: BlocBuilder<NotificationBloc, NotificationState>(
          builder: (context, state) {
            if (state is NotificationLoading) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFF3B82F6)),
              );
            } else if (state is NotificationError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
                    const SizedBox(height: 16),
                    Text(
                      state.message,
                      style: const TextStyle(color: Color(0xFF64748B), fontSize: 16),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () => context
                          .read<NotificationBloc>()
                          .add(const LoadNotifications()),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            } else if (state is NotificationLoaded) {
              final allNotifications = state.notifications;
              final filtered = _selectedFilter == 'All'
                  ? allNotifications
                  : allNotifications
                      .where((n) => n.type.toLowerCase() == _selectedFilter.toLowerCase())
                      .toList();

              return Column(
                children: [
                  // Filter Chips Header
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: ['All', 'Ride', 'Payment', 'Message', 'System']
                          .map((filter) {
                        final isSelected = _selectedFilter == filter;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(filter),
                            selected: isSelected,
                            selectedColor: const Color(0xFF2563EB).withValues(alpha: 0.15),
                            labelStyle: TextStyle(
                              color: isSelected
                                  ? const Color(0xFF2563EB)
                                  : const Color(0xFF475569),
                              fontWeight:
                                  isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                            backgroundColor: Colors.white,
                            side: BorderSide(
                              color: isSelected
                                  ? const Color(0xFF2563EB)
                                  : const Color(0xFFE2E8F0),
                            ),
                            onSelected: (_) {
                              setState(() {
                                _selectedFilter = filter;
                              });
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  // Notifications List
                  Expanded(
                    child: filtered.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(24),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFEFF6FF),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.notifications_off_outlined,
                                    color: Color(0xFF60A5FA),
                                    size: 64,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                const Text(
                                  'No notifications found',
                                  style: TextStyle(
                                    color: Color(0xFF0F172A),
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Send a test notification using the button below!',
                                  style: TextStyle(
                                    color: Color(0xFF64748B),
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.only(
                              left: 16,
                              right: 16,
                              top: 8,
                              bottom: 80,
                            ),
                            itemCount: filtered.length,
                            itemBuilder: (context, index) {
                              final notification = filtered[index];

                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: notification.isRead
                                        ? const Color(0xFFF1F5F9)
                                        : const Color(0xFFBFDBFE),
                                    width: notification.isRead ? 1 : 1.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF94A3B8)
                                          .withValues(alpha: 0.05),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: () {
                                        context
                                            .read<NotificationBloc>()
                                            .add(MarkNotificationAsRead(notification.id));
                                      },
                                      child: Stack(
                                        children: [
                                          if (!notification.isRead)
                                            Positioned(
                                              top: 0,
                                              bottom: 0,
                                              left: 0,
                                              child: Container(
                                                width: 4,
                                                color: const Color(0xFF3B82F6),
                                              ),
                                            ),
                                          Padding(
                                            padding: const EdgeInsets.all(16.0),
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Container(
                                                  padding:
                                                      const EdgeInsets.all(10),
                                                  decoration: BoxDecoration(
                                                    color: notification.isRead
                                                        ? const Color(0xFFF8FAFC)
                                                        : const Color(0xFFEFF6FF),
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: Icon(
                                                    _getIconForNotification(
                                                        notification.title,
                                                        notification.type),
                                                    color: notification.isRead
                                                        ? const Color(0xFF94A3B8)
                                                        : const Color(0xFF3B82F6),
                                                    size: 24,
                                                  ),
                                                ),
                                                const SizedBox(width: 16),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment.start,
                                                    children: [
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Expanded(
                                                            child: Text(
                                                              notification.title,
                                                              style: TextStyle(
                                                                color: const Color(
                                                                    0xFF0F172A),
                                                                fontWeight:
                                                                    notification
                                                                            .isRead
                                                                        ? FontWeight
                                                                            .w600
                                                                        : FontWeight
                                                                            .w700,
                                                                fontSize: 16,
                                                              ),
                                                              maxLines: 2,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                            ),
                                                          ),
                                                          const SizedBox(width: 8),
                                                          Text(
                                                            _formatDate(
                                                                notification
                                                                    .createdAt),
                                                            style: TextStyle(
                                                              color: notification
                                                                      .isRead
                                                                  ? const Color(
                                                                      0xFF94A3B8)
                                                                  : const Color(
                                                                      0xFF64748B),
                                                              fontSize: 12,
                                                              fontWeight:
                                                                  notification
                                                                          .isRead
                                                                      ? FontWeight
                                                                          .normal
                                                                      : FontWeight
                                                                          .w500,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      const SizedBox(height: 6),
                                                      Text(
                                                        notification.message,
                                                        style: const TextStyle(
                                                          color:
                                                              Color(0xFF475569),
                                                          fontSize: 14,
                                                          height: 1.4,
                                                        ),
                                                      ),
                                                      if (notification.sender !=
                                                          null) ...[
                                                        const SizedBox(height: 6),
                                                        Row(
                                                          children: [
                                                            const Icon(
                                                              Icons.send_rounded,
                                                              size: 11,
                                                              color: Color(
                                                                  0xFF94A3B8),
                                                            ),
                                                            const SizedBox(
                                                                width: 4),
                                                            Text(
                                                              'From: ${notification.sender}',
                                                              style:
                                                                  const TextStyle(
                                                                fontSize: 11,
                                                                color: Color(
                                                                    0xFF94A3B8),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  IconData _getIconForNotification(String title, String type) {
    final lower = '${title.toLowerCase()} ${type.toLowerCase()}';
    if (lower.contains('payment') || lower.contains('money') || lower.contains('earn')) {
      return Icons.payments_outlined;
    }
    if (lower.contains('trip') || lower.contains('ride')) {
      return Icons.directions_car_outlined;
    }
    if (lower.contains('warning') || lower.contains('alert') || lower.contains('urgent')) {
      return Icons.warning_amber_rounded;
    }
    if (lower.contains('message') || lower.contains('chat')) {
      return Icons.chat_bubble_outline;
    }
    if (lower.contains('document') || lower.contains('verified') || lower.contains('upload')) {
      return Icons.verified_user_outlined;
    }
    return Icons.notifications_active_outlined;
  }
}
