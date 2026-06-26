const express = require('express');
const router = express.Router();

const {
  getDestinations,
  getDestinationById,
  createDestination,
  updateDestination,
  deleteDestination,
} = require('../controllers/destination.controller');

const { protect } = require('../middleware/auth');

// Public routes
router.get('/', getDestinations);
router.get('/:id', getDestinationById);

// Protected routes (require authorization token)
router.post('/', protect, createDestination);
router.put('/:id', protect, updateDestination);
router.delete('/:id', protect, deleteDestination);

module.exports = router;
