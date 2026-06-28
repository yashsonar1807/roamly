const express = require('express');
const {
  searchUsers,
  getProfile,
  updateProfile,
  toggleSavePost,
  getSavedPosts,
  getUserPosts,
  toggleSaveDestination,
  getSavedDestinations
} = require('../controllers/user.controller');
const { protect } = require('../middleware/auth');

const router = express.Router();

router.get('/search', searchUsers);

router.get('/profile', protect, getProfile);
router.get('/profile/:id', protect, getProfile);
router.put('/profile', protect, updateProfile);

router.post('/save/:postId', protect, toggleSavePost);
router.get('/saved', protect, getSavedPosts);

router.post('/save-destination/:destinationId', protect, toggleSaveDestination);
router.get('/saved-destinations', protect, getSavedDestinations);

router.get('/:userId/posts', protect, getUserPosts);

module.exports = router;
