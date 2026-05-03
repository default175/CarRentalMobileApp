import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/di/app_providers.dart';
import '../../extras/presentation/app_screen_catalog_page.dart';
import '../../notifications/presentation/notifications_page.dart';
import '../../profile/presentation/profile_page.dart';
import 'overview_page.dart';

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final authController = ref.watch(authControllerProvider);
    final notifications = ref.watch(notificationsProvider);
    final unreadCount = ref.watch(unreadNotificationsCountProvider);
    final user = authController.currentUser!;

    final pages = <Widget>[
      OverviewPage(onProfileTap: () => setState(() => _currentIndex = 4)),
      const AppTemplateScreenPage(slug: 'all-cars', embedded: true),
      const AppTemplateScreenPage(slug: 'orders-history', embedded: true),
      const AppTemplateScreenPage(slug: 'favorite-cars', embedded: true),
      const ProfilePage(),
    ];

    final destinations = <NavigationDestination>[
      const NavigationDestination(
        icon: Icon(Icons.home_outlined),
        selectedIcon: Icon(Icons.home),
        label: 'Home',
      ),
      const NavigationDestination(
        icon: Icon(Icons.directions_car_outlined),
        selectedIcon: Icon(Icons.directions_car),
        label: 'All Cars',
      ),
      const NavigationDestination(
        icon: Icon(Icons.calendar_month_outlined),
        selectedIcon: Icon(Icons.calendar_month),
        label: 'Bookings',
      ),
      const NavigationDestination(
        icon: Icon(Icons.favorite_border),
        selectedIcon: Icon(Icons.favorite),
        label: 'Favorites',
      ),
      const NavigationDestination(
        icon: Icon(Icons.person_outline),
        selectedIcon: Icon(Icons.person),
        label: 'Profile',
      ),
    ];

    return Scaffold(
      extendBody: true,
      drawer: Drawer(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text('Menu', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 16),
              _DrawerItem(
                icon: Icons.person_outline,
                title: 'Profile',
                onTap: () {
                  Navigator.of(context).pop();
                  setState(() => _currentIndex = 4);
                },
              ),
              _DrawerItem(
                icon: Icons.settings_outlined,
                title: 'Settings',
                onTap: () {
                  Navigator.of(context).pop();
                  context.push('/screens/settings-notifications');
                },
              ),
              _DrawerItem(
                icon: Icons.help_outline,
                title: 'FAQ',
                onTap: () {
                  Navigator.of(context).pop();
                  context.push('/screens/faqs');
                },
              ),
              if (user.isAdmin)
                _DrawerItem(
                  icon: Icons.admin_panel_settings_outlined,
                  title: 'Admin panel',
                  onTap: () {
                    Navigator.of(context).pop();
                    context.push('/screens/admin-panel');
                  },
                ),
              _DrawerItem(
                icon: Icons.privacy_tip_outlined,
                title: 'Privacy Policy',
                onTap: () {
                  Navigator.of(context).pop();
                  context.push('/screens/privacy-policy');
                },
              ),
              _DrawerItem(
                icon: Icons.description_outlined,
                title: 'Terms Of Service',
                onTap: () {
                  Navigator.of(context).pop();
                  context.push('/screens/terms-of-service');
                },
              ),
              _DrawerItem(
                icon: Icons.logout,
                title: 'Sign out',
                onTap: () {
                  Navigator.of(context).pop();
                  ref.read(authControllerProvider).signOut();
                },
              ),
            ],
          ),
        ),
      ),
      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            tooltip: 'Menu',
            onPressed: () => Scaffold.of(context).openDrawer(),
            icon: const Icon(Icons.menu),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(user.isAdmin ? 'Fleet Control' : 'Car Rental'),
            Text(
              user.isAdmin
                  ? 'Administrator workspace'
                  : 'Find and book your ride',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        actions: [
          notifications.when(
            data: (_) => IconButton(
              onPressed: () {
                showModalBottomSheet<void>(
                  context: context,
                  isScrollControlled: true,
                  showDragHandle: true,
                  builder: (context) => SizedBox(
                    height: MediaQuery.of(context).size.height * 0.7,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Notifications',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 16),
                          const Expanded(child: NotificationsListView()),
                        ],
                      ),
                    ),
                  ),
                );
              },
              icon: Stack(
                clipBehavior: Clip.none,
                children: [
                  const Icon(Icons.notifications_outlined),
                  if (unreadCount > 0)
                    Positioned(
                      right: -2,
                      top: -2,
                      child: Container(
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.error,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          unreadCount > 9 ? '9+' : '$unreadCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
          IconButton(
            onPressed: () => ref.read(themeModeProvider.notifier).toggle(),
            icon: const Icon(Icons.dark_mode_outlined),
          ),
        ],
      ),
      body: SafeArea(
        child: pages[_currentIndex],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(14, 0, 14, 12),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.14),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: NavigationBar(
              labelBehavior:
                  NavigationDestinationLabelBehavior.onlyShowSelected,
              selectedIndex: _currentIndex,
              destinations: destinations,
              onDestinationSelected: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  const _DrawerItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
    );
  }
}
