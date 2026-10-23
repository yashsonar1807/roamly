import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../config/routes.dart';
import '../config/colors.dart';
import '../providers/auth_provider.dart';
import '../providers/destination_provider.dart';
import '../providers/user_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/notification_provider.dart';
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
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktopWeb = screenWidth >= 900;

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

    if (isDesktopWeb) {
      // ─── DESKTOP WEB LAYOUT WITH FULL TOP NAVBAR ───
      return Scaffold(
        body: Column(
          children: [
            _buildWebTopNav(context),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return FadeTransition(opacity: animation, child: child);
                },
                child: KeyedSubtree(
                  key: ValueKey<int>(_selectedIndex),
                  child: views[_selectedIndex],
                ),
              ),
            ),
          ],
        ),
      );
    }

    // ─── MOBILE & TABLET WEB LAYOUT WITH LUMINOUS TRAVEL DOCK ───
    return Scaffold(
      extendBody: true,
      appBar: _buildMobileTopNav(context),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(opacity: animation, child: child);
        },
        child: KeyedSubtree(
          key: ValueKey<int>(_selectedIndex),
          child: views[_selectedIndex],
        ),
      ),
      bottomNavigationBar: _buildLuminousBottomDock(context),
    );
  }

  PreferredSizeWidget _buildMobileTopNav(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final themeProvider = Provider.of<ThemeProvider>(context);
    final notificationProvider = Provider.of<NotificationProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;
    final userName = user?['name'] ?? 'Traveler';
    final userAvatar = user?['profileImage'] ??
        'https://ui-avatars.com/api/?name=${Uri.encodeComponent(userName)}&background=0EA5E9&color=fff';

    return AppBar(
      elevation: 0,
      backgroundColor: theme.scaffoldBackgroundColor,
      titleSpacing: 14,
      title: Row(
        children: [
          Image.asset(
            isDark ? 'assets/images/logo_dark_v3.png' : 'assets/images/logo_light_v3.png',
            height: 34,
            fit: BoxFit.contain,
          ),
          const SizedBox(width: 8),
          const Text(
            'ROAMLY',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
              fontSize: 16,
            ),
          ),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
            decoration: BoxDecoration(
              gradient: AppColors.rankGradient,
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Text(
              'WEB',
              style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          tooltip: 'Search Places',
          icon: const Icon(Icons.search_rounded, size: 22),
          onPressed: () {
            setState(() => _selectedIndex = 1);
          },
        ),
        IconButton(
          tooltip: 'Switch Theme',
          icon: Icon(
            themeProvider.isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
            color: themeProvider.isDarkMode ? Colors.amber : null,
            size: 20,
          ),
          onPressed: () {
            themeProvider.toggleTheme(!themeProvider.isDarkMode);
          },
        ),
        IconButton(
          tooltip: 'Notifications',
          icon: Badge(
            isLabelVisible: notificationProvider.unreadCount > 0,
            label: Text('${notificationProvider.unreadCount}'),
            child: const Icon(Icons.notifications_outlined, size: 21),
          ),
          onPressed: () {
            Navigator.pushNamed(context, AppRoutes.notifications);
          },
        ),
        InkWell(
          onTap: () => setState(() => _selectedIndex = 4),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.only(right: 14, left: 4),
            child: CircleAvatar(
              radius: 14,
              backgroundImage: CachedNetworkImageProvider(userAvatar),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWebTopNav(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final authProvider = Provider.of<AuthProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final notificationProvider = Provider.of<NotificationProvider>(context);

    final user = authProvider.user;
    final userName = user?['name'] ?? 'Traveler';
    final userAvatar = user?['profileImage'] ??
        'https://ui-avatars.com/api/?name=${Uri.encodeComponent(userName)}&background=0EA5E9&color=fff';

    final screenWidth = MediaQuery.of(context).size.width;
    final showUserName = screenWidth > 860;

    return Container(
      height: 68,
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        border: Border(
          bottom: BorderSide(
            color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.06),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          // BRAND LOGO & TITLE
          InkWell(
            onTap: () => setState(() => _selectedIndex = 0),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              child: Row(
                children: [
                  Image.asset(
                    isDark ? 'assets/images/logo_dark_v3.png' : 'assets/images/logo_light_v3.png',
                    height: 36,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'ROAMLY',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                      fontSize: 17,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    decoration: BoxDecoration(
                      gradient: AppColors.rankGradient,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'WEB',
                      style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(width: 8),

          // CENTER NAVIGATION PILLS (FLEXIBLE & SCROLLABLE)
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildWebNavItem(0, Icons.home_rounded, Icons.home_outlined, 'Feed'),
                    _buildWebNavItem(1, Icons.explore_rounded, Icons.explore_outlined, 'Explore'),
                    _buildWebNavItem(2, Icons.add_circle_rounded, Icons.add_circle_outline_rounded, 'Create'),
                    _buildWebNavItem(3, Icons.flight_takeoff_rounded, Icons.card_travel_outlined, 'My Trips'),
                    _buildWebNavItem(4, Icons.person_rounded, Icons.person_outline_rounded, 'Profile'),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(width: 8),

          // RIGHT ACTIONS
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Theme Switcher
              IconButton(
                tooltip: 'Switch to ${themeProvider.isDarkMode ? 'Light' : 'Dark'} Mode',
                icon: Icon(
                  themeProvider.isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                  color: themeProvider.isDarkMode ? Colors.amber : null,
                  size: 20,
                ),
                onPressed: () {
                  themeProvider.toggleTheme(!themeProvider.isDarkMode);
                },
              ),

              // Notifications
              IconButton(
                tooltip: 'Notifications',
                icon: Badge(
                  isLabelVisible: notificationProvider.unreadCount > 0,
                  label: Text('${notificationProvider.unreadCount}'),
                  child: const Icon(Icons.notifications_outlined, size: 21),
                ),
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.notifications);
                },
              ),
              const SizedBox(width: 4),

              // User Profile Chip
              InkWell(
                onTap: () => setState(() => _selectedIndex = 4),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: showUserName ? 8 : 4,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _selectedIndex == 4 ? AppColors.primary : Colors.transparent,
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        radius: 13,
                        backgroundImage: CachedNetworkImageProvider(userAvatar),
                      ),
                      if (showUserName) ...[
                        const SizedBox(width: 6),
                        Text(
                          userName.toString().split(' ')[0],
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              // Settings button
              IconButton(
                tooltip: 'Settings',
                icon: const Icon(Icons.settings_outlined, size: 20),
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.settings);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWebNavItem(int index, IconData selectedIcon, IconData unselectedIcon, String label) {
    final isSelected = _selectedIndex == index;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: InkWell(
        onTap: () => setState(() => _selectedIndex = index),
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withValues(alpha: isDark ? 0.25 : 0.12)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Icon(
                isSelected ? selectedIcon : unselectedIcon,
                color: isSelected ? AppColors.primaryDark : (isDark ? Colors.white70 : Colors.black87),
                size: 19,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? AppColors.primaryDark : (isDark ? Colors.white70 : Colors.black87),
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  fontSize: 13.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLuminousBottomDock(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(left: 14, right: 14, bottom: 12),
      height: 64,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF131B2E).withValues(alpha: 0.95) : Colors.white.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.08),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildDockItem(0, Icons.home_rounded, Icons.home_outlined, 'Feed'),
          _buildDockItem(1, Icons.explore_rounded, Icons.explore_outlined, 'Explore'),
          _buildDockCenterItem(2),
          _buildDockItem(3, Icons.flight_takeoff_rounded, Icons.flight_takeoff_outlined, 'Trips'),
          _buildDockItem(4, Icons.person_rounded, Icons.person_outline_rounded, 'Profile'),
        ],
      ),
    );
  }

  Widget _buildDockItem(int index, IconData selectedIcon, IconData unselectedIcon, String label) {
    final isSelected = _selectedIndex == index;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedIndex = index),
        borderRadius: BorderRadius.circular(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? selectedIcon : unselectedIcon,
              color: isSelected ? AppColors.primary : (isDark ? Colors.white60 : Colors.black54),
              size: 22,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? AppColors.primary : (isDark ? Colors.white60 : Colors.black54),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDockCenterItem(int index) {
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          gradient: AppColors.rankGradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add_rounded, color: Colors.white, size: 18),
            SizedBox(width: 4),
            Text(
              'Plan',
              style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
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
  final SearchController _searchController = SearchController();
  int _searchTypeIndex = 0; // 0 for Places, 1 for People
  Timer? _debounce;

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
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String val) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _triggerSearch(val);
    });
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
    double childAspectRatio = 1.05;

    if (width > 1200) {
      crossAxisCount = 4;
      childAspectRatio = 0.74;
    } else if (width > 850) {
      crossAxisCount = 3;
      childAspectRatio = 0.74;
    } else if (width > 540) {
      crossAxisCount = 2;
      childAspectRatio = 0.76;
    } else {
      crossAxisCount = 1;
      childAspectRatio = 1.12;
    }

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 1200),
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
              // 1. SEARCH INPUT BAR WITH SUBMIT BUTTON
              Row(
                children: [
                  Expanded(
                    child: SearchAnchor(
                      searchController: _searchController,
                      builder: (BuildContext context, SearchController controller) {
                        return SearchBar(
                          controller: controller,
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
                          onTap: () {
                            if (_searchTypeIndex == 1) {
                              controller.openView();
                            }
                          },
                          onChanged: (val) {
                            if (_searchTypeIndex == 1) {
                              controller.openView();
                            } else {
                              _onSearchChanged(val);
                            }
                          },
                          onSubmitted: (val) {
                            if (_searchTypeIndex == 0) {
                              _triggerSearch(val);
                            }
                          },
                          trailing: [
                            if (controller.text.isNotEmpty)
                              IconButton(
                                icon: const Icon(Icons.close_rounded),
                                onPressed: () {
                                  controller.clear();
                                  _triggerSearch('');
                                },
                              ),
                          ],
                        );
                      },
                      suggestionsBuilder: (BuildContext context, SearchController controller) async {
                        if (_searchTypeIndex == 0 || controller.text.trim().isEmpty) {
                          return const Iterable<Widget>.empty();
                        }
                        final userProvider = Provider.of<UserProvider>(context, listen: false);
                        final users = await userProvider.searchUsersDirect(controller.text);
                        
                        return users.map((user) {
                          final profileImage = user['profileImage']?.toString() ?? '';
                          final name = user['name']?.toString() ?? '';
                          final username = user['username']?.toString() ?? '';
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundImage: profileImage.isNotEmpty
                                  ? NetworkImage(profileImage)
                                  : null,
                              child: profileImage.isEmpty
                                  ? const Icon(Icons.person)
                                  : null,
                            ),
                            title: Text(name),
                            subtitle: Text('@$username'),
                            onTap: () {
                              controller.closeView(name);
                              Navigator.pushNamed(
                                context,
                                AppRoutes.publicProfile,
                                arguments: user['_id'],
                              );
                            },
                          );
                        });
                      },
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
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).brightness == Brightness.dark
                                          ? const Color(0xFF131B2E)
                                          : Colors.white,
                                      borderRadius: BorderRadius.circular(18),
                                      border: Border.all(
                                        color: Theme.of(context).brightness == Brightness.dark
                                            ? Colors.white.withValues(alpha: 0.08)
                                            : Colors.black.withValues(alpha: 0.06),
                                        width: 1,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(
                                            alpha: Theme.of(context).brightness == Brightness.dark ? 0.25 : 0.05,
                                          ),
                                          blurRadius: 12,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    clipBehavior: Clip.antiAlias,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.stretch,
                                      children: [
                                        // Top Image with Badges
                                        SizedBox(
                                          height: 155,
                                          child: Stack(
                                            fit: StackFit.expand,
                                            children: [
                                              Image.network(
                                                imageUrl,
                                                fit: BoxFit.cover,
                                                errorBuilder: (_, __, ___) => Container(
                                                  color: Colors.grey[800],
                                                  child: const Icon(Icons.landscape_rounded, color: Colors.grey),
                                                ),
                                              ),
                                              Container(
                                                decoration: const BoxDecoration(
                                                  gradient: LinearGradient(
                                                    colors: [Color(0x66000000), Color(0x00000000), Color(0x77000000)],
                                                    begin: Alignment.topCenter,
                                                    end: Alignment.bottomCenter,
                                                  ),
                                                ),
                                              ),
                                              Positioned(
                                                top: 10,
                                                left: 10,
                                                child: Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                  decoration: BoxDecoration(
                                                    color: Colors.black.withValues(alpha: 0.75),
                                                    borderRadius: BorderRadius.circular(10),
                                                    border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                                                  ),
                                                  child: Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      const Icon(Icons.star_rounded, color: Colors.amber, size: 13),
                                                      const SizedBox(width: 3),
                                                      Text(
                                                        (dest['rating'] ?? '4.8').toString(),
                                                        style: const TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 11,
                                                          fontWeight: FontWeight.bold,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              Positioned(
                                                top: 10,
                                                right: 10,
                                                child: Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                  decoration: BoxDecoration(
                                                    color: AppColors.primary,
                                                    borderRadius: BorderRadius.circular(10),
                                                  ),
                                                  child: Text(
                                                    (dest['category'] ?? 'TRAVEL').toString().toUpperCase(),
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 10,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Positioned(
                                                bottom: 8,
                                                left: 10,
                                                child: Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                                  decoration: BoxDecoration(
                                                    color: Colors.black.withValues(alpha: 0.65),
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                                  child: const Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      Text('☀️', style: TextStyle(fontSize: 10)),
                                                      SizedBox(width: 3),
                                                      Text(
                                                        '26°C • Perfect Season',
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 10,
                                                          fontWeight: FontWeight.w600,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        // Bottom Metadata Section
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.all(12.0),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      dest['name'] ?? '',
                                                      style: theme.textTheme.titleMedium?.copyWith(
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 15,
                                                      ),
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                    const SizedBox(height: 3),
                                                    Row(
                                                      children: [
                                                        const Icon(
                                                          Icons.location_on_rounded,
                                                          color: AppColors.primary,
                                                          size: 13,
                                                        ),
                                                        const SizedBox(width: 3),
                                                        Expanded(
                                                          child: Text(
                                                            '${dest['city'] ?? ''}, ${dest['country'] ?? ''}',
                                                            style: TextStyle(
                                                              fontSize: 12,
                                                              color: Theme.of(context).brightness == Brightness.dark
                                                                  ? Colors.white60
                                                                  : Colors.black54,
                                                            ),
                                                            maxLines: 1,
                                                            overflow: TextOverflow.ellipsis,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Container(
                                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                                      decoration: BoxDecoration(
                                                        color: const Color(0xFF10B981).withValues(alpha: 0.12),
                                                        borderRadius: BorderRadius.circular(6),
                                                      ),
                                                      child: const Row(
                                                        mainAxisSize: MainAxisSize.min,
                                                        children: [
                                                          Icon(Icons.wifi_rounded, size: 11, color: Color(0xFF10B981)),
                                                          SizedBox(width: 3),
                                                          Text(
                                                            '120 Mbps',
                                                            style: TextStyle(
                                                              fontSize: 10,
                                                              fontWeight: FontWeight.bold,
                                                              color: Color(0xFF10B981),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    const Row(
                                                      children: [
                                                        Text(
                                                          'Explore',
                                                          style: TextStyle(
                                                            fontSize: 11,
                                                            fontWeight: FontWeight.bold,
                                                            color: AppColors.primary,
                                                          ),
                                                        ),
                                                        SizedBox(width: 2),
                                                        Icon(Icons.arrow_forward_rounded, size: 12, color: AppColors.primary),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
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
                              itemBuilder: (itemCtx, index) {
                                final user = userProvider.searchResults[index];
                                final profileImage = user['profileImage']?.toString() ?? '';
                                final name = user['name']?.toString() ?? '';
                                final username = user['username']?.toString() ?? '';
                                return ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 8.0,
                                    horizontal: 8.0,
                                  ),
                                  leading: CircleAvatar(
                                    radius: 24,
                                    backgroundImage:
                                        profileImage.isNotEmpty
                                        ? NetworkImage(profileImage)
                                        : null,
                                    child: profileImage.isEmpty
                                        ? const Icon(Icons.person)
                                        : null,
                                  ),
                                  title: Text(
                                    name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Text('@$username'),
                                  trailing: OutlinedButton(
                                    onPressed: () async {
                                      final auth = Provider.of<AuthProvider>(context, listen: false);
                                      final messenger = ScaffoldMessenger.of(context);
                                      if (auth.accessToken != null) {
                                        await userProvider.toggleFollow(auth.accessToken!, user['_id'] ?? user['id']);
                                        messenger.showSnackBar(
                                          const SnackBar(content: Text('Follow request sent!')),
                                        );
                                      }
                                    },
                                    style: OutlinedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                    ),
                                    child: const Text('Follow'),
                                  ),
                                  onTap: () {
                                    Navigator.pushNamed(
                                      context,
                                      AppRoutes.publicProfile,
                                      arguments: user['_id'],
                                    );
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
      ),
    );
  }
}

