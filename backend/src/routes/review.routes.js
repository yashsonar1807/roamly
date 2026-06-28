const express = require('express');
const router = express.Router();

const {
  getReviews,
  addReview,
  updateReview,
  deleteReview,
} = require('../controllers/review.controller');

const { protect } = require('../middleware/auth');

// Public route to get reviews for a destination
router.get('/:destinationId', getReviews);

// Protected routes to add/update/delete reviews
router.post('/:destinationId', protect, addReview);
router.put('/:id', protect, updateReview);
router.delete('/:id', protect, deleteReview);

module.exports = router;
