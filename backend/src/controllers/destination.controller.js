const Destination = require('../models/Destination');

/**
 * @desc    Get all seeded destinations
 * @route   GET /api/v1/destinations
 * @access  Public
 */
const getDestinations = async (req, res, next) => {
  try {
    const destinations = await Destination.find().sort({ name: 1 });
    res.status(200).json({
      status: 'success',
      results: destinations.length,
      data: {
        destinations,
      },
    });
  } catch (error) {
    next(error);
  }
};

module.exports = {
  getDestinations,
};
