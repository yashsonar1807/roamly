import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/auth_provider.dart';
import '../services/user_service.dart';
import '../config/colors.dart';
import '../providers/user_provider.dart';

class PublicProfileScreen extends StatefulWidget {
  final String userId;
  const PublicProfileScreen({super.key, required this.userId});

  @override
  State<PublicProfileScreen> createState() => _PublicProfileScreenState();
}

class _PublicProfileScreenState extends State<PublicProfileScreen> {
  final UserService _userService = UserService();
  Map<String, dynamic>? _profile;
  List<dynamic> _userPosts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProfileData();
  }

  Future<void> _fetchProfileData() async {
    setState(() => _isLoading = true);
    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final token = auth.accessToken;
      if (token == null || widget.userId.isEmpty) return;

      final profileRes = await _userService.getProfile(token, userId: widget.userId);
      if (profileRes['success'] == true || profileRes['status'] == 'success') {
        _profile = profileRes['data'];
      }
      
      _userPosts = await _userService.getUserPosts(token, widget.userId);

    } catch (e) {
      debugPrint('Error fetching profile: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profile')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    if (_profile == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profile')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Failed to load profile'),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _fetchProfileData,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final theme = Theme.of(context);

    return DefaultTabController(
      length: 1,
      child: Scaffold(
        appBar: AppBar(
          title: Text(_profile!['username'] ?? 'Profile'),
        ),
        body: Column(
          children: [
          // Modern Profile Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
            color: theme.scaffoldBackgroundColor,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: AppColors.storyGradient,
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: theme.scaffoldBackgroundColor,
                        ),
                        child: CircleAvatar(
                          radius: 42,
                          backgroundColor: theme.colorScheme.primaryContainer,
                          backgroundImage: _profile!['profileImage'] != null && _profile!['profileImage'].toString().isNotEmpty
                              ? CachedNetworkImageProvider(_profile!['profileImage'])
                              : null,
                          child: _profile!['profileImage'] == null || _profile!['profileImage'].toString().isEmpty
                              ? Text(
                                  (_profile!['name'] ?? 'U')[0].toUpperCase(),
                                  style: TextStyle(fontSize: 32, color: theme.colorScheme.onPrimaryContainer),
                                )
                              : null,
                        ),
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildStatItem('Posts', _profile!['postsCount'] ?? _userPosts.length, theme),
                          _buildStatItem('Followers', _profile!['followersCount'] ?? 0, theme),
                          _buildStatItem('Following', _profile!['followingCount'] ?? 0, theme),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Row(
                    children: [
                      Text(
                        _profile!['name'] ?? '',
                        style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          gradient: AppColors.rankGradient,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.star_rounded, color: Colors.white, size: 14),
                            SizedBox(width: 4),
                            Text(
                              'World Traveler',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                
                // Follow Button
                SizedBox(
                  width: double.infinity,
                  child: Consumer<UserProvider>(
                    builder: (context, userProvider, child) {
                      return OutlinedButton(
                        onPressed: () async {
                          final auth = Provider.of<AuthProvider>(context, listen: false);
                          if (auth.accessToken != null) {
                            await userProvider.toggleFollow(auth.accessToken!, widget.userId);
                            // Refresh profile data to get updated followers count
                            _fetchProfileData();
                          }
                        },
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 36),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Follow / Unfollow'),
                      );
                    }
                  ),
                ),
              ],
            ),
          ),
          
          // Tab Bar (Just one for posts)
          TabBar(
            labelColor: theme.colorScheme.onSurface,
            unselectedLabelColor: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            indicatorColor: AppColors.primary,
            indicatorWeight: 2,
            indicatorSize: TabBarIndicatorSize.tab,
            dividerColor: Colors.transparent,
            tabs: const [
              Tab(icon: Icon(Icons.grid_on_rounded)),
            ],
          ),
          
          // Tab Views
          Expanded(
            child: TabBarView(
              children: [
                _buildPostsGrid(_userPosts),
              ],
            ),
          ),
        ],
      ),
    ));
  }

  Widget _buildStatItem(String label, int count, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.dark 
            ? const Color(0xFF1E293B).withValues(alpha: 0.6)
            : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: theme.brightness == Brightness.dark 
              ? Colors.white.withValues(alpha: 0.05)
              : Colors.black.withValues(alpha: 0.05),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        children: [
          Text(
            count.toString(),
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold, 
              fontSize: 20,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostsGrid(List<dynamic> posts) {
    if (posts.isEmpty) {
      return const Center(child: Text('No posts yet.'));
    }
    return GridView.builder(
      padding: const EdgeInsets.all(2.0),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 200,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
        childAspectRatio: 1,
      ),
      itemCount: posts.length,
      itemBuilder: (ctx, index) {
        final post = posts[index];
        return Container(
          color: Theme.of(context).cardTheme.color,
          child: post['mediaUrl'] != null && post['mediaUrl'].toString().isNotEmpty
              ? CachedNetworkImage(
                  imageUrl: post['mediaUrl'],
                  fit: BoxFit.cover,
                  errorWidget: (c, u, e) => const Icon(Icons.error),
                )
              : Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      post['caption'] ?? 'No caption',
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ),
        );
      },
    );
  }
}
