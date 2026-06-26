import 'package:flutter/material.dart';

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

  final List<Map<String, String>> _stories = [
    {
      'name': 'Aarav',
      'avatar': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?q=80&w=200',
    },
    {
      'name': 'Ananya',
      'avatar': 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&w=200',
    },
    {
      'name': 'Kabir',
      'avatar': 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?q=80&w=200',
    },
    {
      'name': 'Diya',
      'avatar': 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?q=80&w=200',
    },
    {
      'name': 'Rohan',
      'avatar': 'https://images.unsplash.com/photo-1522075469751-3a6694fb2f61?q=80&w=200',
    },
  ];

  final List<Map<String, dynamic>> _trending = [
    {
      'title': 'Taj Mahal',
      'location': 'Agra, UP',
      'rating': '4.9',
      'image': 'https://images.unsplash.com/photo-1564507592333-c60657eea523?q=80&w=600',
    },
    {
      'title': 'Munnar Tea Estates',
      'location': 'Munnar, Kerala',
      'rating': '4.8',
      'image': 'https://images.unsplash.com/photo-1593693397690-362cb9666fc2?q=80&w=600',
    },
    {
      'title': 'Solang Valley',
      'location': 'Manali, HP',
      'rating': '4.7',
      'image': 'https://images.unsplash.com/photo-1544735716-392fe2489ffa?q=80&w=600',
    },
  ];

  final List<Map<String, dynamic>> _feed = [
    {
      'author': 'Amit Sharma',
      'role': 'Explorer',
      'avatar': 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?q=80&w=200',
      'title': 'Watching sunrise in Varanasi 🌅',
      'description': 'Witnessed the spiritual Ganga Aarti at sunrise. There is an inexplicable tranquility in the air of Varanasi that everyone must experience at least once.',
      'image': 'https://images.unsplash.com/photo-1561361062-65223e441c71?q=80&w=600',
      'likes': '1.2k',
      'comments': '45',
    },
    {
      'author': 'Priya Patel',
      'role': 'Vagabond',
      'avatar': 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?q=80&w=200',
      'title': 'Chasing waves in South Goa 🌊',
      'description': 'Spent the day exploring isolated beaches in Palolem. White sands, clear water, and fresh coconut water. Truly paradise!',
      'image': 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?q=80&w=600',
      'likes': '890',
      'comments': '23',
    }
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. STORIES SECTION
              SizedBox(
                height: 104,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: _stories.length,
                  itemBuilder: (context, index) {
                    final story = _stories[index];
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
                              backgroundImage: NetworkImage(story['avatar']!),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            story['name']!,
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

              // 4. TRENDING DESTINATIONS
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
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: _trending.length,
                  itemBuilder: (context, index) {
                    final item = _trending[index];
                    return Container(
                      width: 170,
                      margin: const EdgeInsets.only(right: 16),
                      child: Card(
                        clipBehavior: Clip.antiAlias,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.network(item['image']!, fit: BoxFit.cover),
                            // Gradient Overlay
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Colors.black.withValues(alpha: 0.8), Colors.transparent],
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                ),
                              ),
                            ),
                            // Floating Rating Badge
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
                                      item['rating']!,
                                      style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            // Info Text
                            Positioned(
                              bottom: 12,
                              left: 12,
                              right: 12,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item['title']!,
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                                  ),
                                  const SizedBox(height: 2),
                                  Row(
                                    children: [
                                      const Icon(Icons.location_on_rounded, color: Colors.white70, size: 12),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          item['location']!,
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

              // 5. RECOMMENDED PLACES
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
                child: Card(
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
                        child: Image.network(
                          'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?q=80&w=600',
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
                                  'BEST SELLER',
                                  style: TextStyle(
                                    color: theme.colorScheme.secondary,
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Goa Coastal cruise tour',
                                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(Icons.star_rounded, color: Colors.amber[700], size: 14),
                                  const SizedBox(width: 4),
                                  const Text('4.9 (124 reviews)', style: TextStyle(fontSize: 11)),
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

              // 6. TRAVEL FEED SECTION
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text('Travel Feed & Experiences', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 12),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _feed.length,
                itemBuilder: (context, index) {
                  final post = _feed[index];
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
                                backgroundImage: NetworkImage(post['avatar']!),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(post['author']!, style: const TextStyle(fontWeight: FontWeight.bold)),
                                    Text(post['role']!, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
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
                          Text(post['title']!, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 6),
                          Text(post['description']!, style: theme.textTheme.bodyMedium?.copyWith(height: 1.4)),
                          const SizedBox(height: 12),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(post['image']!, fit: BoxFit.cover, height: 180, width: double.infinity),
                          ),
                          const SizedBox(height: 14),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.favorite_rounded, color: theme.colorScheme.error, size: 20),
                                  const SizedBox(width: 6),
                                  Text(post['likes']!, style: const TextStyle(fontWeight: FontWeight.w600)),
                                  const SizedBox(width: 18),
                                  Icon(Icons.chat_bubble_outline_rounded, color: theme.colorScheme.primary, size: 20),
                                  const SizedBox(width: 6),
                                  Text(post['comments']!, style: const TextStyle(fontWeight: FontWeight.w600)),
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
