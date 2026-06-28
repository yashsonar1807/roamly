import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:share_plus/share_plus.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../providers/post_provider.dart';
import '../providers/auth_provider.dart';

class PostCard extends StatelessWidget {
  final Map<String, dynamic> post;

  const PostCard({super.key, required this.post});

  void _showCommentsBottomSheet(BuildContext context, String postId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _CommentsSheet(postId: postId),
    );
  }

  void _handleShare(BuildContext context) {
    final String caption = post['caption'] ?? 'Check out this post on Roamly!';
    final String url = post['mediaUrl'] ?? '';
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
    
    final bool isLiked = post['isLiked'] ?? false;
    final int likesCount = post['likesCount'] ?? 0;
    final int commentsCount = post['commentsCount'] ?? 0;
    
    final bool isOwner = authProvider.user != null && 
        authProvider.user!['_id'] == post['user'];

    final createdAt = post['createdAt'] != null 
        ? DateTime.parse(post['createdAt']) 
        : DateTime.now();

    return Container(
      color: Theme.of(context).cardColor,
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          ListTile(
            leading: CircleAvatar(
              backgroundImage: post['authorAvatar'] != null && post['authorAvatar'].toString().isNotEmpty
                  ? CachedNetworkImageProvider(post['authorAvatar'])
                  : null,
              child: post['authorAvatar'] == null || post['authorAvatar'].toString().isEmpty
                  ? const Icon(Icons.person)
                  : null,
            ),
            title: Text(
              post['authorName'] ?? 'Anonymous',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              post['location'] ?? '',
              style: const TextStyle(fontSize: 12),
            ),
            trailing: isOwner 
                ? PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'delete') {
                        _handleDelete(context);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'delete',
                        child: Text('Delete Post', style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  )
                : null,
          ),
          
          // Media
          if (post['mediaUrl'] != null && post['mediaUrl'].toString().isNotEmpty)
            Container(
              constraints: const BoxConstraints(maxHeight: 500, minHeight: 200),
              width: double.infinity,
              color: Colors.grey[200],
              child: post['mediaType'] == 'video'
                  ? const Center(child: Icon(Icons.play_circle_outline, size: 64, color: Colors.grey))
                  : CachedNetworkImage(
                      imageUrl: post['mediaUrl'],
                      fit: BoxFit.cover,
                      placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                      errorWidget: (context, url, error) => const Center(child: Icon(Icons.broken_image, size: 64, color: Colors.grey)),
                    ),
            ),

          // Actions
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(
                    isLiked ? Icons.favorite : Icons.favorite_border,
                    color: isLiked ? Colors.red : null,
                  ),
                  onPressed: () {
                    if (authProvider.accessToken != null) {
                      postProvider.toggleLike(authProvider.accessToken!, post['_id']);
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.chat_bubble_outline),
                  onPressed: () => _showCommentsBottomSheet(context, post['_id']),
                ),
                IconButton(
                  icon: const Icon(Icons.send_outlined),
                  onPressed: () => _handleShare(context),
                ),
              ],
            ),
          ),

          // Likes Count
          if (likesCount > 0)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                '$likesCount ${likesCount == 1 ? 'like' : 'likes'}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),

          // Caption
          if (post['caption'] != null && post['caption'].toString().isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: RichText(
                text: TextSpan(
                  style: DefaultTextStyle.of(context).style,
                  children: [
                    TextSpan(
                      text: '${post['authorName'] ?? 'Anonymous'} ',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(text: post['caption']),
                  ],
                ),
              ),
            ),

          // View all comments
          if (commentsCount > 0)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: GestureDetector(
                onTap: () => _showCommentsBottomSheet(context, post['_id']),
                child: Text(
                  'View all $commentsCount comments',
                  style: const TextStyle(color: Colors.grey),
                ),
              ),
            ),

          // Timestamp
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Text(
              timeago.format(createdAt),
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ),
          const SizedBox(height: 8),
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
    // Optimistic UI could be added here
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
    final currentUserId = authProvider.user?['_id'];

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          children: [
            const Text(
              'Comments',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _comments.isEmpty
                      ? const Center(child: Text('No comments yet. Be the first!'))
                      : ListView.builder(
                          itemCount: _comments.length,
                          itemBuilder: (context, index) {
                            final comment = _comments[index];
                            final isOwner = currentUserId != null && comment['user'] != null && 
                                (comment['user']['_id'] == currentUserId || comment['user'] == currentUserId);
                            
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
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    timeago.format(createdAt),
                                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                                  ),
                                ],
                              ),
                              subtitle: Text(comment['text'] ?? ''),
                              trailing: isOwner
                                  ? IconButton(
                                      icon: const Icon(Icons.delete_outline, size: 20),
                                      onPressed: () => _deleteComment(comment['_id'], index),
                                    )
                                  : null,
                            );
                          },
                        ),
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      decoration: const InputDecoration(
                        hintText: 'Add a comment...',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: _postComment,
                    child: const Text('Post'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
