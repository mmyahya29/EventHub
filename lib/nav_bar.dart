import 'package:event_hub/main_screens/add_events_screens.dart';
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';

import 'main_screens/events_screen.dart';
import 'main_screens/explore_screen.dart';
import 'main_screens/profile_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({Key? key}) : super(key: key);

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  late PersistentTabController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PersistentTabController(initialIndex: 0);
  }

  List<Widget> _buildScreens() {
    return const [
      ExploreScreen(),
      EventsScreen(),
      MapScreen(),
      ProfileScreen(),
    ];
  }

  List<PersistentBottomNavBarItem> _navBarsItems(BuildContext context) {
    final Color activeColor = (Theme.of(context).brightness == Brightness.light)
        ? const Color(0xFF5B4EFF)
        : const Color(0xFF6D81CA);

    return [
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.explore_outlined),
        title: ("Explore"),
        activeColorPrimary: activeColor,
        inactiveColorPrimary: Colors.grey,
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.calendar_today_outlined),
        title: ("Events"),
        activeColorPrimary: activeColor,
        inactiveColorPrimary: Colors.grey,
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.location_on_outlined),
        title: ("Map"),
        activeColorPrimary: activeColor,
        inactiveColorPrimary: Colors.grey,
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.person_outline),
        title: ("Profile"),
        activeColorPrimary: activeColor,
        inactiveColorPrimary: Colors.grey,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return PersistentTabView(
      context,
      controller: _controller,
      screens: _buildScreens(),
      items: _navBarsItems(context),
      confineToSafeArea: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      navBarStyle: NavBarStyle.style9,
      handleAndroidBackButtonPress: true,
    );
  }
}

class MapScreen extends StatelessWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Map Screen', style: TextStyle(fontSize: 24)),
      ),
    );
  }
}