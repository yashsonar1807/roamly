import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/auth_provider.dart';
import '../providers/trip_provider.dart';
import '../services/user_service.dart';
import '../config/routes.dart';
import '../config/colors.dart';
import '../utils/animations.dart';
import 'edit_profile_screen.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final UserService _userService = UserService();
  Map<String, dynamic>? _profile;
  List<dynamic> _userPosts = [];
  List<dynamic> _savedPosts = [];
  List<dynamic> _savedDestinations = [];
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
      final token = auth.accessToken!;

      final profileRes = await _userService.getProfile(token, userId: 'me');
      if (profileRes['success'] == true) {
        _profile = profileRes['data'];
      }
      
      _userPosts = await _userService.getUserPosts(token, 'me');
      _savedPosts = await _userService.getSavedPosts(token);
      _savedDestinations = await _userService.getSavedDestinations(token);
      
      if (mounted) {
        Provider.of<TripProvider>(context, listen: false).fetchTrips(token);
      }
    } catch (e) {
      debugPrint('Error fetching profile: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showEditProfileDialog() async {
    if (_profile == null) return;
    
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditProfileScreen(initialProfile: _profile!)),
    );
    
    if (result == true) {
      _fetchProfileData();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_profile == null) {
      return const Center(child: Text('Failed to load profile'));
    }

    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 860),
        child: DefaultTabController(
          length: 3,
          child: Column(
            children: [
          // Modern Profile Header
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 16.0 : 24.0,
              vertical: isMobile ? 14.0 : 20.0,
            ),
            color: theme.scaffoldBackgroundColor,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(3),
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
                          radius: isMobile ? 36 : 42,
                          backgroundColor: theme.colorScheme.primaryContainer,
                          backgroundImage: _profile!['profileImage'] != null && _profile!['profileImage'].toString().isNotEmpty
                              ? CachedNetworkImageProvider(_profile!['profileImage'])
                              : null,
                          child: _profile!['profileImage'] == null || _profile!['profileImage'].toString().isEmpty
                              ? Text(
                                  _profile!['name'][0].toUpperCase(),
                                  style: TextStyle(
                                    fontSize: isMobile ? 26 : 32,
                                    color: theme.colorScheme.onPrimaryContainer,
                                  ),
                                )
                              : null,
                        ),
                      ),
                    ),
                    SizedBox(width: isMobile ? 12 : 24),
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(child: _buildStatItem('Posts', _profile!['postsCount'] ?? _userPosts.length, theme)),
                          SizedBox(width: isMobile ? 6 : 10),
                          Expanded(child: _buildStatItem('Followers', _profile!['followersCount'] ?? 0, theme)),
                          SizedBox(width: isMobile ? 6 : 10),
                          Expanded(child: _buildStatItem('Following', _profile!['followingCount'] ?? 0, theme)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      Text(
                        _profile!['name'],
                        style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      BounceScale(
                        onTap: () {
                          Navigator.pushNamed(context, AppRoutes.rankProgress);
                        },
                        child: Container(
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
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                
                // Edit Profile Button
                SizedBox(
                  width: double.infinity,
                  child: BounceScale(
                    onTap: _showEditProfileDialog,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: isDarkMode ? Colors.white.withValues(alpha: 0.1) : AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDarkMode ? Colors.white.withValues(alpha: 0.05) : AppColors.primary.withValues(alpha: 0.2),
                          width: 1,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'Edit Profile',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isDarkMode ? Colors.white : AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Tab Bar
          TabBar(
            labelColor: theme.colorScheme.onSurface,
            unselectedLabelColor: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            indicatorColor: AppColors.primary,
            indicatorWeight: 2,
            indicatorSize: TabBarIndicatorSize.tab,
            dividerColor: Colors.transparent,
            tabs: const [
              Tab(icon: Icon(Icons.grid_on_rounded)),
              Tab(icon: Icon(Icons.bookmark_border_rounded)),
              Tab(icon: Icon(Icons.place_rounded)),
            ],
          ),
          
          // Tab Views
          Expanded(
            child: TabBarView(
              children: [
                _buildPostsGrid(_userPosts),
                _buildPostsGrid(_savedPosts),
                _buildDestinationsGrid(_savedDestinations),
              ],
            ),
          ),
        ],
      ),
    ),
  ),
);
}

  Widget _buildStatItem(String label, int count, ThemeData theme) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 4 : 16,
        vertical: isMobile ? 10 : 16,
      ),
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.dark 
            ? const Color(0xFF1E293B).withValues(alpha: 0.6)
            : Colors.white,
        borderRadius: BorderRadius.circular(isMobile ? 14 : 24),
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
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              count.toString(),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold, 
                fontSize: isMobile ? 16 : 20,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontSize: isMobile ? 11 : 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDestinationsGrid(List<dynamic> destinations) {
    if (destinations.isEmpty) {
      return const Center(child: Text('No saved places yet.'));
    }
    return GridView.builder(
      padding: const EdgeInsets.only(left: 2.0, right: 2.0, top: 2.0, bottom: 96.0),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 250,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
        childAspectRatio: 0.85,
      ),
      itemCount: destinations.length,
      itemBuilder: (ctx, index) {
        final dest = destinations[index];
        final imageUrl = (dest['images'] != null && (dest['images'] as List).isNotEmpty)
            ? dest['images'][0].toString()
            : 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?q=80&w=600';
            
        return GestureDetector(
          onTap: () {
            Navigator.pushNamed(
              context,
              AppRoutes.destinationDetail,
              arguments: dest,
            ).then((_) => _fetchProfileData());
          },
          child: Stack(
            fit: StackFit.expand,
            children: [
              CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
              ),
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.transparent, Colors.black87],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
              Positioned(
                bottom: 8,
                left: 8,
                right: 8,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dest['name'] ?? '',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const Positioned(
                top: 8,
                right: 8,
                child: Icon(Icons.bookmark_rounded, color: Colors.white, size: 20),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPostsGrid(List<dynamic> posts) {
    if (posts.isEmpty) {
      return const Center(child: Text('No posts yet.'));
    }
    return GridView.builder(
      padding: const EdgeInsets.only(left: 2.0, right: 2.0, top: 2.0, bottom: 96.0),
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
