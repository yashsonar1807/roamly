import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/routes.dart';
import '../providers/auth_provider.dart';
import '../providers/destination_provider.dart';
import '../providers/trip_provider.dart';
import '../providers/user_provider.dart';
import '../utils/responsive.dart';
import '../widgets/custom_text_field.dart';
import 'home_view.dart';
import 'create_view.dart';
import 'trips_view.dart';
import 'profile_view.dart';


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

  void _switchToTripsTab() {
    setState(() {
      _selectedIndex = 3; // Index of Trips tab
    });
  }

  void _switchToCreateTab() {
    setState(() {
      _selectedIndex = 2; // Index of Create tab
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDesktop = context.isDesktop;

    final List<Widget> views = [
      HomeView(
        onCreateTripTap: _switchToCreateTab,
        onExploreTap: () {
          setState(() {
            _selectedIndex = 1;
          });
        },
      ),
      const _ExploreView(),
      CreateView(onTripCreated: _switchToTripsTab),
      const TripsView(),
      const ProfileView(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: _selectedIndex == 0
            ? Image.asset(
                Theme.of(context).brightness == Brightness.dark
                    ? 'assets/images/logo_dark.png'
                    : 'assets/images/logo_light.png',
                height: 32,
              )
            : Text(_titles[_selectedIndex]),
        elevation: 0,
        actions: _selectedIndex == 4
            ? [
                IconButton(
                  icon: const Icon(Icons.logout_rounded),
                  onPressed: () async {
                    final auth = Provider.of<AuthProvider>(
                      context,
                      listen: false,
                    );
                    await auth.logout();
                    if (context.mounted) {
                      Navigator.pushReplacementNamed(context, '/login');
                    }
                  },
                ),
              ]
            : null,
      ),
      body: Row(
        children: [
          // Navigation Rail for Desktop/Tablet landscape
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

          // Viewport container with sliding page switch animation
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

// ─── TAB VIEW: EXPLORE (ADVANCED DRIVEN) ──────────────────────────
class _ExploreView extends StatefulWidget {
  const _ExploreView();

  @override
  State<_ExploreView> createState() => _ExploreViewState();
}

class _ExploreViewState extends State<_ExploreView> {
  final TextEditingController _searchController = TextEditingController();
  int _searchTypeIndex = 0; // 0 for Places, 1 for People

  final List<Map<String, String>> _categories = [
    {'name': 'All', 'icon': '🌍'},
    {'name': 'Mountains', 'icon': '⛰️'},
    {'name': 'Beaches', 'icon': '🏖️'},
    {'name': 'Heritage', 'icon': '🏛️'},
    {'name': 'Forests', 'icon': '🌲'},
    {'name': 'Adventure', 'icon': '⛺'},
  ];

  final List<double?> _ratingFilters = [null, 4.6, 4.8, 4.9];

  @override
  void initState() {
    super.initState();
    // Fetch destinations with pagination/filters on view load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<DestinationProvider>(context, listen: false);
      provider.resetFilters();
      _searchController.clear();
      provider.fetchDestinations(usePaginationFilters: true);

      final userProvider = Provider.of<UserProvider>(context, listen: false);
      userProvider.clearSearch();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _triggerSearch(String val) {
    if (_searchTypeIndex == 0) {
      final provider = Provider.of<DestinationProvider>(context, listen: false);
      provider.setSearchQuery(val);
      provider.fetchDestinations(usePaginationFilters: true);
    } else {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      if (val.trim().isNotEmpty) {
        userProvider.searchUsers(val);
      } else {
        userProvider.clearSearch();
      }
    }
  }

  void _changeCategory(String categoryName) {
    final provider = Provider.of<DestinationProvider>(context, listen: false);
    provider.setSelectedCategory(categoryName);
    provider.fetchDestinations(usePaginationFilters: true);
  }

  void _changeMinRating(double? rating) {
    final provider = Provider.of<DestinationProvider>(context, listen: false);
    provider.setMinRating(rating);
    provider.fetchDestinations(usePaginationFilters: true);
  }

  void _loadData() {
    if (_searchTypeIndex == 0) {
      Provider.of<DestinationProvider>(
        context,
        listen: false,
      ).fetchDestinations(usePaginationFilters: true);
    } else {
      Provider.of<UserProvider>(
        context,
        listen: false,
      ).searchUsers(_searchController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = Provider.of<DestinationProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);

    // Responsive grid cross-axis count calculation
    final width = MediaQuery.of(context).size.width;
    int crossAxisCount = 1;
    double childAspectRatio = 0.85;

    if (width > 1200) {
      crossAxisCount = 4;
      childAspectRatio = 0.8;
    } else if (width > 800) {
      crossAxisCount = 3;
      childAspectRatio = 0.8;
    } else if (width > 550) {
      crossAxisCount = 2;
      childAspectRatio = 0.85;
    }

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. SEARCH INPUT BAR WITH SUBMIT BUTTON
              Row(
                children: [
                  Expanded(
                    child: SearchBar(
                      controller: _searchController,
                      leading: const Icon(Icons.search_rounded),
                      hintText: _searchTypeIndex == 0
                          ? 'Search destinations...'
                          : 'Search people...',
                      elevation: WidgetStateProperty.all(0),
                      backgroundColor: WidgetStateProperty.all(
                        theme.colorScheme.surfaceContainerHighest,
                      ),
                      shape: WidgetStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onSubmitted: _triggerSearch,
                      trailing: [
                        if (_searchController.text.isNotEmpty)
                          IconButton(
                            icon: const Icon(Icons.close_rounded),
                            onPressed: () {
                              _searchController.clear();
                              _triggerSearch('');
                            },
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 56,
                    height: 56,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: theme.colorScheme.onPrimary,
                      ),
                      onPressed: () => _triggerSearch(_searchController.text),
                      child: const Icon(Icons.search_rounded),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 2. TOGGLE PLACES / PEOPLE
              SegmentedButton<int>(
                segments: const [
                  ButtonSegment(
                    value: 0,
                    label: Text('Places'),
                    icon: Icon(Icons.place_rounded),
                  ),
                  ButtonSegment(
                    value: 1,
                    label: Text('People'),
                    icon: Icon(Icons.person_search_rounded),
                  ),
                ],
                selected: {_searchTypeIndex},
                onSelectionChanged: (Set<int> newSelection) {
                  setState(() {
                    _searchTypeIndex = newSelection.first;
                    _triggerSearch(_searchController.text);
                  });
                },
              ),
              const SizedBox(height: 16),

              // conditionally show filters if Places is selected
              if (_searchTypeIndex == 0) ...[
                // CATEGORIES SELECTOR
                SizedBox(
                  height: 44,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _categories.length,
                    itemBuilder: (context, index) {
                      final cat = _categories[index];
                      final isSelected =
                          provider.selectedCategory == cat['name'];
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ChoiceChip(
                          label: Text('${cat['icon']}  ${cat['name']}'),
                          selected: isSelected,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          onSelected: (selected) {
                            if (selected) {
                              _changeCategory(cat['name']!);
                            }
                          },
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),

                // MINIMUM RATINGS CHIP ROW
                Row(
                  children: [
                    Text(
                      'Min Rating:',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: SizedBox(
                        height: 38,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _ratingFilters.length,
                          itemBuilder: (context, index) {
                            final ratingVal = _ratingFilters[index];
                            final isSelected = provider.minRating == ratingVal;
                            final label = ratingVal == null
                                ? 'All'
                                : '⭐ $ratingVal+';
                            return Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: ChoiceChip(
                                label: Text(
                                  label,
                                  style: const TextStyle(fontSize: 11),
                                ),
                                selected: isSelected,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                  vertical: 0,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                onSelected: (selected) {
                                  if (selected) {
                                    _changeMinRating(ratingVal);
                                  }
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],

              // 4. MAIN CONTENT AREA
              Expanded(
                child: _searchTypeIndex == 0
                    // --- DESTINATIONS LIST ---
                    ? (provider.isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : provider.errorMessage != null
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.error_outline_rounded,
                                    color: theme.colorScheme.error,
                                    size: 48,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    provider.errorMessage!,
                                    style: TextStyle(
                                      color: theme.colorScheme.error,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  ElevatedButton(
                                    onPressed: _loadData,
                                    child: const Text('Retry'),
                                  ),
                                ],
                              ),
                            )
                          : provider.destinations.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.search_off_rounded,
                                    size: 56,
                                    color: theme.colorScheme.onSurfaceVariant
                                        .withValues(alpha: 0.5),
                                  ),
                                  const SizedBox(height: 16),
                                  const Text(
                                    'No destinations match your search filters.',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  TextButton(
                                    onPressed: () {
                                      _searchController.clear();
                                      provider.resetFilters();
                                      provider.fetchDestinations(
                                        usePaginationFilters: true,
                                      );
                                    },
                                    child: const Text('Reset All Filters'),
                                  ),
                                ],
                              ),
                            )
                          : GridView.builder(
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: crossAxisCount,
                                    crossAxisSpacing: 14,
                                    mainAxisSpacing: 14,
                                    childAspectRatio: childAspectRatio,
                                  ),
                              itemCount: provider.destinations.length,
                              itemBuilder: (context, index) {
                                final dest = provider.destinations[index];
                                final imageUrl =
                                    (dest['images'] != null &&
                                        (dest['images'] as List).isNotEmpty)
                                    ? dest['images'][0].toString()
                                    : 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?q=80&w=600';

                                return GestureDetector(
                                  onTap: () {
                                    Navigator.pushNamed(
                                      context,
                                      AppRoutes.destinationDetail,
                                      arguments: dest,
                                    );
                                  },
                                  child: Card(
                                    clipBehavior: Clip.antiAlias,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    elevation: 2,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        // Image section with floating badges
                                        Expanded(
                                          child: Stack(
                                            fit: StackFit.expand,
                                            children: [
                                              Image.network(
                                                imageUrl,
                                                fit: BoxFit.cover,
                                              ),
                                              // Rating Badge
                                              Positioned(
                                                top: 10,
                                                left: 10,
                                                child: Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 8,
                                                        vertical: 4,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    color: Colors.black
                                                        .withValues(alpha: 0.7),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          8,
                                                        ),
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      const Icon(
                                                        Icons.star_rounded,
                                                        color: Colors.amber,
                                                        size: 14,
                                                      ),
                                                      const SizedBox(width: 4),
                                                      Text(
                                                        (dest['rating'] ??
                                                                '4.8')
                                                            .toString(),
                                                        style: const TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 10,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              // Category Badge
                                              Positioned(
                                                top: 10,
                                                right: 10,
                                                child: Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 8,
                                                        vertical: 4,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    color: theme
                                                        .colorScheme
                                                        .primary
                                                        .withValues(alpha: 0.9),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          8,
                                                        ),
                                                  ),
                                                  child: Text(
                                                    (dest['category'] ??
                                                            'TRAVEL')
                                                        .toString()
                                                        .toUpperCase(),
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 9,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        // Card content details
                                        Padding(
                                          padding: const EdgeInsets.all(12.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                dest['name'] ?? '',
                                                style: theme
                                                    .textTheme
                                                    .titleMedium
                                                    ?.copyWith(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 2),
                                              Row(
                                                children: [
                                                  Icon(
                                                    Icons.location_on_rounded,
                                                    color: theme
                                                        .colorScheme
                                                        .primary,
                                                    size: 12,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Expanded(
                                                    child: Text(
                                                      '${dest['city'] ?? ''}, ${dest['country'] ?? ''}',
                                                      style: theme
                                                          .textTheme
                                                          .bodySmall
                                                          ?.copyWith(
                                                            color: theme
                                                                .colorScheme
                                                                .onSurfaceVariant,
                                                          ),
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 6),
                                              Text(
                                                dest['description'] ?? '',
                                                style: theme.textTheme.bodySmall
                                                    ?.copyWith(height: 1.3),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ))
                    // --- USERS LIST ---
                    : (userProvider.isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : userProvider.errorMessage != null
                          ? Center(
                              child: Text(
                                userProvider.errorMessage!,
                                style: TextStyle(
                                  color: theme.colorScheme.error,
                                ),
                              ),
                            )
                          : userProvider.searchResults.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.person_search_rounded,
                                    size: 56,
                                    color: theme.colorScheme.onSurfaceVariant
                                        .withValues(alpha: 0.5),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    _searchController.text.isEmpty
                                        ? 'Search for people'
                                        : 'No users found.',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.separated(
                              itemCount: userProvider.searchResults.length,
                              separatorBuilder: (context, index) =>
                                  const Divider(height: 1),
                              itemBuilder: (context, index) {
                                final user = userProvider.searchResults[index];
                                return ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 8.0,
                                    horizontal: 8.0,
                                  ),
                                  leading: CircleAvatar(
                                    radius: 24,
                                    backgroundImage:
                                        user.profileImage.isNotEmpty
                                        ? NetworkImage(user.profileImage)
                                        : null,
                                    child: user.profileImage.isEmpty
                                        ? const Icon(Icons.person)
                                        : null,
                                  ),
                                  title: Text(
                                    user.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Text('@${user.username}'),
                                  trailing: OutlinedButton(
                                    onPressed: () {},
                                    style: OutlinedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                    ),
                                    child: const Text('Follow'),
                                  ),
                                  onTap: () {
                                    // Navigate to user profile later
                                  },
                                );
                              },
                            )),
              ),

              // 5. PAGINATION SELECTOR FOOTER (Shown only if totalPages > 1)
              if (provider.totalPages > 1) ...[
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left_rounded),
                      onPressed: provider.currentPage > 1
                          ? () => provider.setPage(provider.currentPage - 1)
                          : null,
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Page ${provider.currentPage} of ${provider.totalPages}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.chevron_right_rounded),
                      onPressed: provider.currentPage < provider.totalPages
                          ? () => provider.setPage(provider.currentPage + 1)
                          : null,
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

