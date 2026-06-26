const Post = require('../models/Post');

/**
 * @desc    Get all feed posts from database
 * @route   GET /api/v1/posts
 * @access  Public
 */
const getPosts = async (req, res, next) => {
  try {
    const posts = await Post.find().sort({ createdAt: -1 });
    res.status(200).json({
      status: 'success',
      results: posts.length,
      data: {
        posts,
      },
    });
  } catch (error) {
    next(error);
  }
};

module.exports = {
  getPosts,
};
