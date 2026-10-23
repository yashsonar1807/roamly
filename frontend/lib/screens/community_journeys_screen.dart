import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/journey_provider.dart';
import '../widgets/glassmorphism.dart';
import '../utils/animations.dart';

class CommunityJourneysScreen extends StatefulWidget {
  const CommunityJourneysScreen({super.key});

  @override
  State<CommunityJourneysScreen> createState() => _CommunityJourneysScreenState();
}

class _CommunityJourneysScreenState extends State<CommunityJourneysScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedRatingFilter = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchJourneys();
    });
  }

  void _fetchJourneys() {
    Provider.of<JourneyProvider>(context, listen: false).fetchJourneys(
      search: _searchController.text,
      minRating: _selectedRatingFilter,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        // Premium Search Header
        Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              GlassContainer(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                borderRadius: BorderRadius.circular(30),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search destinations...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.arrow_forward),
                      onPressed: _fetchJourneys,
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    fillColor: Colors.transparent,
                    filled: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onSubmitted: (_) => _fetchJourneys(),
                ),
              ),
              const SizedBox(height: 16),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip('All', '', theme),
                    _buildFilterChip('4+ Stars', '4', theme),
                    _buildFilterChip('5 Stars', '5', theme),
                  ],
                ),
              ),
            ],
          ),
        ),
        
        // Journey List
        Expanded(
          child: Consumer<JourneyProvider>(
            builder: (context, provider, child) {
              if (provider.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (provider.error != null) {
                return Center(child: Text(provider.error!, style: const TextStyle(color: Colors.red)));
              }
              if (provider.journeys.isEmpty) {
                return const Center(child: Text('No journeys found.'));
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                itemCount: provider.journeys.length,
                itemBuilder: (context, index) {
                  final journey = provider.journeys[index];
                  final creator = journey['creator'];
                  final creatorName = creator?['name'] ?? 'Unknown';
                  final profileImage = creator?['profileImage'];
                  
                  return BounceScale(
                    onTap: () => _showJourneyDetails(context, journey),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 24.0),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                        border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Hero Image (Placeholder or first photo)
                          Container(
                            height: 180,
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                              image: DecorationImage(
                                image: (journey['photos'] != null && journey['photos'].isNotEmpty)
                                    ? NetworkImage(journey['photos'][0])
                                    : NetworkImage('https://picsum.photos/600/300?random=${index + 50}'),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        journey['title'] ?? 'Untitled',
                                        style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: Colors.amber.withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.star, color: Colors.amber, size: 16),
                                          const SizedBox(width: 4),
                                          Text(
                                            (journey['rating'] ?? 0.0).toString(),
                                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.amber),
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(Icons.location_on_outlined, size: 16, color: Colors.grey),
                                    const SizedBox(width: 4),
                                    Text(
                                      journey['destinationName'] ?? 'Unknown Destination',
                                      style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 16,
                                      backgroundImage: profileImage != null && profileImage.isNotEmpty
                                          ? NetworkImage(profileImage)
                                          : const NetworkImage('https://ui-avatars.com/api/?name=User&background=random&format=png'),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(creatorName, style: const TextStyle(fontWeight: FontWeight.w600)),
                                    const Spacer(),
                                    Text(
                                      '\$${journey['budget'] ?? 0}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: theme.colorScheme.primary,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
        const SizedBox(height: 100), // padding for FAB
      ],
    );
  }

  void _showJourneyDetails(BuildContext context, Map<String, dynamic> journey) {
    final theme = Theme.of(context);
    final creator = journey['creator'];
    final creatorName = creator?['name'] ?? 'Traveler';
    final profileImage = creator?['profileImage'];
    final photos = journey['photos'] as List<dynamic>? ?? [];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: theme.scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.65,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (ctx, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 48,
                      height: 5,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    journey['title'] ?? 'Community Journey',
                    style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundImage: profileImage != null && profileImage.isNotEmpty
                            ? NetworkImage(profileImage)
                            : null,
                        child: profileImage == null || profileImage.isEmpty
                            ? const Icon(Icons.person, size: 18)
                            : null,
                      ),
                      const SizedBox(width: 8),
                      Text(creatorName, style: const TextStyle(fontWeight: FontWeight.w600)),
                      const Spacer(),
                      if (journey['budget'] != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '\$${journey['budget']}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (photos.isNotEmpty)
                    SizedBox(
                      height: 160,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: photos.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 12),
                        itemBuilder: (ctx, i) => ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.network(
                            photos[i],
                            width: 220,
                            height: 160,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              width: 220,
                              height: 160,
                              color: Colors.grey.shade300,
                              child: const Icon(Icons.image_not_supported),
                            ),
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),
                  Text(
                    journey['description'] ?? 'No description provided.',
                    style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFilterChip(String label, String value, ThemeData theme) {
    final isSelected = _selectedRatingFilter == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedRatingFilter = selected ? value : '';
          });
          _fetchJourneys();
        },
        backgroundColor: theme.colorScheme.surface,
        selectedColor: theme.colorScheme.primary.withValues(alpha: 0.2),
        checkmarkColor: theme.colorScheme.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isSelected ? theme.colorScheme.primary : theme.colorScheme.outline.withValues(alpha: 0.5),
          ),
        ),
      ),
    );
  }
}
