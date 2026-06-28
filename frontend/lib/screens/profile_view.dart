import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/auth_provider.dart';
import '../providers/trip_provider.dart';
import '../services/user_service.dart';
import '../config/routes.dart';
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
      
      // Also fetch trips just in case they aren't loaded
      Provider.of<TripProvider>(context, listen: false).fetchTrips(token);

    } catch (e) {
      debugPrint('Error fetching profile: $e');
    } finally {
      setState(() => _isLoading = false);
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
    final auth = Provider.of<AuthProvider>(context);
    final user = auth.user!;
    final tripProvider = Provider.of<TripProvider>(context);

    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          // Profile Header
          Container(
            padding: const EdgeInsets.all(24.0),
            color: theme.colorScheme.surface,
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: theme.colorScheme.primaryContainer,
                  backgroundImage: _profile!['profileImage'] != null && _profile!['profileImage'].toString().isNotEmpty
                      ? CachedNetworkImageProvider(_profile!['profileImage'])
                      : null,
                  child: _profile!['profileImage'] == null || _profile!['profileImage'].toString().isEmpty
                      ? Text(
                          _profile!['name'][0].toUpperCase(),
                          style: TextStyle(fontSize: 32, color: theme.colorScheme.onPrimaryContainer),
                        )
                      : null,
                ),
                const SizedBox(height: 16),
                Text(
                  _profile!['name'],
                  style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  '@${_profile!['username']}',
                  style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                ),
                if (_profile!['bio'] != null && _profile!['bio'].toString().isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    _profile!['bio'],
                    textAlign: TextAlign.center,
                  ),
                ],
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildStatItem('Posts', _profile!['postsCount'] ?? _userPosts.length),
                    const SizedBox(width: 24),
                    _buildStatItem('Followers', _profile!['followersCount'] ?? 0),
                    const SizedBox(width: 24),
                    _buildStatItem('Following', _profile!['followingCount'] ?? 0),
                  ],
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: _showEditProfileDialog,
                  icon: const Icon(Icons.edit_rounded, size: 18),
                  label: const Text('Edit Profile'),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Tab Bar
          TabBar(
            labelColor: theme.colorScheme.primary,
            unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
            indicatorColor: theme.colorScheme.primary,
            tabs: const [
              Tab(icon: Icon(Icons.grid_on_rounded), text: 'Posts'),
              Tab(icon: Icon(Icons.bookmark_border_rounded), text: 'Saved Posts'),
              Tab(icon: Icon(Icons.place_rounded), text: 'Saved Places'),
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
    );
  }

  Widget _buildStatItem(String label, int count) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildDestinationsGrid(List<dynamic> destinations) {
    if (destinations.isEmpty) {
      return const Center(child: Text('No saved places yet.'));
    }
    return GridView.builder(
      padding: const EdgeInsets.all(8.0),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 250,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
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
            ).then((_) => _fetchProfileData()); // Refresh when coming back
          },
          child: Card(
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        ', ',
                        style: const TextStyle(color: Colors.white70, fontSize: 10),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const Positioned(
                  top: 8,
                  right: 8,
                  child: Icon(Icons.bookmark_rounded, color: Colors.amber, size: 20),
                ),
              ],
            ),
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
          color: Colors.grey[200],
          child: post['mediaUrl'] != null && post['mediaUrl'].toString().isNotEmpty
              ? CachedNetworkImage(
                  imageUrl: post['mediaUrl'],
                  fit: BoxFit.cover,
                  errorWidget: (c, u, e) => const Icon(Icons.error),
                )
              : Center(
                  child: Text(
                    post['caption'] ?? 'No caption',
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ),
        );
      },
    );
  }

  Widget _buildTripsList(List<dynamic> trips) {
    if (trips.isEmpty) {
      return const Center(child: Text('No trips yet.'));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: trips.length,
      itemBuilder: (ctx, index) {
        final trip = trips[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: const Icon(Icons.map_rounded, color: Colors.orange),
            title: Text(trip['title'] ?? 'Untitled'),
            subtitle: Text(trip['destination'] ?? ''),
            trailing: Text(trip['status'] ?? 'Upcoming'),
          ),
        );
      },
    );
  }
}
