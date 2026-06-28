import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/routes.dart';
import '../providers/story_provider.dart';
import '../providers/post_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../widgets/post_card.dart';

class HomeView extends StatefulWidget {
  final VoidCallback onCreateTripTap;
  final VoidCallback? onExploreTap;

  const HomeView({super.key, required this.onCreateTripTap, this.onExploreTap});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Fetch stories, posts, and destinations from MongoDB database on load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<StoryProvider>(context, listen: false).fetchStories();
      Provider.of<PostProvider>(context, listen: false).fetchPosts();
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        final postProvider = Provider.of<PostProvider>(context, listen: false);
        postProvider.fetchMorePosts();
      }
    });
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
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          controller: _scrollController,
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
                                padding: const EdgeInsets.only(right: 16.0),
                                child: GestureDetector(
                                  onTap: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Viewing ${story['userName']}\'s story')),
                                    );
                                  },
                                  child: Column(
                                    children: [
                                      Container(
                                        width: 72,
                                        height: 72,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          gradient: const LinearGradient(
                                            colors: [Colors.purple, Colors.orange],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          ),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(2.5),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              border: Border.all(color: theme.scaffoldBackgroundColor, width: 2),
                                              image: DecorationImage(
                                                image: NetworkImage(story['userAvatar'] ?? 'https://i.pravatar.cc/150?img=${index + 10}'),
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        (story['userName'] ?? 'User').toString().split(' ')[0],
                                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
              ),
              const SizedBox(height: 16),

              // 6. TRAVEL FEED SECTION (DATABASE DRIVEN)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Travel Feed & Experiences', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    IconButton(
                      icon: const Icon(Icons.add_a_photo_outlined),
                      onPressed: () {
                        Navigator.pushNamed(context, AppRoutes.uploadPost);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              postProvider.isLoading && postProvider.posts.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : postProvider.posts.isEmpty
                      ? const Center(child: Text('No travel posts loaded.'))
                      : Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 600),
                            child: Column(
                              children: [
                                ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  padding: const EdgeInsets.symmetric(horizontal: 20),
                                  itemCount: postProvider.posts.length,
                                  itemBuilder: (context, index) {
                                    final post = postProvider.posts[index];
                                    return PostCard(post: post);
                                  },
                                ),
                                if (postProvider.isFetchingMore)
                                  const Padding(
                                    padding: EdgeInsets.all(16.0),
                                    child: Center(child: CircularProgressIndicator()),
                                  ),
                              ],
                            ),
                          ),
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
