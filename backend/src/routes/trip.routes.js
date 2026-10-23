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
const { upload } = require('../middleware/upload');

router.use(protect); // All trip routes require authentication

router.route('/')
  .get(getUserTrips)
  .post(upload.single('coverImage'), createTrip);

router.route('/:id')
  .get(getTripById)
  .put(upload.single('coverImage'), updateTrip)
  .delete(deleteTrip);



module.exports = router;
