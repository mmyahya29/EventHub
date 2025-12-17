import 'package:event_hub/main_screens/explore_subscreens/side_drawer_screens/FAQ_screen.dart';
import 'package:event_hub/main_screens/explore_subscreens/side_drawer_screens/booked_events.dart';
import 'package:event_hub/main_screens/explore_subscreens/side_drawer_screens/chats_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/auth_provider.dart';

class AppDrawer extends ConsumerStatefulWidget {

  const AppDrawer({super.key,});

  @override
  ConsumerState<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends ConsumerState<AppDrawer> {

  @override
  Widget build(BuildContext context) {
    final auth = ref.read(firebaseAuthProvider);
    return Drawer(
      child: Container(
        color: Colors.white,
        child: Column(
          children: [
            // Header with Profile
            Container(
              width: double.infinity,
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 20,
                bottom: 20,
                left: 20,
                right: 20,
              ),
              child: Column(
                children: [
                  // Profile Picture
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey[300],
                      border: Border.all(
                        color: const Color(0xFF5B4EFF),
                        width: 3,
                      ),
                    ),
                    child: const Icon(
                      Icons.person,
                      size: 35,
                      color: Colors.grey,
                    ),
                    // Replace with actual image:
                    // child: ClipOval(
                    //   child: Image.network(
                    //     'profile_image_url',
                    //     fit: BoxFit.cover,
                    //   ),
                    // ),
                  ),
                  const SizedBox(height: 12),
                  // Name
                  const Text(
                    'Yahya Hyder',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // Menu Items
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  _buildMenuItem(
                    icon: Icons.token_outlined,
                    title: 'Booked Tickets',
                    onTap: () {
                      Navigator.pop(context); // Close drawer
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MyBookingsScreen(),
                        ),
                      );
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.message_outlined,
                    title: 'Chats',
                    onTap: () {
                      Navigator.pop(context); // Close drawer
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatsScreen(),
                        ),
                      );
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.calendar_today_outlined,
                    title: 'Calendar',
                    onTap: () {
                      // Navigate to calendar
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.bookmark_border,
                    title: 'Bookmark',
                    onTap: () {
                      // Navigate to bookmarks
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.mail_outline,
                    title: 'Contact Us',
                    onTap: () {
                      // Navigate to contact
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.settings_outlined,
                    title: 'Settings',
                    onTap: () {
                      // Navigate to settings
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.help_outline,
                    title: 'FAQs',
                    onTap: () {
                      Navigator.pop(context); // Close drawer first
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FaqScreen(),
                        ),
                      );
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.logout,
                    title: 'Sign Out',
                    textColor: const Color(0xFFFF6B6B),
                    onTap: () {
                      auth.signOut();
                    },
                  ),
                ],
              ),
            ),
            // Upgrade Pro Button
            Padding(
              padding: const EdgeInsets.all(20),
              child: ElevatedButton(
                onPressed: () {
                  // Upgrade to pro
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00D9A5),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                  minimumSize: const Size(double.infinity, 48),
                ),
                child: const Text(
                  'Upgrade Pro',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? textColor,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: textColor ?? Colors.grey[700],
        size: 24,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          color: textColor ?? Colors.black87,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
    );
  }
}