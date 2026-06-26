const express = require('express');
const router = express.Router();
const { protect } = require('../middleware/auth');
const { upload } = require('../middleware/upload');
const {
  getPosts,
  getPostById,
  createPost,
  updatePost,
  deletePost,
  toggleLikePost,
  createComment,
  deleteComment,
  getPostComments,
} = require('../controllers/post.controller');

// Public routes
router.get('/', getPosts);
router.get('/:id', getPostById);
router.get('/:id/comments', getPostComments);

// Protected routes (requires login authorization token)
router.post('/', protect, upload.single('media'), createPost);
router.put('/:id', protect, upload.single('media'), updatePost);
router.delete('/:id', protect, deletePost);
router.post('/:id/like', protect, toggleLikePost);
router.post('/:id/comments', protect, createComment);
router.delete('/:id/comments/:commentId', protect, deleteComment);

module.exports = router;
