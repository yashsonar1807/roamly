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
  const { title, destination, startDate, endDate, spotsCount, notes, budget, hotel, status } = req.body;

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
      budget: budget || 0,
      hotel,
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

    trip = await Trip.findByIdAndUpdate(req.params.id, req.body, {
      new: true,
      runValidators: true,
    });

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
