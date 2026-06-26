const Post = require('../models/Post');
const Comment = require('../models/Comment');
const { uploadToCloudinary, deleteFromCloudinary } = require('../middleware/upload');
const fs = require('fs');
const path = require('path');

/**
 * @desc    Get all feed posts from database (sorted newest first)
 * @route   GET /api/v1/posts
 * @access  Public
 */
const getPosts = async (req, res, next) => {
  try {
    const posts = await Post.find()
      .populate('user', 'name username avatar')
      .sort({ createdAt: -1 });

    // Format output with compatibility fallbacks for seeded assets
    const formattedPosts = posts.map((post) => {
      const p = post.toObject();
      return {
        _id: p._id,
        user: p.user ? p.user._id : null,
        authorName: p.user ? p.user.name : (p.authorName || 'Anonymous'),
        authorRole: p.user ? 'Explorer' : (p.authorRole || 'Explorer'),
        authorAvatar: p.user ? p.user.avatar : (p.authorAvatar || ''),
        title: p.title || '',
        description: p.description || p.caption || '',
        caption: p.caption || p.description || '',
        mediaUrl: p.mediaUrl || p.image || '',
        mediaType: p.mediaType || (p.image ? 'image' : 'none'),
        location: p.location || '',
        likesCount: p.likesCount || 0,
        commentsCount: p.commentsCount || 0,
        isLiked: req.user ? p.likes.some((id) => id.toString() === req.user._id.toString()) : false,
        createdAt: p.createdAt,
        updatedAt: p.updatedAt,
      };
    });

    res.status(200).json({
      status: 'success',
      results: formattedPosts.length,
      data: {
        posts: formattedPosts,
      },
    });
  } catch (error) {
    next(error);
  }
};

/**
 * @desc    Get single post details
 * @route   GET /api/v1/posts/:id
 * @access  Public
 */
const getPostById = async (req, res, next) => {
  try {
    const post = await Post.findById(req.params.id).populate('user', 'name username avatar');
    if (!post) {
      return res.status(404).json({ status: 'error', message: 'Post not found' });
    }

    const p = post.toObject();
    const formatted = {
      _id: p._id,
      user: p.user ? p.user._id : null,
      authorName: p.user ? p.user.name : (p.authorName || 'Anonymous'),
      authorRole: p.user ? 'Explorer' : (p.authorRole || 'Explorer'),
      authorAvatar: p.user ? p.user.avatar : (p.authorAvatar || ''),
      title: p.title || '',
      description: p.description || p.caption || '',
      caption: p.caption || p.description || '',
      mediaUrl: p.mediaUrl || p.image || '',
      mediaType: p.mediaType || (p.image ? 'image' : 'none'),
      location: p.location || '',
      likesCount: p.likesCount || 0,
      commentsCount: p.commentsCount || 0,
      isLiked: req.user ? p.likes.some((id) => id.toString() === req.user._id.toString()) : false,
      createdAt: p.createdAt,
      updatedAt: p.updatedAt,
    };

    res.status(200).json({
      status: 'success',
      data: {
        post: formatted,
      },
    });
  } catch (error) {
    next(error);
  }
};

/**
 * @desc    Create a new post
 * @route   POST /api/v1/posts
 * @access  Private
 */
const createPost = async (req, res, next) => {
  try {
    const { caption, location } = req.body;

    if (!caption || caption.trim() === '') {
      return res.status(400).json({ status: 'error', message: 'Caption is required' });
    }

    let mediaUrl = '';
    let mediaType = 'none';
    let mediaPublicId = '';

    if (req.file) {
      const fileType = req.file.mimetype;
      mediaType = fileType.startsWith('video/') ? 'video' : 'image';

      // Upload to Cloudinary helper
      const uploadResult = await uploadToCloudinary(req.file.path, fileType);
      
      if (uploadResult) {
        mediaUrl = uploadResult.url;
        mediaPublicId = uploadResult.publicId;
      } else {
        // Fallback to local server serving URL
        const serverUrl = `${req.protocol}://${req.get('host')}`;
        mediaUrl = `${serverUrl}/uploads/${req.file.filename}`;
      }
    }

    const post = await Post.create({
      user: req.user._id,
      caption: caption.trim(),
      description: caption.trim(),
      location: location ? location.trim() : '',
      mediaUrl,
      image: mediaUrl,
      mediaType,
      mediaPublicId,
    });

    res.status(201).json({
      status: 'success',
      data: {
        post,
      },
    });
  } catch (error) {
    next(error);
  }
};

/**
 * @desc    Update a post (only allowed for post creator)
 * @route   PUT /api/v1/posts/:id
 * @access  Private
 */
const updatePost = async (req, res, next) => {
  try {
    const { caption, location } = req.body;
    const post = await Post.findById(req.params.id);

    if (!post) {
      return res.status(404).json({ status: 'error', message: 'Post not found' });
    }

    // Restrict updates to the post creator
    if (post.user && post.user.toString() !== req.user._id.toString()) {
      return res.status(403).json({ status: 'error', message: 'You are not authorized to edit this post' });
    }

    if (req.file) {
      // Clear old media files
      if (post.mediaPublicId) {
        await deleteFromCloudinary(post.mediaPublicId, post.mediaType);
      } else if (post.mediaUrl && post.mediaUrl.includes('/uploads/')) {
        const filename = post.mediaUrl.split('/uploads/')[1];
        const localPath = path.join(__dirname, '../uploads', filename);
        if (fs.existsSync(localPath)) {
          fs.unlinkSync(localPath);
        }
      }

      const fileType = req.file.mimetype;
      post.mediaType = fileType.startsWith('video/') ? 'video' : 'image';

      const uploadResult = await uploadToCloudinary(req.file.path, fileType);
      if (uploadResult) {
        post.mediaUrl = uploadResult.url;
        post.image = uploadResult.url;
        post.mediaPublicId = uploadResult.publicId;
      } else {
        const serverUrl = `${req.protocol}://${req.get('host')}`;
        post.mediaUrl = `${serverUrl}/uploads/${req.file.filename}`;
        post.image = post.mediaUrl;
        post.mediaPublicId = '';
      }
    }

    if (caption !== undefined) {
      post.caption = caption.trim();
      post.description = caption.trim();
    }
    if (location !== undefined) {
      post.location = location.trim();
    }

    await post.save();

    res.status(200).json({
      status: 'success',
      data: {
        post,
      },
    });
  } catch (error) {
    next(error);
  }
};

/**
 * @desc    Delete a post (only allowed for post creator)
 * @route   DELETE /api/v1/posts/:id
 * @access  Private
 */
const deletePost = async (req, res, next) => {
  try {
    const post = await Post.findById(req.params.id);

    if (!post) {
      return res.status(404).json({ status: 'error', message: 'Post not found' });
    }

    // Restrict deletion to the post creator
    if (post.user && post.user.toString() !== req.user._id.toString()) {
      return res.status(403).json({ status: 'error', message: 'You are not authorized to delete this post' });
    }

    // Clean up media files
    if (post.mediaPublicId) {
      await deleteFromCloudinary(post.mediaPublicId, post.mediaType);
    } else if (post.mediaUrl && post.mediaUrl.includes('/uploads/')) {
      const filename = post.mediaUrl.split('/uploads/')[1];
      const localPath = path.join(__dirname, '../uploads', filename);
      if (fs.existsSync(localPath)) {
        fs.unlinkSync(localPath);
      }
    }

    // Remove all associated comments from DB
    await Comment.deleteMany({ post: post._id });

    // Remove the post
    await post.deleteOne();

    res.status(200).json({
      status: 'success',
      message: 'Post deleted successfully',
    });
  } catch (error) {
    next(error);
  }
};

/**
 * @desc    Toggle Like on a post
 * @route   POST /api/v1/posts/:id/like
 * @access  Private
 */
const toggleLikePost = async (req, res, next) => {
  try {
    const post = await Post.findById(req.params.id);

    if (!post) {
      return res.status(404).json({ status: 'error', message: 'Post not found' });
    }

    const likeIndex = post.likes.indexOf(req.user._id);

    if (likeIndex > -1) {
      // User has already liked, unlike it
      post.likes.splice(likeIndex, 1);
    } else {
      // User has not liked, add like
      post.likes.push(req.user._id);
    }

    await post.save();

    res.status(200).json({
      status: 'success',
      likesCount: post.likesCount,
      isLiked: post.likes.includes(req.user._id),
    });
  } catch (error) {
    next(error);
  }
};

/**
 * @desc    Add a comment to a post
 * @route   POST /api/v1/posts/:id/comments
 * @access  Private
 */
const createComment = async (req, res, next) => {
  try {
    const { text } = req.body;
    const postId = req.params.id;

    if (!text || text.trim() === '') {
      return res.status(400).json({ status: 'error', message: 'Comment text is required' });
    }

    const post = await Post.findById(postId);
    if (!post) {
      return res.status(404).json({ status: 'error', message: 'Post not found' });
    }

    const comment = await Comment.create({
      user: req.user._id,
      post: postId,
      text: text.trim(),
    });

    // Recalculate commentsCount
    post.commentsCount = await Comment.countDocuments({ post: postId });
    await post.save();

    const populatedComment = await comment.populate('user', 'name username avatar');

    res.status(201).json({
      status: 'success',
      data: {
        comment: populatedComment,
      },
    });
  } catch (error) {
    next(error);
  }
};

/**
 * @desc    Delete a comment (only comment creator OR post owner can delete)
 * @route   DELETE /api/v1/posts/:id/comments/:commentId
 * @access  Private
 */
const deleteComment = async (req, res, next) => {
  try {
    const { id, commentId } = req.params;

    const comment = await Comment.findById(commentId);
    if (!comment) {
      return res.status(404).json({ status: 'error', message: 'Comment not found' });
    }

    const post = await Post.findById(id);
    if (!post) {
      return res.status(404).json({ status: 'error', message: 'Post not found' });
    }

    const isCommentOwner = comment.user.toString() === req.user._id.toString();
    const isPostOwner = post.user && post.user.toString() === req.user._id.toString();

    if (!isCommentOwner && !isPostOwner) {
      return res.status(403).json({ status: 'error', message: 'Not authorized to delete this comment' });
    }

    await comment.deleteOne();

    // Recalculate commentsCount
    post.commentsCount = await Comment.countDocuments({ post: id });
    await post.save();

    res.status(200).json({
      status: 'success',
      message: 'Comment deleted successfully',
    });
  } catch (error) {
    next(error);
  }
};

/**
 * @desc    Get comments list for a post
 * @route   GET /api/v1/posts/:id/comments
 * @access  Public
 */
const getPostComments = async (req, res, next) => {
  try {
    const comments = await Comment.find({ post: req.params.id })
      .populate('user', 'name username avatar')
      .sort({ createdAt: 1 });

    res.status(200).json({
      status: 'success',
      results: comments.length,
      data: {
        comments,
      },
    });
  } catch (error) {
    next(error);
  }
};

module.exports = {
  getPosts,
  getPostById,
  createPost,
  updatePost,
  deletePost,
  toggleLikePost,
  createComment,
  deleteComment,
  getPostComments,
};
