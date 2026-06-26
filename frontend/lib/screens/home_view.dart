import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/story_provider.dart';
import '../providers/post_provider.dart';
import '../providers/destination_provider.dart';

class HomeView extends StatefulWidget {
  final VoidCallback onCreateTripTap;

  const HomeView({super.key, required this.onCreateTripTap});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  String _selectedCategory = 'Mountains';

  final List<Map<String, String>> _categories = [
    {'name': 'Mountains', 'icon': '⛰️'},
    {'name': 'Beaches', 'icon': '🏖️'},
    {'name': 'Heritage', 'icon': '🏛️'},
    {'name': 'Forests', 'icon': '🌲'},
    {'name': 'Adventure', 'icon': '⛺'},
  ];

  @override
  void initState() {
    super.initState();
    // Fetch stories, posts, and destinations from MongoDB database on load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<StoryProvider>(context, listen: false).fetchStories();
      Provider.of<PostProvider>(context, listen: false).fetchPosts();
      Provider.of<DestinationProvider>(context, listen: false).fetchDestinations();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    final storyProvider = Provider.of<StoryProvider>(context);
    final postProvider = Provider.of<PostProvider>(context);
    final destProvider = Provider.of<DestinationProvider>(context);

    // Limit destinations for Trending list (e.g. up to 3)
    final trendingDestinations = destProvider.destinations.take(3).toList();
    // Get recommended (take next one or fallback)
    final recommendedDest = destProvider.destinations.length > 3 
        ? destProvider.destinations[3] 
        : (destProvider.destinations.isNotEmpty ? destProvider.destinations.first : null);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. STORIES SECTION (DATABASE DRIVEN)
              SizedBox(
                height: 104,
                child: storyProvider.isLoading
                    ? const Center(child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2)))
                    : storyProvider.stories.isEmpty
                        ? const Center(child: Text('No stories', style: TextStyle(fontSize: 12)))
                        : ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            itemCount: storyProvider.stories.length,
                            itemBuilder: (context, index) {
                              final story = storyProvider.stories[index];
                              return Padding(
                                padding: const EdgeInsets.only(right: 18),
                                child: Column(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(3),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: LinearGradient(
                                          colors: [theme.colorScheme.primary, theme.colorScheme.secondary],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                      ),
                                      child: CircleAvatar(
                                        radius: 32,
                                        backgroundImage: NetworkImage(story['userAvatar'] ?? ''),
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      story['userName'] ?? '',
                                      style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
              ),
              const SizedBox(height: 16),

              // 2. SEARCH BAR WITH FILTER
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: SearchBar(
                        leading: const Icon(Icons.search_rounded),
                        hintText: 'Search destinations, hotels...',
                        elevation: WidgetStateProperty.all(0),
                        backgroundColor: WidgetStateProperty.all(theme.colorScheme.surfaceContainerHighest),
                        shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        Icons.tune_rounded,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 3. CATEGORIES TABS
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Categories',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 48,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final cat = _categories[index];
                    final isSelected = _selectedCategory == cat['name'];
                    return Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: ChoiceChip(
                        label: Text('${cat['icon']}  ${cat['name']}'),
                        selected: isSelected,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        onSelected: (selected) {
                          setState(() {
                            _selectedCategory = cat['name']!;
                          });
                        },
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 28),

              // 4. TRENDING DESTINATIONS (DATABASE DRIVEN)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Trending Destinations', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    TextButton(onPressed: () {}, child: const Text('See All')),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 220,
                child: destProvider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : trendingDestinations.isEmpty
                        ? const Center(child: Text('No trending destinations found.'))
                        : ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            itemCount: trendingDestinations.length,
                            itemBuilder: (context, index) {
                              final item = trendingDestinations[index];
                              final imageUrl = (item['images'] != null && (item['images'] as List).isNotEmpty)
                                  ? item['images'][0].toString()
                                  : 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?q=80&w=600';
                              return Container(
                                width: 170,
                                margin: const EdgeInsets.only(right: 16),
                                child: Card(
                                  clipBehavior: Clip.antiAlias,
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      Image.network(imageUrl, fit: BoxFit.cover),
                                      Container(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [Colors.black.withValues(alpha: 0.8), Colors.transparent],
                                            begin: Alignment.bottomCenter,
                                            end: Alignment.topCenter,
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        top: 12,
                                        right: 12,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: Colors.black.withValues(alpha: 0.6),
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: Row(
                                            children: [
                                              const Icon(Icons.star_rounded, color: Colors.amber, size: 14),
                                              const SizedBox(width: 4),
                                              Text(
                                                (item['rating'] ?? '4.5').toString(),
                                                style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        bottom: 12,
                                        left: 12,
                                        right: 12,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              item['name'] ?? '',
                                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                                            ),
                                            const SizedBox(height: 2),
                                            Row(
                                              children: [
                                                const Icon(Icons.location_on_rounded, color: Colors.white70, size: 12),
                                                const SizedBox(width: 4),
                                                Expanded(
                                                  child: Text(
                                                    '${item['city'] ?? ''}, ${item['country'] ?? ''}',
                                                    style: const TextStyle(color: Colors.white70, fontSize: 11),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
              ),
              const SizedBox(height: 28),

              // 5. RECOMMENDED PLACES (DATABASE DRIVEN)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Recommended for You',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: destProvider.isLoading
                    ? const Center(child: SizedBox(height: 24, width: 24, child: CircularProgressIndicator()))
                    : recommendedDest == null
                        ? const Center(child: Text('No recommended destinations.'))
                        : Card(
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
                                  child: Image.network(
                                    (recommendedDest['images'] != null && (recommendedDest['images'] as List).isNotEmpty)
                                        ? recommendedDest['images'][0].toString()
                                        : 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?q=80&w=600',
                                    width: 110,
                                    height: 110,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: theme.colorScheme.secondary.withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            recommendedDest['category']?.toString().toUpperCase() ?? 'RECOMMENDED',
                                            style: TextStyle(
                                              color: theme.colorScheme.secondary,
                                              fontSize: 9,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          recommendedDest['name'] ?? '',
                                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Icon(Icons.star_rounded, color: Colors.amber[700], size: 14),
                                            const SizedBox(width: 4),
                                            Text(
                                              '${recommendedDest['rating'] ?? 4.8} (Vibrant spot in ${recommendedDest['city'] ?? ''})',
                                              style: const TextStyle(fontSize: 11),
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
              ),
              const SizedBox(height: 28),

              // 6. TRAVEL FEED SECTION (DATABASE DRIVEN)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text('Travel Feed & Experiences', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 12),
              postProvider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : postProvider.posts.isEmpty
                      ? const Center(child: Text('No travel posts loaded.'))
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: postProvider.posts.length,
                          itemBuilder: (context, index) {
                            final post = postProvider.posts[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 20),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 20,
                                          backgroundImage: NetworkImage(post['authorAvatar'] ?? ''),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(post['authorName'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                                              Text(post['authorRole'] ?? 'Traveler', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                                            ],
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.more_horiz_rounded),
                                          onPressed: () {},
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 14),
                                    Text(post['title'] ?? '', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 6),
                                    Text(post['description'] ?? '', style: theme.textTheme.bodyMedium?.copyWith(height: 1.4)),
                                    if (post['image'] != null) ...[
                                      const SizedBox(height: 12),
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: Image.network(post['image']!, fit: BoxFit.cover, height: 180, width: double.infinity),
                                      ),
                                    ],
                                    const SizedBox(height: 14),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(Icons.favorite_rounded, color: theme.colorScheme.error, size: 20),
                                            const SizedBox(width: 6),
                                            Text((post['likesCount'] ?? 0).toString(), style: const TextStyle(fontWeight: FontWeight.w600)),
                                            const SizedBox(width: 18),
                                            Icon(Icons.chat_bubble_outline_rounded, color: theme.colorScheme.primary, size: 20),
                                            const SizedBox(width: 6),
                                            Text((post['commentsCount'] ?? 0).toString(), style: const TextStyle(fontWeight: FontWeight.w600)),
                                          ],
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.bookmark_border_rounded),
                                          onPressed: () {},
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: widget.onCreateTripTap,
        icon: const Icon(Icons.add_location_alt_rounded),
        label: const Text('Log Trip'),
      ),
    );
  }
}
