const Trip = require('../models/Trip');
const User = require('../models/User');

const calculateRank = (points) => {
  if (points >= 20000) return 'Travel Legend';
  if (points >= 10000) return 'World Traveler';
  if (points >= 6000) return 'Globetrotter';
  if (points >= 3000) return 'Adventurer';
  if (points >= 1500) return 'Pathfinder';
  if (points >= 500) return 'Wanderer';
  return 'Explorer';
};

/**
 * @desc    Get all trips belonging to the authenticated user
 * @route   GET /api/v1/trips
 * @access  Private
 */
const getUserTrips = async (req, res, next) => {
  try {
    const trips = await Trip.find({ user: req.user._id }).lean().sort({ createdAt: -1 });
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
  let { title, destination, startDate, endDate, spotsCount, notes, budget, hotel, status } = req.body;

  try {
    if (!title && !destination) {
      return res.status(400).json({
        status: 'error',
        message: 'Please provide a title or destination for the trip',
      });
    }

    if (!title) title = destination;
    if (!destination) destination = title;

    const trip = await Trip.create({
      user: req.user._id,
      title: title.trim(),
      destination: destination.trim(),
      startDate: startDate || new Date(),
      endDate: endDate || new Date(),
      spotsCount: spotsCount || 0,
      notes: notes || '',
      budget: budget || 0,
      hotel: hotel || '',
      status: status || 'Upcoming',
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



/**
 * @desc    Get single trip by ID
 * @route   GET /api/v1/trips/:id
 * @access  Private
 */
const getTripById = async (req, res, next) => {
  try {
    const trip = await Trip.findById(req.params.id);
    if (!trip) {
      return res.status(404).json({ status: 'error', message: 'Trip not found' });
    }

    // Ensure user owns trip
    if (trip.user.toString() !== req.user._id.toString()) {
      return res.status(403).json({ status: 'error', message: 'Not authorized to access this trip' });
    }

    res.status(200).json({
      status: 'success',
      data: { trip },
    });
  } catch (error) {
    next(error);
  }
};

/**
 * @desc    Update a trip
 * @route   PUT /api/v1/trips/:id
 * @access  Private
 */
const updateTrip = async (req, res, next) => {
  try {
    let trip = await Trip.findById(req.params.id);
    if (!trip) {
      return res.status(404).json({ status: 'error', message: 'Trip not found' });
    }

    if (trip.user.toString() !== req.user._id.toString()) {
      return res.status(403).json({ status: 'error', message: 'Not authorized to update this trip' });
    }

    const previousStatus = trip.status;

    trip = await Trip.findByIdAndUpdate(req.params.id, req.body, {
      new: true,
      runValidators: true,
    });

    if (previousStatus === 'Active' && trip.status === 'Completed') {
      const user = await User.findById(req.user._id);
      if (user) {
        user.travelPoints = (user.travelPoints || 0) + 100;
        user.completedTrips = (user.completedTrips || 0) + 1;
        user.rank = calculateRank(user.travelPoints);
        await user.save();
      }
    }

    res.status(200).json({
      status: 'success',
      data: { trip },
    });
  } catch (error) {
    next(error);
  }
};

/**
 * @desc    Delete a trip
 * @route   DELETE /api/v1/trips/:id
 * @access  Private
 */
const deleteTrip = async (req, res, next) => {
  try {
    const trip = await Trip.findById(req.params.id);
    if (!trip) {
      return res.status(404).json({ status: 'error', message: 'Trip not found' });
    }

    if (trip.user.toString() !== req.user._id.toString()) {
      return res.status(403).json({ status: 'error', message: 'Not authorized to delete this trip' });
    }

    await trip.deleteOne();

    res.status(200).json({
      status: 'success',
      message: 'Trip deleted successfully',
    });
  } catch (error) {
    next(error);
  }
};

module.exports = {
  getUserTrips,
  createTrip,
  getTripById,
  updateTrip,
  deleteTrip,
};
