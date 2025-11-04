import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_onesignal_example/features/repositories/notification_manager.dart';

/// Notification Demo Page - Testing OneSignal Integration
/// Works with your existing NotificationService and NotificationManager
class NotificationDemoPage extends StatefulWidget {
  const NotificationDemoPage({super.key});

  @override
  State<NotificationDemoPage> createState() => _NotificationDemoPageState();
}

class _NotificationDemoPageState extends State<NotificationDemoPage>
    with WidgetsBindingObserver {
  final NotificationManager _notificationManager = NotificationManager();

  String? _playerId;
  bool _isSubscribed = false;
  bool _isLoading = false;
  final List<Map<String, dynamic>> _receivedNotifications = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadNotificationStatus();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadNotificationStatus();
    }
  }

  Future<void> _loadNotificationStatus() async {
    setState(() => _isLoading = true);

    try {
      final playerId = await _notificationManager.getPlayerId();

      setState(() {
        _playerId = playerId;
        _isLoading = false;
      });

      debugPrint('Notification Status Loaded: PlayerId=$playerId');
    } catch (e) {
      debugPrint('Error loading notification status: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleSubscription() async {
    setState(() => _isLoading = true);

    try {
      if (_isSubscribed) {
        await _notificationManager.unsubscribeNotifcation();
        _showSnackBar('Unsubscribed from notifications', Colors.orange);
      } else {
        await _notificationManager.subscribeNotication();
        _showSnackBar('Subscribed to notifications', Colors.green);
      }

      setState(() => _isSubscribed = !_isSubscribed);
      await _loadNotificationStatus();
    } catch (e) {
      debugPrint('Error toggling subscription: $e');
      _showSnackBar('Failed to toggle subscription', Colors.red);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _sendTestLocalNotification() async {
    try {
      await _notificationManager.showLocalNotification(
        title: 'Test Notification',
        body: 'This is a test notification from the demo page!',
        payload: {
          'type': 'test',
          'route': '/notifications',
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      _showSnackBar('Test notification sent!', Colors.blue);

      // Add to received list for demo
      setState(() {
        _receivedNotifications.insert(0, {
          'title': 'Test Notification',
          'body': 'This is a test notification from the demo page!',
          'time': DateTime.now(),
          'type': 'local',
        });
      });
    } catch (e) {
      debugPrint('Error sending test notification: $e');
      _showSnackBar('Failed to send test notification', Colors.red);
    }
  }

  Future<void> _addUserTags() async {
    setState(() => _isLoading = true);

    try {
      // Example tags for user segmentation
      await _notificationManager.addTags({
        'user_type': 'premium',
        'city': 'Duhok',
        'language': 'ar',
        'interests': 'real_estate',
      });

      _showSnackBar('User tags added successfully!', Colors.green);
    } catch (e) {
      debugPrint('Error adding tags: $e');
      _showSnackBar('Failed to add tags', Colors.red);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _removeUserTags() async {
    setState(() => _isLoading = true);

    try {
      await _notificationManager.removeTags(['user_type', 'city', 'language']);
      _showSnackBar('User tags removed!', Colors.orange);
    } catch (e) {
      debugPrint('Error removing tags: $e');
      _showSnackBar('Failed to remove tags', Colors.red);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _copyPlayerId() {
    if (_playerId != null) {
      Clipboard.setData(ClipboardData(text: _playerId!));
      _showSnackBar('Player ID copied to clipboard!', Colors.blue);
    }
  }

  void _showSnackBar(String message, Color color) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('OneSignal Demo'),
        backgroundColor: Colors.deepPurple,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadNotificationStatus,
            tooltip: 'Refresh Status',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadNotificationStatus,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Status Card
                    _buildStatusCard(),
                    const SizedBox(height: 16),

                    // Actions Section
                    _buildSectionTitle('Actions'),
                    const SizedBox(height: 8),
                    _buildSubscriptionCard(),
                    const SizedBox(height: 8),
                    _buildTestNotificationCard(),
                    const SizedBox(height: 8),
                    _buildTagsCard(),
                    const SizedBox(height: 16),

                    // Received Notifications
                    _buildSectionTitle('Received Notifications'),
                    const SizedBox(height: 8),
                    _buildNotificationsList(),
                    const SizedBox(height: 16),

                    // Instructions
                    _buildInstructionsCard(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildStatusCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: Colors.deepPurple, size: 24),
                const SizedBox(width: 8),
                Text(
                  'OneSignal Status',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            _buildInfoRow(
              'Player ID',
              _playerId ?? 'Not Available',
              icon: Icons.fingerprint,
              onTap: _playerId != null ? _copyPlayerId : null,
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              'Subscription Status',
              _isSubscribed ? 'Subscribed ✓' : 'Not Subscribed ✗',
              icon: Icons.notifications_active,
              color: _isSubscribed ? Colors.green : Colors.orange,
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              'Platform',
              Theme.of(context).platform == TargetPlatform.iOS
                  ? 'iOS'
                  : 'Android',
              icon: Icons.phone_android,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value, {
    IconData? icon,
    Color? color,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 20, color: color ?? Colors.grey[600]),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 14,
                      color: color ?? Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (onTap != null)
              Icon(Icons.copy, size: 16, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildSubscriptionCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _isSubscribed ? Colors.green : Colors.orange,
          child: Icon(
            _isSubscribed
                ? Icons.notifications_active
                : Icons.notifications_off,
            color: Colors.white,
          ),
        ),
        title: Text(
          _isSubscribed ? 'Subscribed' : 'Unsubscribed',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          _isSubscribed
              ? 'You will receive notifications'
              : 'Subscribe to receive notifications',
        ),
        trailing: Switch(
          value: _isSubscribed,
          onChanged: (_) => _toggleSubscription(),
          activeColor: Colors.green,
        ),
      ),
    );
  }

  Widget _buildTestNotificationCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Colors.blue,
          child: Icon(Icons.send, color: Colors.white),
        ),
        title: const Text(
          'Send Test Notification',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: const Text('Send a local test notification'),
        trailing: IconButton(
          icon: const Icon(Icons.play_arrow),
          onPressed: _sendTestLocalNotification,
          color: Colors.blue,
        ),
        onTap: _sendTestLocalNotification,
      ),
    );
  }

  Widget _buildTagsCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'User Tags',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tags help segment users for targeted notifications',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _addUserTags,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Tags'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _removeUserTags,
                    icon: const Icon(Icons.remove),
                    label: const Text('Remove Tags'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationsList() {
    if (_receivedNotifications.isEmpty) {
      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            children: [
              Icon(Icons.notifications_none, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'No notifications yet',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Notifications will appear here',
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: _receivedNotifications.map((notification) {
        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: notification['type'] == 'local'
                  ? Colors.blue
                  : Colors.deepPurple,
              child: Icon(
                notification['type'] == 'local'
                    ? Icons.notifications
                    : Icons.cloud,
                color: Colors.white,
                size: 20,
              ),
            ),
            title: Text(
              notification['title'] ?? 'Notification',
              style: const TextStyle(fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notification['body'] ?? '',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  _formatTime(notification['time']),
                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                ),
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.close, size: 20),
              onPressed: () {
                setState(() {
                  _receivedNotifications.remove(notification);
                });
              },
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildInstructionsCard() {
    return Card(
      elevation: 2,
      color: Colors.blue[50],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.lightbulb_outline, color: Colors.blue[700]),
                const SizedBox(width: 8),
                Text(
                  'How to Test',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[900],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInstructionItem(
              '1. Copy your Player ID from the status card',
            ),
            _buildInstructionItem(
              '2. Go to OneSignal Dashboard > Messages > New Push',
            ),
            _buildInstructionItem(
              '3. Use "Test Users" and paste your Player ID',
            ),
            _buildInstructionItem(
              '4. Send notification and see it appear here!',
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.link, size: 16, color: Colors.blue[700]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'https://app.onesignal.com',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle, size: 16, color: Colors.blue[700]),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 13, color: Colors.blue[900]),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}
