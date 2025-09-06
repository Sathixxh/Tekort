import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tekort/Presentation/notification/notificationprovider.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'package:tekort/core/core/utils/styles.dart';

// Enhanced NotificationModel with additional properties
class NotificationModel {
  final String id;
  final String title;
  final String body;
  final DateTime timestamp;
  final NotificationType type;
  final bool isRead;
  final String? avatarUrl;

  NotificationModel({
    String? id,
    required this.title,
    required this.body,
    required this.timestamp,
    this.type = NotificationType.general,
    this.isRead = false,
    this.avatarUrl,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'timestamp': timestamp.toIso8601String(),
      'type': type.index,
      'isRead': isRead,
      'avatarUrl': avatarUrl,
    };
  }

  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      body: map['body'] ?? '',
      timestamp: DateTime.parse(map['timestamp']),
      type: NotificationType.values[map['type'] ?? 0],
      isRead: map['isRead'] ?? false,
      avatarUrl: map['avatarUrl'],
    );
  }

  NotificationModel copyWith({
    String? id,
    String? title,
    String? body,
    DateTime? timestamp,
    NotificationType? type,
    bool? isRead,
    String? avatarUrl,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }
}

enum NotificationType {
  general,
  message,
  reminder,
  warning,
  success,
  error,
}

// Enhanced NotificationProvider
class NotificationProvider extends ChangeNotifier {
  List<NotificationModel> _notifications = [];
  List<NotificationModel> get notifications => _notifications;

  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  NotificationProvider() {
    loadNotifications();
  }

  Future<void> addNotification(NotificationModel notification) async {
    _notifications.insert(0, notification);
    notifyListeners();
    await saveNotifications();
  }

  Future<void> markAsRead(String notificationId) async {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      notifyListeners();
      await saveNotifications();
    }
  }

  Future<void> markAllAsRead() async {
    _notifications = _notifications.map((n) => n.copyWith(isRead: true)).toList();
    notifyListeners();
    await saveNotifications();
  }

  Future<void> deleteNotification(String notificationId) async {
    _notifications.removeWhere((n) => n.id == notificationId);
    notifyListeners();
    await saveNotifications();
  }

  Future<void> saveNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final encodedList = _notifications.map((n) => jsonEncode(n.toMap())).toList();
    await prefs.setStringList('notifications', encodedList);
  }

  Future<void> loadNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final encodedList = prefs.getStringList('notifications');
    if (encodedList != null) {
      _notifications = encodedList
          .map((e) => NotificationModel.fromMap(jsonDecode(e)))
          .toList();
      notifyListeners();
    }
  }

  Future<void> clearNotifications() async {
    _notifications.clear();
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('notifications');
  }
}

// Professional Notification Screen with Animations
class NotificationScreen extends StatefulWidget {
  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _fadeController;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeController = AnimationController(
      duration: Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isdark=Theme.of(context).brightness==Brightness.dark;
    return Scaffold(
      backgroundColor:isdark?blackColor: Colors.grey[50],
      appBar: _buildAppBar(),
      body: Consumer<NotificationProvider>(
        builder: (context, provider, child) {
          return FadeTransition(
            opacity: _fadeController,
            child: provider.notifications.isEmpty
                ? _buildEmptyState()
                : _buildNotificationList(provider),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
      bool isdark=Theme.of(context).brightness==Brightness.dark;
    return AppBar(
      elevation: 0,
      backgroundColor:isdark?blackColor: Colors.white,
    
      title: Text(
        "Notifications",
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
         
        ),
      ),
      actions: [
        Consumer<NotificationProvider>(
          builder: (context, provider, child) {
            if (provider.notifications.isEmpty) return SizedBox();
            return PopupMenuButton<String>(
              icon: Icon(Icons.more_vert, ),
              onSelected: (value) {
                switch (value) {
                  case 'mark_all_read':
                    provider.markAllAsRead();
                    break;
                  case 'clear_all':
                    _showClearAllDialog(provider);
                    break;
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'mark_all_read',
                  child: Row(
                    children: [
                      Icon(Icons.done_all, size: 20, color: Colors.green),
                      SizedBox(width: 8),
                      Text('Mark all as read'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'clear_all',
                  child: Row(
                    children: [
                      Icon(Icons.clear_all, size: 20, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Clear all'),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
        SizedBox(width: 8),
      ],
     
    );
  }

  Widget _buildEmptyState() {
      bool isdark=Theme.of(context).brightness==Brightness.dark;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TweenAnimationBuilder<double>(
            duration: Duration(milliseconds: 800),
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color:isdark?blackColor: Colors.grey[100],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.notifications_none,
                    size: 60,
                    color: Colors.grey[400],
                  ),
                ),
              );
            },
          ),
          SizedBox(height: 24),
          Text(
            "No notifications yet",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8),
          Text(
            "You'll see your notifications here",
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationList(NotificationProvider provider) {
    
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: provider.notifications.length,
      itemBuilder: (context, index) {
        return TweenAnimationBuilder<double>(
          duration: Duration(milliseconds: 400 + (index * 100)),
          tween: Tween(begin: 0.0, end: 1.0),
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(50 * (1 - value), 0),
              child: Opacity(
                opacity: value,
                child: _buildNotificationCard(provider.notifications[index], provider),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildNotificationCard(NotificationModel notification, NotificationProvider provider) {
      bool isdark=Theme.of(context).brightness==Brightness.dark;
    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        provider.deleteNotification(notification.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Notification deleted'),
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(
              label: 'Undo',
              onPressed: () {
                provider.addNotification(notification);
              },
            ),
          ),
        );
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.symmetric(horizontal: 20),
        margin: EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(
          Icons.delete,
          color: Colors.white,
          size: 24,
        ),
      ),
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 4),
        child: Material(
          elevation: notification.isRead ? 0 : 2,
          borderRadius: BorderRadius.circular(16),
          color:isdark?const Color.fromARGB(255, 32, 32, 32): Colors.white,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              if (!notification.isRead) {
                provider.markAsRead(notification.id);
              }
            },
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: notification.isRead 
                    ? null 
                    : Border.all(color: _getTypeColor(notification.type).withOpacity(0.2)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildNotificationIcon(notification),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                notification.title,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: notification.isRead 
                                      ? FontWeight.w500 
                                      : FontWeight.w600,
                                  
                                ),
                              ),
                            ),
                            if (!notification.isRead)
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: _getTypeColor(notification.type),
                                  shape: BoxShape.circle,
                                ),
                              ),
                          ],
                        ),
                        SizedBox(height: 4),
                        Text(
                          notification.body,
                          style: TextStyle(
                            fontSize: 14,
                           
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 8),
                        Text(
                          _formatTimestamp(notification.timestamp),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                            fontWeight: FontWeight.w500,
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
      ),
    );
  }
Color _getStatusColor(NotificationModel notification) {
  final bodyLower = notification.body.toLowerCase();

  if (bodyLower.contains('completed')) {
    return Colors.green;
  } else if (bodyLower.contains('pending')) {
    return Colors.orange;
  } else if (bodyLower.contains('login success')) {
    return Colors.green;
  }

  // fallback to type-based color
  return _getTypeColor(notification.type);
}

IconData _getStatusIcon(NotificationModel notification) {
  final bodyLower = notification.body.toLowerCase();

  if (bodyLower.contains('completed')) {
    return Icons.check_circle; // ✅
  } else if (bodyLower.contains('pending')) {
    return Icons.access_time; // ⏳
  } else if (bodyLower.contains('login success')) {
    return Icons.check_circle; // ✅
  }

  // fallback to type-based icon
  return _getTypeIcon(notification.type);
}

Widget _buildNotificationIcon(NotificationModel notification) {
  return Container(
    width: 48,
    height: 48,
    decoration: BoxDecoration(
      color: _getStatusColor(notification).withOpacity(0.1),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Icon(
      _getStatusIcon(notification),
      color: _getStatusColor(notification),
      size: 24,
    ),
  );
}


  Color _getTypeColor(NotificationType type) {
    switch (type) {
      case NotificationType.message:
        return Colors.blue;
      case NotificationType.reminder:
        return Colors.orange;
      case NotificationType.warning:
        return Colors.amber;
      case NotificationType.success:
        return Colors.green;
      case NotificationType.error:
        return Colors.red;
      default:
        return primaryColor!;
    }
  }

  IconData _getTypeIcon(NotificationType type) {
    switch (type) {
      case NotificationType.message:
        return Icons.message;
      case NotificationType.reminder:
        return Icons.schedule;
      case NotificationType.warning:
        return Icons.warning;
      case NotificationType.success:
        return Icons.check_circle;
      case NotificationType.error:
        return Icons.error;
      default:
        return Icons.notifications;
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }

  void _showClearAllDialog(NotificationProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Clear all notifications?'),
        content: Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              provider.clearNotifications();
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text('Clear all'),
          ),
        ],
      ),
    );
  }
}
