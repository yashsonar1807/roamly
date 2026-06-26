import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/responsive.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  final List<String> _titles = [
    'Home',
    'Explore',
    'Create',
    'Trips',
    'Profile',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDesktop = context.isDesktop;

    // The views for each tab
    final List<Widget> views = [
      const _HomeView(),
      const _ExploreView(),
      const _CreateView(),
      const _TripsView(),
      const _ProfileView(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
        elevation: 0,
        actions: _selectedIndex == 4 // Only show logout action in Profile tab
            ? [
                IconButton(
                  icon: const Icon(Icons.logout_rounded),
                  onPressed: () async {
                    final auth = Provider.of<AuthProvider>(context, listen: false);
                    await auth.logout();
                    if (context.mounted) {
                      Navigator.pushReplacementNamed(context, '/login');
                    }
                  },
                )
              ]
            : null,
      ),
      // Use Row for desktop navigation rail layout, Standard scaffold body for mobile/tablet
      body: Row(
        children: [
          // Navigation Rail for Desktop / Tablet Landscape
          if (isDesktop)
            NavigationRail(
              selectedIndex: _selectedIndex,
              onDestinationSelected: (int index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              labelType: NavigationRailLabelType.all,
              indicatorColor: theme.colorScheme.primaryContainer,
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home_rounded),
                  label: Text('Home'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.explore_outlined),
                  selectedIcon: Icon(Icons.explore_rounded),
                  label: Text('Explore'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.add_circle_outline_rounded),
                  selectedIcon: Icon(Icons.add_circle_rounded),
                  label: Text('Create'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.card_travel_outlined),
                  selectedIcon: Icon(Icons.card_travel_rounded),
                  label: Text('Trips'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.person_outline_rounded),
                  selectedIcon: Icon(Icons.person_rounded),
                  label: Text('Profile'),
                ),
              ],
            ),
          
          // Primary View Area with animated transitions
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0.0, 0.05),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  ),
                );
              },
              child: KeyedSubtree(
                key: ValueKey<int>(_selectedIndex),
                child: views[_selectedIndex],
              ),
            ),
          ),
        ],
      ),
      
      // Bottom Navigation Bar for Mobile and Tablet
      bottomNavigationBar: !isDesktop
          ? Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: NavigationBar(
                selectedIndex: _selectedIndex,
                onDestinationSelected: (int index) {
                  setState(() {
                    _selectedIndex = index;
                  });
                },
                destinations: const [
                  NavigationDestination(
                    icon: Icon(Icons.home_outlined),
                    selectedIcon: Icon(Icons.home_rounded),
                    label: 'Home',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.explore_outlined),
                    selectedIcon: Icon(Icons.explore_rounded),
                    label: 'Explore',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.add_circle_outline_rounded),
                    selectedIcon: Icon(Icons.add_circle_rounded),
                    label: 'Create',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.card_travel_outlined),
                    selectedIcon: Icon(Icons.card_travel_rounded),
                    label: 'Trips',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.person_outline_rounded),
                    selectedIcon: Icon(Icons.person_rounded),
                    label: 'Profile',
                  ),
                ],
              ),
            )
          : null,
    );
  }
}

// ─── TAB VIEW: HOME ───────────────────────────────────────────────
class _HomeView extends StatelessWidget {
  const _HomeView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final auth = Provider.of<AuthProvider>(context);
    final user = auth.user ?? {};

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome, ${user['name'] ?? 'Traveler'} 👋',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Where do you want to explore next?',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 28),
          
          // Responsive layout grid of feature items
          ResponsiveLayout(
            mobile: Column(
              children: _buildHomeCards(context),
            ),
            tablet: Row(
              children: _buildHomeCards(context).map((card) => Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 4.0), child: card))).toList(),
            ),
            desktop: Row(
              children: _buildHomeCards(context).map((card) => Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 8.0), child: card))).toList(),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildHomeCards(BuildContext context) {
    final theme = Theme.of(context);
    return [
      Card(
        color: theme.colorScheme.primaryContainer,
        child: InkWell(
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.flight_takeoff_rounded, size: 36, color: theme.colorScheme.onPrimaryContainer),
                const SizedBox(height: 16),
                Text('Plan New Trip', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.onPrimaryContainer)),
                const SizedBox(height: 4),
                Text('Create customizable itineraries and checklists', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.8))),
              ],
            ),
          ),
        ),
      ),
      const SizedBox(height: 12),
      Card(
        color: theme.colorScheme.secondaryContainer,
        child: InkWell(
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.map_rounded, size: 36, color: theme.colorScheme.onSecondaryContainer),
                const SizedBox(height: 16),
                Text('Explore Map', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.onSecondaryContainer)),
                const SizedBox(height: 4),
                Text('Search popular spots and hidden locations nearby', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSecondaryContainer.withValues(alpha: 0.8))),
              ],
            ),
          ),
        ),
      ),
    ];
  }
}

// ─── TAB VIEW: EXPLORE ────────────────────────────────────────────
class _ExploreView extends StatelessWidget {
  const _ExploreView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search Bar
          SearchBar(
            leading: const Icon(Icons.search_rounded),
            hintText: 'Search destinations, parks, cities...',
            elevation: WidgetStateProperty.all(0),
            shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            backgroundColor: WidgetStateProperty.all(theme.colorScheme.surfaceContainerHighest),
          ),
          const SizedBox(height: 24),
          Text('Popular Destinations', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.builder(
              itemCount: 5,
              itemBuilder: (context, index) {
                final cities = ['Paris, France', 'Tokyo, Japan', 'New York, USA', 'Rome, Italy', 'Sydney, Australia'];
                final icons = [Icons.domain, Icons.temple_hindu, Icons.location_city, Icons.museum, Icons.sailing];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                    child: Icon(icons[index], color: theme.colorScheme.primary),
                  ),
                  title: Text(cities[index], style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text('Tap to explore travel guides and reviews'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {},
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ─── TAB VIEW: CREATE ─────────────────────────────────────────────
class _CreateView extends StatelessWidget {
  const _CreateView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_circle_outline_rounded, size: 80, color: theme.colorScheme.primary.withValues(alpha: 0.8)),
            const SizedBox(height: 16),
            Text('Create Trip Entry', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(
              'Add photos, notes, and highlights of your recent travels to save in your digital log.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add_rounded),
              label: const Text('Start Logging'),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── TAB VIEW: TRIPS ──────────────────────────────────────────────
class _TripsView extends StatelessWidget {
  const _TripsView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Your Travel Logs', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: 2,
              itemBuilder: (context, index) {
                final titles = ['Summer Beach Getaway', 'Weekend Mountain Trekking'];
                final dates = ['July 10 - July 18', 'October 5 - October 7'];
                final spots = ['12 places visited', '3 trails hiked'];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: theme.colorScheme.secondary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                      child: Icon(Icons.card_travel_rounded, color: theme.colorScheme.secondary),
                    ),
                    title: Text(titles[index], style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(dates[index], style: theme.textTheme.bodySmall),
                        Text(spots[index], style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.primary)),
                      ],
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () {},
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ─── TAB VIEW: PROFILE ────────────────────────────────────────────
class _ProfileView extends StatelessWidget {
  const _ProfileView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final auth = Provider.of<AuthProvider>(context);
    final user = auth.user ?? {};

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // User Avatar
          Center(
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [theme.colorScheme.primary, theme.colorScheme.secondary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Center(
                child: Text(
                  (user['name'] ?? 'U').toString().substring(0, 1).toUpperCase(),
                  style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            (user['name'] ?? 'Guest').toString(),
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          Text(
            '@${user['username'] ?? 'guest'}',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 24),
          
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStatColumn(context, 'Followers', (user['followersCount'] ?? 0).toString()),
                  Container(height: 30, width: 1, color: theme.colorScheme.outline.withValues(alpha: 0.5)),
                  _buildStatColumn(context, 'Following', (user['followingCount'] ?? 0).toString()),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          _buildDetailItem(context, Icons.email_outlined, 'Email', (user['email'] ?? 'Not provided').toString()),
          _buildDetailItem(context, Icons.phone_outlined, 'Phone', (user['phone'] ?? 'Not provided').toString()),
          _buildDetailItem(context, Icons.public_outlined, 'Country', (user['country'] ?? 'Not specified').toString()),
          _buildDetailItem(context, Icons.description_outlined, 'Bio', (user['bio'] ?? 'No bio written yet.').toString()),
        ],
      ),
    );
  }

  Widget _buildStatColumn(BuildContext context, String label, String count) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(
          count,
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
        ),
        const SizedBox(height: 4),
        Text(label, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
      ],
    );
  }

  Widget _buildDetailItem(BuildContext context, IconData icon, String label, String value) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 22, color: theme.colorScheme.primary.withValues(alpha: 0.7)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(value, style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
