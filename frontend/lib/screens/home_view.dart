import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../config/routes.dart';
import '../config/colors.dart';
import '../providers/story_provider.dart';
import '../providers/post_provider.dart';
import '../providers/destination_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/post_card.dart';
import '../widgets/story_viewer_dialog.dart';
import '../widgets/travel_search_dock.dart';

class HomeView extends StatefulWidget {
  final VoidCallback onCreateTripTap;
  final VoidCallback? onExploreTap;

  const HomeView({
    super.key,
    required this.onCreateTripTap,
    this.onExploreTap,
  });

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final ScrollController _scrollController = ScrollController();
  String _selectedCategory = 'All';

  final List<Map<String, String>> _categories = const [
    {'name': 'All', 'icon': '🌍'},
    {'name': 'Beaches', 'icon': '🏖️'},
    {'name': 'Mountains', 'icon': '🏔️'},
    {'name': 'Heritage', 'icon': '🏛️'},
    {'name': 'Forests', 'icon': '🌲'},
    {'name': 'Adventure', 'icon': '⛺'},
    {'name': 'Food & Cafe', 'icon': '🍜'},
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<StoryProvider>(context, listen: false).fetchStories();
      Provider.of<PostProvider>(context, listen: false).fetchPosts();
      Provider.of<DestinationProvider>(context, listen: false).fetchDestinations();
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        final postProvider = Provider.of<PostProvider>(context, listen: false);
        postProvider.fetchMorePosts();
      }
    });
  }

  Future<void> _onRefresh() async {
    if (!mounted) return;
    final storyProvider = Provider.of<StoryProvider>(context, listen: false);
    final postProvider = Provider.of<PostProvider>(context, listen: false);
    final destProvider = Provider.of<DestinationProvider>(context, listen: false);
    await Future.wait([
      storyProvider.fetchStories(),
      postProvider.fetchPosts(),
      destProvider.fetchDestinations(),
    ]);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final storyProvider = Provider.of<StoryProvider>(context);
    final postProvider = Provider.of<PostProvider>(context);
    final destProvider = Provider.of<DestinationProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isWideDesktop = screenWidth >= 1050;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        color: AppColors.primary,
        child: SingleChildScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Center(
            child: Container(
              constraints: BoxConstraints(maxWidth: isWideDesktop ? 1060 : 680),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // MAIN CONTENT FEED COLUMN
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // 1. HERO TRAVEL WELCOME BANNER
                        _buildHeroBanner(context, authProvider),
                        const SizedBox(height: 16),

                        // 2. STORIES REEL (HORIZONTAL SCROLL)
                        _buildStoriesSection(context, storyProvider, authProvider),
                        const SizedBox(height: 18),

                        // 3. FEED POSTS LIST

                        // 4. FEED POSTS LIST
                        if (postProvider.isLoading && postProvider.posts.isEmpty)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 80),
                            child: Center(child: CircularProgressIndicator()),
                          )
                        else if (postProvider.posts.isEmpty)
                          _buildEmptyFeedState(context)
                        else
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: postProvider.posts.length + 1,
                            itemBuilder: (context, index) {
                              if (index == postProvider.posts.length) {
                                return postProvider.isFetchingMore
                                    ? const Padding(
                                        padding: EdgeInsets.all(16.0),
                                        child: Center(child: CircularProgressIndicator()),
                                      )
                                    : const SizedBox(height: 60);
                              }
                              return PostCard(post: postProvider.posts[index]);
                            },
                          ),
                      ],
                    ),
                  ),

                  // RIGHT SIDEBAR (VISIBLE ON WIDE WEB >= 1050px)
                  if (isWideDesktop) ...[
                    const SizedBox(width: 24),
                    SizedBox(
                      width: 320,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildTrendingDestinationsCard(context, destProvider),
                          const SizedBox(height: 20),
                          _buildTravelTipsCard(context),
                          const SizedBox(height: 20),
                          _buildCommunityStatsCard(context),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, AppRoutes.uploadPost);
        },
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 6,
        icon: const Icon(Icons.add_a_photo_rounded),
        label: const Text('Share Moment', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  // ─── 1. HERO TRAVEL BANNER ──────────────────────────────────────────────
  Widget _buildHeroBanner(BuildContext context, AuthProvider authProvider) {
    final userName = authProvider.user?['name'] ?? 'Traveler';
    final firstName = userName.toString().split(' ')[0];

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF0F172A),
            AppColors.primaryDark,
            AppColors.primary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.25),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.explore_rounded, color: Colors.white, size: 14),
                    SizedBox(width: 6),
                    Text(
                      'Roamly Travel Web',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              const Icon(Icons.flight_takeoff_rounded, color: Colors.white70, size: 20),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Where to next, $firstName? ✈️',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Discover curated hidden gems, map out your next dream itinerary, and share adventures with wanderers worldwide.',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  if (widget.onExploreTap != null) {
                    widget.onExploreTap!();
                  } else {
                    Navigator.pushNamed(context, AppRoutes.home);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF0F172A),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                icon: const Icon(Icons.travel_explore_rounded, size: 18, color: AppColors.primaryDark),
                label: const Text('Explore Places', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              OutlinedButton.icon(
                onPressed: widget.onCreateTripTap,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white70, width: 1.5),
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                icon: const Icon(Icons.calendar_month_rounded, size: 18),
                label: const Text('Plan Itinerary', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── 2. STORIES ROW ─────────────────────────────────────────────────────
  Widget _buildStoriesSection(
    BuildContext context,
    StoryProvider storyProvider,
    AuthProvider authProvider,
  ) {
    final theme = Theme.of(context);
    final userAvatar = authProvider.user?['profileImage'] ??
        'https://ui-avatars.com/api/?name=${authProvider.user?['name'] ?? 'You'}&background=0EA5E9&color=fff';

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.brightness == Brightness.dark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.05),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
            child: Row(
              children: [
                const Icon(Icons.flash_on_rounded, size: 16, color: AppColors.accentOrange),
                const SizedBox(width: 6),
                Text(
                  'Community Travel Stories',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  'Tap to view live',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 98,
            child: storyProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: storyProvider.stories.length + 1,
                    itemBuilder: (context, index) {
                      // 1st Item: "Your Story" / Add Story
                      if (index == 0) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(context, AppRoutes.uploadPost);
                            },
                            child: Column(
                              children: [
                                Stack(
                                  children: [
                                    Container(
                                      width: 62,
                                      height: 62,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: AppColors.primary.withValues(alpha: 0.6),
                                          width: 2,
                                        ),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(2.0),
                                        child: CircleAvatar(
                                          backgroundImage: CachedNetworkImageProvider(userAvatar),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 0,
                                      right: 0,
                                      child: Container(
                                        padding: const EdgeInsets.all(3),
                                        decoration: const BoxDecoration(
                                          color: AppColors.primary,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.add,
                                          size: 14,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                const Text(
                                  'Your Story',
                                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      // Community Traveler Stories
                      final storyIndex = index - 1;
                      final story = storyProvider.stories[storyIndex];
                      final name = (story['userName'] ?? 'Traveler').toString().split(' ')[0];

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: GestureDetector(
                          onTap: () {
                            StoryViewerDialog.show(context, storyProvider.stories, storyIndex);
                          },
                          child: Column(
                            children: [
                              Container(
                                width: 62,
                                height: 62,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: AppColors.storyGradient,
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.accentOrange.withValues(alpha: 0.3),
                                      blurRadius: 8,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(2.5),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: theme.scaffoldBackgroundColor,
                                        width: 2,
                                      ),
                                      image: DecorationImage(
                                        image: CachedNetworkImageProvider(
                                          story['userAvatar'] ??
                                              'https://ui-avatars.com/api/?name=$name&background=random&format=png',
                                        ),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              SizedBox(
                                width: 64,
                                child: Text(
                                  name,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // ─── 3. CATEGORIES FILTER BAR ───────────────────────────────────────────
  Widget _buildCategoryFilterBar(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      height: 42,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final cat = _categories[index];
          final isSelected = _selectedCategory == cat['name'];

          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ChoiceChip(
              label: Text('${cat['icon']}  ${cat['name']}'),
              selected: isSelected,
              selectedColor: AppColors.primary.withValues(alpha: 0.15),
              labelStyle: TextStyle(
                color: isSelected ? AppColors.primaryDark : theme.textTheme.bodyMedium?.color,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                fontSize: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: isSelected
                      ? AppColors.primary
                      : (theme.brightness == Brightness.dark
                          ? Colors.white.withValues(alpha: 0.12)
                          : Colors.black.withValues(alpha: 0.08)),
                ),
              ),
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _selectedCategory = cat['name']!;
                  });
                  if (cat['name'] != 'All' && widget.onExploreTap != null) {
                    widget.onExploreTap!();
                  }
                }
              },
            ),
          );
        },
      ),
    );
  }

  // ─── 4. EMPTY STATE ─────────────────────────────────────────────────────
  Widget _buildEmptyFeedState(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.luggage_outlined,
              size: 56,
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No travel moments posted yet.',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            const Text(
              'Be the first explorer to share a moment from your adventures!',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.uploadPost);
              },
              icon: const Icon(Icons.add_a_photo_rounded, size: 18),
              label: const Text('Share First Post'),
            ),
          ],
        ),
      ),
    );
  }

  // ─── 5. RIGHT SIDEBAR WIDGETS ───────────────────────────────────────────
  Widget _buildTrendingDestinationsCard(
    BuildContext context,
    DestinationProvider destProvider,
  ) {
    final theme = Theme.of(context);
    final destinations = destProvider.destinations.take(3).toList();

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.brightness == Brightness.dark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.05),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.local_fire_department_rounded, color: Colors.redAccent, size: 20),
              const SizedBox(width: 8),
              Text(
                'Trending Escapes',
                style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              TextButton(
                onPressed: widget.onExploreTap,
                child: const Text('View All', style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (destProvider.isLoading && destinations.isEmpty)
            const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()))
          else
            ...destinations.map((dest) {
              final imageUrl = (dest['images'] != null && (dest['images'] as List).isNotEmpty)
                  ? dest['images'][0].toString()
                  : 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?q=80&w=600';

              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: InkWell(
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.destinationDetail,
                      arguments: dest,
                    );
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: CachedNetworkImage(
                          imageUrl: imageUrl,
                          width: 56,
                          height: 56,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(color: Colors.grey.shade300),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              dest['name'] ?? 'Destination',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${dest['city'] ?? ''}, ${dest['country'] ?? ''}',
                              style: TextStyle(
                                fontSize: 11,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.amber.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.star_rounded, color: Colors.amber, size: 13),
                            const SizedBox(width: 2),
                            Text(
                              (dest['rating'] ?? '4.8').toString(),
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.amber,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildTravelTipsCard(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.brightness == Brightness.dark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.05),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.lightbulb_rounded, color: Colors.amber, size: 20),
              const SizedBox(width: 8),
              Text(
                'Wanderer Pro-Tip',
                style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            '“Download offline offline maps and save bookmark locations ahead of travel. When hiking scenic trails, always pack a backup power bank and keep local emergency contacts handy.”',
            style: TextStyle(fontSize: 12.5, height: 1.45, fontStyle: FontStyle.italic),
          ),
          const SizedBox(height: 12),
          const Row(
            children: [
              Icon(Icons.shield_outlined, size: 14, color: AppColors.primary),
              SizedBox(width: 6),
              Text(
                'Verified Nomad Advisory',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCommunityStatsCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.1),
            AppColors.accentOrange.withValues(alpha: 0.08),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '🌟 Global Travel Network',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 6),
          const Text(
            'Connect with 12,000+ travelers across 85 countries sharing daily stories.',
            style: TextStyle(fontSize: 12, color: Colors.grey, height: 1.35),
          ),
          const SizedBox(height: 14),
          InkWell(
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.communityJourneys);
            },
            borderRadius: BorderRadius.circular(10),
            child: const Row(
              children: [
                Text(
                  'Explore Community Journeys',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryDark,
                  ),
                ),
                SizedBox(width: 4),
                Icon(Icons.arrow_forward_rounded, size: 14, color: AppColors.primaryDark),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
