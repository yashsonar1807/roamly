import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/destination_provider.dart';
import '../providers/trip_provider.dart';
import '../utils/responsive.dart';
import '../widgets/custom_text_field.dart';
import 'home_view.dart';

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

    // View list passing appropriate callbacks
    final List<Widget> views = [
      HomeView(onCreateTripTap: _switchToCreateTab),
      const _ExploreView(),
      _CreateView(onTripCreated: _switchToTripsTab),
      const _TripsView(),
      const _ProfileView(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
        elevation: 0,
        actions: _selectedIndex == 4
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
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _triggerSearch(String val) {
    final provider = Provider.of<DestinationProvider>(context, listen: false);
    provider.setSearchQuery(val);
    provider.fetchDestinations(usePaginationFilters: true);
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
    Provider.of<DestinationProvider>(context, listen: false).fetchDestinations(usePaginationFilters: true);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = Provider.of<DestinationProvider>(context);

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
                      hintText: 'Search by destination, name, city...',
                      elevation: WidgetStateProperty.all(0),
                      backgroundColor: WidgetStateProperty.all(theme.colorScheme.surfaceContainerHighest),
                      shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
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
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                    ),
                    onPressed: () => _triggerSearch(_searchController.text),
                    child: const Icon(Icons.search_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 2. CATEGORIES SELECTOR
              SizedBox(
                height: 44,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final cat = _categories[index];
                    final isSelected = provider.selectedCategory == cat['name'];
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ChoiceChip(
                        label: Text('${cat['icon']}  ${cat['name']}'),
                        selected: isSelected,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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

              // 3. MINIMUM RATINGS CHIP ROW
              Row(
                children: [
                  Text(
                    'Min Rating:',
                    style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurfaceVariant),
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
                          final label = ratingVal == null ? 'All' : '⭐ $ratingVal+';
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: ChoiceChip(
                              label: Text(label, style: const TextStyle(fontSize: 11)),
                              selected: isSelected,
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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

              // 4. GRID OF DESTINATIONS
              Expanded(
                child: provider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : provider.errorMessage != null
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.error_outline_rounded, color: theme.colorScheme.error, size: 48),
                                const SizedBox(height: 16),
                                Text(provider.errorMessage!, style: TextStyle(color: theme.colorScheme.error)),
                                const SizedBox(height: 12),
                                ElevatedButton(onPressed: _loadData, child: const Text('Retry')),
                              ],
                            ),
                          )
                        : provider.destinations.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.search_off_rounded, size: 56, color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5)),
                                    const SizedBox(height: 16),
                                    const Text('No destinations match your search filters.', style: TextStyle(fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 8),
                                    TextButton(
                                      onPressed: () {
                                        _searchController.clear();
                                        provider.resetFilters();
                                        provider.fetchDestinations(usePaginationFilters: true);
                                      },
                                      child: const Text('Reset All Filters'),
                                    ),
                                  ],
                                ),
                              )
                            : GridView.builder(
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: crossAxisCount,
                                  crossAxisSpacing: 14,
                                  mainAxisSpacing: 14,
                                  childAspectRatio: childAspectRatio,
                                ),
                                itemCount: provider.destinations.length,
                                itemBuilder: (context, index) {
                                  final dest = provider.destinations[index];
                                  final imageUrl = (dest['images'] != null && (dest['images'] as List).isNotEmpty)
                                      ? dest['images'][0].toString()
                                      : 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?q=80&w=600';

                                  return Card(
                                    clipBehavior: Clip.antiAlias,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                    elevation: 2,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.stretch,
                                      children: [
                                        // Image section with floating badges
                                        Expanded(
                                          child: Stack(
                                            fit: StackFit.expand,
                                            children: [
                                              Image.network(imageUrl, fit: BoxFit.cover),
                                              // Rating Badge
                                              Positioned(
                                                top: 10,
                                                left: 10,
                                                child: Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                  decoration: BoxDecoration(
                                                    color: Colors.black.withValues(alpha: 0.7),
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      const Icon(Icons.star_rounded, color: Colors.amber, size: 14),
                                                      const SizedBox(width: 4),
                                                      Text(
                                                        (dest['rating'] ?? '4.8').toString(),
                                                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
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
                                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                  decoration: BoxDecoration(
                                                    color: theme.colorScheme.primary.withValues(alpha: 0.9),
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                                  child: Text(
                                                    (dest['category'] ?? 'TRAVEL').toString().toUpperCase(),
                                                    style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
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
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                dest['name'] ?? '',
                                                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 2),
                                              Row(
                                                children: [
                                                  Icon(Icons.location_on_rounded, color: theme.colorScheme.primary, size: 12),
                                                  const SizedBox(width: 4),
                                                  Expanded(
                                                    child: Text(
                                                      '${dest['city'] ?? ''}, ${dest['country'] ?? ''}',
                                                      style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 6),
                                              Text(
                                                dest['description'] ?? '',
                                                style: theme.textTheme.bodySmall?.copyWith(height: 1.3),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
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
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Page ${provider.currentPage} of ${provider.totalPages}',
                        style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
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

// ─── TAB VIEW: CREATE (WRITE OPERATION) ───────────────────────────
class _CreateView extends StatefulWidget {
  final VoidCallback onTripCreated;

  const _CreateView({required this.onTripCreated});

  @override
  State<_CreateView> createState() => _CreateViewState();
}

class _CreateViewState extends State<_CreateView> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _destinationController = TextEditingController();
  final _spotsController = TextEditingController();
  final _notesController = TextEditingController();

  void _submitForm() {
    if (!_formKey.currentState!.validate()) return;

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final tripProvider = Provider.of<TripProvider>(context, listen: false);

    tripProvider.createTrip(
      token: auth.accessToken!,
      title: _titleController.text.trim(),
      destination: _destinationController.text.trim(),
      spotsCount: int.tryParse(_spotsController.text.trim()) ?? 0,
      notes: _notesController.text.trim(),
      onSuccess: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Trip logged to MongoDB successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        _titleController.clear();
        _destinationController.clear();
        _spotsController.clear();
        _notesController.clear();
        widget.onTripCreated(); // Redirect to Trips tab list
      },
      onError: (err) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(err),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _destinationController.dispose();
    _spotsController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tripProvider = Provider.of<TripProvider>(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 450),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(Icons.add_circle_outline_rounded, size: 64, color: theme.colorScheme.primary),
                const SizedBox(height: 16),
                Text('Log a New Trip', textAlign: TextAlign.center, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(
                  'Write travel logs directly to the MongoDB backend database.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
                const SizedBox(height: 28),
                
                CustomTextField(
                  controller: _titleController,
                  label: 'Trip Title',
                  hint: 'e.g. Summer Beach Getaway',
                  prefixIcon: Icons.title_rounded,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return 'Please enter a trip title';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _destinationController,
                  label: 'Destination Name',
                  hint: 'e.g. Goa Beaches, Goa',
                  prefixIcon: Icons.pin_drop_rounded,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return 'Please specify the destination';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _spotsController,
                  label: 'Visited Places / Spots Count',
                  hint: 'e.g. 5',
                  prefixIcon: Icons.location_on_outlined,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _notesController,
                  label: 'Travel Notes / Details',
                  hint: 'Describe your favorite moments...',
                  prefixIcon: Icons.note_alt_outlined,
                ),
                const SizedBox(height: 28),
                
                tripProvider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton.icon(
                        onPressed: _submitForm,
                        icon: const Icon(Icons.cloud_upload_rounded),
                        label: const Text('Save to Cloud DB'),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── TAB VIEW: TRIPS (DATABASE DRIVEN) ────────────────────────────
class _TripsView extends StatefulWidget {
  const _TripsView();

  @override
  State<_TripsView> createState() => _TripsViewState();
}

class _TripsViewState extends State<_TripsView> {
  @override
  void initState() {
    super.initState();
    // Fetch trips list on view load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      Provider.of<TripProvider>(context, listen: false).fetchTrips(auth.accessToken!);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tripProvider = Provider.of<TripProvider>(context);

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Your Travel Logs (MongoDB)', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          
          Expanded(
            child: tripProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : tripProvider.errorMessage != null
                    ? Center(child: Text(tripProvider.errorMessage!, style: TextStyle(color: theme.colorScheme.error)))
                    : tripProvider.trips.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.card_travel_rounded, size: 64, color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5)),
                                const SizedBox(height: 16),
                                const Text('No trips logged yet.', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                                const SizedBox(height: 8),
                                const Text('Tap the Create tab to write your first travel log!', textAlign: TextAlign.center),
                              ],
                            ),
                          )
                        : ListView.builder(
                            itemCount: tripProvider.trips.length,
                            itemBuilder: (context, index) {
                              final trip = tripProvider.trips[index];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 16),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.all(16),
                                  leading: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                        color: theme.colorScheme.secondary.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(8)),
                                    child: Icon(Icons.card_travel_rounded, color: theme.colorScheme.secondary),
                                  ),
                                  title: Text(trip['title'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 4),
                                      Text(trip['destination'] ?? '', style: const TextStyle(fontWeight: FontWeight.w600)),
                                      const SizedBox(height: 2),
                                      Text('${trip['spotsCount'] ?? 0} spots visited', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.primary)),
                                      if (trip['notes'] != null && trip['notes'].toString().isNotEmpty) ...[
                                        const SizedBox(height: 6),
                                        Text('Notes: ${trip['notes']}', style: theme.textTheme.bodyMedium?.copyWith(fontStyle: FontStyle.italic)),
                                      ],
                                    ],
                                  ),
                                  trailing: const Icon(Icons.check_circle_rounded, color: Colors.green),
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
