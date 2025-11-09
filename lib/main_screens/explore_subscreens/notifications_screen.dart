import 'package:flutter/material.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final List<Map<String, dynamic>> _notifications = [
    {
      'name': 'David Silbia',
      'action': 'Invite Jo Malone London\'s Mother\'s...',
      'time': 'Just now',
      'type': 'invite',
      'hasActions': true,
      'avatar': Colors.orange,
    },
    {
      'name': 'Adnan Safi',
      'action': 'Started following you',
      'time': '5 min ago',
      'type': 'follow',
      'hasActions': false,
      'avatar': Colors.purple,
    },
    {
      'name': 'Joan Baker',
      'action': 'Invite A Virtual Evening of Smooth Jazz',
      'time': '20 min ago',
      'type': 'invite',
      'hasActions': true,
      'avatar': Colors.pink,
    },
    {
      'name': 'Ronald C. Kinch',
      'action': 'Like you events',
      'time': '1hr ago',
      'type': 'like',
      'hasActions': false,
      'avatar': Colors.blue,
    },
    {
      'name': 'Clara Tolson',
      'action': 'Invite international Kids Safe Parents Night Out',
      'time': '2hr ago',
      'type': 'invite',
      'hasActions': false,
      'avatar': Colors.green,
    },
    {
      'name': 'Jennifer Fritz',
      'action': 'Invite Jungle Judi and Tarzan',
      'time': '5hr ago',
      'type': 'invite',
      'hasActions': false,
      'avatar': Colors.red,
    },
    {
      'name': 'Manuela Marques',
      'action': 'Like you events International kids safe',
      'time': '1 day ago',
      'type': 'like',
      'hasActions': false,
      'avatar': Colors.amber,
    },
    {
      'name': 'Eric G. Prickett',
      'action': 'Started following you',
      'time': 'Wed, 3:30 PM',
      'type': 'follow',
      'hasActions': false,
      'avatar': Colors.teal,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Notification',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black87),
            onPressed: () {
              _showOptionsMenu(context);
            },
          ),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: _notifications.length,
        separatorBuilder: (context, index) => Divider(
          height: 1,
          color: Colors.grey[200],
        ),
        itemBuilder: (context, index) {
          return _buildNotificationItem(_notifications[index]);
        },
      ),
    );
  }

  Widget _buildNotificationItem(Map<String, dynamic> notification) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: notification['avatar'],
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name and Action
                RichText(
                  text: TextSpan(
                    style: const TextStyle(
                      fontSize: 15,
                      color: Colors.black87,
                      height: 1.4,
                    ),
                    children: [
                      TextSpan(
                        text: notification['name'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextSpan(
                        text: ' ${notification['action']}',
                        style: TextStyle(
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                // Time
                Text(
                  notification['time'],
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
                // Action Buttons (if applicable)
                if (notification['hasActions']) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            // Reject action
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.grey[700],
                            side: BorderSide(color: Colors.grey[300]!),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Reject',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            // Accept action
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF5B4EFF),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Accept',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
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
    );
  }

  void _showOptionsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.mark_email_read_outlined),
              title: const Text('Mark all as read'),
              onTap: () {
                Navigator.pop(context);
                // Mark all as read action
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline),
              title: const Text('Clear all'),
              onTap: () {
                Navigator.pop(context);
                // Clear all action
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings_outlined),
              title: const Text('Notification settings'),
              onTap: () {
                Navigator.pop(context);
                // Navigate to settings
              },
            ),
          ],
        ),
      ),
    );
  }
}