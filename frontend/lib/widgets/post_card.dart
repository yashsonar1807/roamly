import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:share_plus/share_plus.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../providers/post_provider.dart';
import '../providers/auth_provider.dart';
import '../services/user_service.dart';
import '../config/colors.dart';
import '../config/routes.dart';
import '../utils/animations.dart';

class PostCard extends StatelessWidget {
  final Map<String, dynamic> post;

  const PostCard({super.key, required this.post});

  void _showCommentsBottomSheet(BuildContext context, String postId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => _CommentsSheet(postId: postId),
    );
  }

  void _handleShare(BuildContext context) {
    final String caption = post['caption'] ?? 'Check out this post on Roamly!';
    final String url = post['mediaUrl'] ?? '';
    // ignore: deprecated_member_use
    Share.share('$caption\n$url');
  }

  void _handleDelete(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Post?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      if (!context.mounted) return;
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final postProvider = Provider.of<PostProvider>(context, listen: false);
      if (authProvider.accessToken != null) {
        final success = await postProvider.deletePost(authProvider.accessToken!, post['_id']);
        if (success && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Post deleted successfully')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final postProvider = Provider.of<PostProvider>(context, listen: false);
    final theme = Theme.of(context);
    
    final bool isLiked = post['isLiked'] ?? false;
    final int likesCount = post['likesCount'] ?? 0;
    final int commentsCount = post['commentsCount'] ?? 0;
    final currentUserId = authProvider.user?['id'] ?? authProvider.user?['_id'];
    final postUserId = post['user'] is Map ? post['user']['_id'] : post['user'];
    final bool isOwner = currentUserId != null && currentUserId.toString() == postUserId?.toString();

    final createdAt = post['createdAt'] != null 
        ? DateTime.parse(post['createdAt']) 
        : DateTime.now();

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: theme.brightness == Brightness.dark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.06),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: theme.brightness == Brightness.dark ? 0.35 : 0.04,
            ),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      final userId = post['user'];
                      if (userId != null && userId.toString().isNotEmpty) {
                        Navigator.pushNamed(
                          context,
                          AppRoutes.publicProfile,
                          arguments: userId,
                        );
                      }
                    },
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundImage: post['authorAvatar'] != null && post['authorAvatar'].toString().isNotEmpty
                              ? CachedNetworkImageProvider(post['authorAvatar'])
                              : null,
                          child: post['authorAvatar'] == null || post['authorAvatar'].toString().isEmpty
                              ? const Icon(Icons.person, size: 18)
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      post['authorName'] ?? 'Anonymous',
                                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: 15),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      gradient: AppColors.rankGradient,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Text(
                                      'Traveler',
                                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                              if (post['location'] != null && post['location'].toString().isNotEmpty)
                                Text(
                                  post['location'],
                                  style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (isOwner)
                  PopupMenuButton<String>(
                    icon: Icon(Icons.more_horiz, color: theme.iconTheme.color),
                    onSelected: (value) {
                      if (value == 'delete') {
                        _handleDelete(context);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'delete',
                        child: Text('Delete', style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  )
                else
                  Icon(Icons.more_horiz, color: theme.iconTheme.color),
              ],
            ),
          ),
          
          // Media with Glassmorphic Actions (Bento Box Style)
          if (post['mediaUrl'] != null && post['mediaUrl'].toString().isNotEmpty)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  Container(
                    constraints: const BoxConstraints(maxHeight: 500, minHeight: 300),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: theme.brightness == Brightness.dark 
                            ? Colors.white.withValues(alpha: 0.05)
                            : Colors.black.withValues(alpha: 0.05),
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: GestureDetector(
                        onDoubleTap: () {
                          if (authProvider.accessToken != null) {
                            postProvider.toggleLike(authProvider.accessToken!, post['_id']);
                          }
                        },
                        child: post['mediaType'] == 'video'
                            ? const Center(child: Icon(Icons.play_circle_outline, size: 64, color: Colors.white))
                            : CachedNetworkImage(
                                imageUrl: post['mediaUrl'],
                                fit: BoxFit.cover,
                                placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                                errorWidget: (context, url, error) => const Center(child: Icon(Icons.broken_image, size: 64, color: Colors.grey)),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Action Bar (Like, Comment, Share, Save)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                BounceScale(
                  onTap: () {
                    if (authProvider.accessToken != null) {
                      postProvider.toggleLike(authProvider.accessToken!, post['_id']);
                    }
                  },
                  child: Icon(
                    isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                    color: isLiked ? AppColors.error : theme.iconTheme.color,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 20),
                BounceScale(
                  onTap: () => _showCommentsBottomSheet(context, post['_id']),
                  child: Icon(Icons.chat_bubble_outline_rounded, size: 26, color: theme.iconTheme.color),
                ),
                const SizedBox(width: 20),
                BounceScale(
                  onTap: () => _handleShare(context),
                  child: Icon(Icons.send_rounded, size: 26, color: theme.iconTheme.color),
                ),
                const Spacer(),
                BounceScale(
                  onTap: () async {
                    if (authProvider.accessToken == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please log in to save posts.')),
                      );
                      return;
                    }
                    try {
                      final res = await UserService().toggleSavePost(authProvider.accessToken!, post['_id']);
                      final isSaved = res['isSaved'] ?? true;
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(isSaved ? 'Post saved to bookmarks!' : 'Post removed from bookmarks.'),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error saving post: $e')),
                        );
                      }
                    }
                  },
                  child: Icon(Icons.bookmark_border_rounded, size: 28, color: theme.iconTheme.color),
                ),
              ],
            ),
          ),

          // Likes Count
          if (likesCount > 0)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Text(
                '$likesCount likes',
                style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ),

          // Caption
          if (post['caption'] != null && post['caption'].toString().isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
              child: RichText(
                text: TextSpan(
                  style: theme.textTheme.bodyMedium?.copyWith(fontSize: 14),
                  children: [
                    TextSpan(
                      text: '${post['authorName'] ?? 'Anonymous'} ',
                      style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    TextSpan(text: post['caption']),
                  ],
                ),
              ),
            ),

          // View all comments
          if (commentsCount > 0)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: GestureDetector(
                onTap: () => _showCommentsBottomSheet(context, post['_id']),
                child: Text(
                  'View all $commentsCount comments',
                  style: theme.textTheme.bodyMedium?.copyWith(fontSize: 14),
                ),
              ),
            ),

          // Timestamp
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              timeago.format(createdAt).toUpperCase(),
              style: theme.textTheme.bodyMedium?.copyWith(fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 0.5),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _CommentsSheet extends StatefulWidget {
  final String postId;

  const _CommentsSheet({required this.postId});

  @override
  State<_CommentsSheet> createState() => _CommentsSheetState();
}

class _CommentsSheetState extends State<_CommentsSheet> {
  final TextEditingController _commentController = TextEditingController();
  List<dynamic> _comments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _loadComments() async {
    final provider = Provider.of<PostProvider>(context, listen: false);
    final comments = await provider.fetchComments(widget.postId);
    if (mounted) {
      setState(() {
        _comments = comments;
        _isLoading = false;
      });
    }
  }

  Future<void> _postComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final postProvider = Provider.of<PostProvider>(context, listen: false);

    if (authProvider.accessToken == null) return;

    _commentController.clear();
    final newComment = await postProvider.createComment(authProvider.accessToken!, widget.postId, text);
    
    if (newComment != null && mounted) {
      setState(() {
        _comments.add(newComment);
      });
    }
  }

  Future<void> _deleteComment(String commentId, int index) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final postProvider = Provider.of<PostProvider>(context, listen: false);

    if (authProvider.accessToken == null) return;

    final success = await postProvider.deleteComment(authProvider.accessToken!, widget.postId, commentId);
    if (success && mounted) {
      setState(() {
        _comments.removeAt(index);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final currentUserId = authProvider.user?['id'] ?? authProvider.user?['_id'];
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: theme.dividerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Text(
              'Comments',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const Divider(height: 32),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _comments.isEmpty
                      ? const Center(child: Text('No comments yet. Be the first!'))
                      : ListView.builder(
                          itemCount: _comments.length,
                          itemBuilder: (context, index) {
                            final comment = _comments[index];
                            final commentUserId = comment['user'] is Map ? comment['user']['_id'] : comment['user'];
                            final isOwner = currentUserId != null && commentUserId != null && 
                                commentUserId.toString() == currentUserId.toString();
                            
                            final authorName = comment['user']?['name'] ?? 'Anonymous';
                            final authorAvatar = comment['user']?['avatar'];
                            final createdAt = comment['createdAt'] != null 
                                ? DateTime.parse(comment['createdAt']) 
                                : DateTime.now();

                            return ListTile(
                              leading: CircleAvatar(
                                backgroundImage: authorAvatar != null && authorAvatar.toString().isNotEmpty
                                    ? CachedNetworkImageProvider(authorAvatar)
                                    : null,
                                child: authorAvatar == null || authorAvatar.toString().isEmpty
                                    ? const Icon(Icons.person)
                                    : null,
                              ),
                              title: Row(
                                children: [
                                  Text(
                                    authorName,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    timeago.format(createdAt),
                                    style: const TextStyle(color: Colors.grey, fontSize: 11),
                                  ),
                                ],
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Text(comment['text'] ?? '', style: const TextStyle(fontSize: 14)),
                              ),
                              trailing: isOwner
                                  ? IconButton(
                                      icon: const Icon(Icons.delete_outline, size: 18),
                                      onPressed: () => _deleteComment(comment['_id'], index),
                                    )
                                  : null,
                            );
                          },
                        ),
            ),
            const Divider(height: 1),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundImage: authProvider.user?['profileImage'] != null
                          ? CachedNetworkImageProvider(authProvider.user!['profileImage'])
                          : null,
                      child: authProvider.user?['profileImage'] == null
                          ? const Icon(Icons.person, size: 18)
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _commentController,
                        decoration: InputDecoration(
                          hintText: 'Add a comment...',
                          hintStyle: TextStyle(color: theme.textTheme.bodyMedium?.color),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: theme.cardTheme.color,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    BounceScale(
                      onTap: _postComment,
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.error,
                        ),
                        child: const Icon(Icons.arrow_upward_rounded, color: Colors.white, size: 20),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
