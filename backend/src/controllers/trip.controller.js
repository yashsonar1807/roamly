const Trip = require('../models/Trip');

/**
 * @desc    Get all trips belonging to the authenticated user
 * @route   GET /api/v1/trips
 * @access  Private
 */
const getUserTrips = async (req, res, next) => {
  try {
    const trips = await Trip.find({ user: req.user._id }).sort({ createdAt: -1 });
    res.status(200).json({
      status: 'success',
      results: trips.length,
      data: {
        trips,
      },
    });
  } catch (error) {
    next(error);
  }
};

/**
 * @desc    Create a new travel trip log
 * @route   POST /api/v1/trips
 * @access  Private
 */
const createTrip = async (req, res, next) => {
  const { title, destination, startDate, endDate, spotsCount, notes } = req.body;

  try {
    if (!title || !destination) {
      return res.status(400).json({
        status: 'error',
        message: 'Please provide a title and destination for the trip',
      });
    }

    const trip = await Trip.create({
      user: req.user._id,
      title,
      destination,
      startDate,
      endDate,
      spotsCount: spotsCount || 0,
      notes,
    });

    res.status(201).json({
      status: 'success',
      message: 'Trip logged successfully',
      data: {
        trip,
      },
    });
  } catch (error) {
    next(error);
  }
};

module.exports = {
  getUserTrips,
  createTrip,
};
