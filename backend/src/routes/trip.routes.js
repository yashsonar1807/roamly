const express = require('express');
const router = express.Router();
const { getUserTrips, createTrip } = require('../controllers/trip.controller');
const { protect } = require('../middleware/auth');

router.use(protect); // Secure all routes in this router

router.get('/', getUserTrips);
router.post('/', createTrip);

module.exports = router;
