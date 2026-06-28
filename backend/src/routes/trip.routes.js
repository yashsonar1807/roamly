const express = require('express');
const router = express.Router();
const { 
  getUserTrips, 
  createTrip,
  getTripById,
  updateTrip,
  deleteTrip
} = require('../controllers/trip.controller');
const { protect } = require('../middleware/auth');

router.use(protect); // Secure all routes in this router

router.get('/', getUserTrips);
router.post('/', createTrip);
router.get('/:id', getTripById);
router.put('/:id', updateTrip);
router.delete('/:id', deleteTrip);

module.exports = router;
