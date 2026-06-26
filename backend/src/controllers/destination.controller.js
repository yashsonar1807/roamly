const Destination = require('../models/Destination');

/**
 * @desc    Get all destinations (with support for filtering & search)
 * @route   GET /api/v1/destinations
 * @access  Public
 */
const getDestinations = async (req, res, next) => {
  const { category, city, search, minRating } = req.query;

  try {
    const query = {};

    // Filter by Category
    if (category && category !== 'All') {
      query.category = category;
    }

    // Filter by City
    if (city) {
      query.city = { $regex: city, $options: 'i' };
    }

    // Filter by Minimum Rating
    if (minRating) {
      const parsedRating = parseFloat(minRating);
      if (!isNaN(parsedRating)) {
        query.rating = { $gte: parsedRating };
      }
    }

    // Search by Name or Description
    if (search) {
      query.$or = [
        { name: { $regex: search, $options: 'i' } },
        { description: { $regex: search, $options: 'i' } },
      ];
    }

    // Pagination Setup
    const page = parseInt(req.query.page, 10) || 1;
    const limit = parseInt(req.query.limit, 10) || 6;
    const skip = (page - 1) * limit;

    const total = await Destination.countDocuments(query);
    const destinations = await Destination.find(query)
      .sort({ name: 1 })
      .skip(skip)
      .limit(limit);

    res.status(200).json({
      status: 'success',
      results: destinations.length,
      pagination: {
        total,
        page,
        limit,
        pages: Math.ceil(total / limit) || 1,
      },
      data: {
        destinations,
      },
    });
  } catch (error) {
    next(error);
  }
};

/**
 * @desc    Get a single destination by ID
 * @route   GET /api/v1/destinations/:id
 * @access  Public
 */
const getDestinationById = async (req, res, next) => {
  try {
    const destination = await Destination.findById(req.params.id);

    if (!destination) {
      return res.status(404).json({
        status: 'error',
        message: 'Destination not found',
      });
    }

    res.status(200).json({
      status: 'success',
      data: {
        destination,
      },
    });
  } catch (error) {
    next(error);
  }
};

/**
 * @desc    Create a new destination
 * @route   POST /api/v1/destinations
 * @access  Private/Protected (For the sake of simplicity, we protect it using protect middleware)
 */
const createDestination = async (req, res, next) => {
  const { name, city, country, description, images, latitude, longitude, rating, category, iconName } = req.body;

  try {
    // Check if destination name already exists
    const exists = await Destination.findOne({ name });
    if (exists) {
      return res.status(400).json({
        status: 'error',
        message: 'A destination with this name already exists',
      });
    }

    const destination = await Destination.create({
      name,
      city,
      country,
      description,
      images,
      latitude,
      longitude,
      rating,
      category,
      iconName,
    });

    res.status(201).json({
      status: 'success',
      message: 'Destination created successfully',
      data: {
        destination,
      },
    });
  } catch (error) {
    next(error);
  }
};

/**
 * @desc    Update a destination by ID
 * @route   PUT /api/v1/destinations/:id
 * @access  Private/Protected
 */
const updateDestination = async (req, res, next) => {
  try {
    const destination = await Destination.findByIdAndUpdate(
      req.params.id,
      req.body,
      {
        new: true,
        runValidators: true,
      }
    );

    if (!destination) {
      return res.status(404).json({
        status: 'error',
        message: 'Destination not found',
      });
    }

    res.status(200).json({
      status: 'success',
      message: 'Destination updated successfully',
      data: {
        destination,
      },
    });
  } catch (error) {
    next(error);
  }
};

/**
 * @desc    Delete a destination by ID
 * @route   DELETE /api/v1/destinations/:id
 * @access  Private/Protected
 */
const deleteDestination = async (req, res, next) => {
  try {
    const destination = await Destination.findByIdAndDelete(req.params.id);

    if (!destination) {
      return res.status(404).json({
        status: 'error',
        message: 'Destination not found',
      });
    }

    res.status(200).json({
      status: 'success',
      message: 'Destination deleted successfully',
    });
  } catch (error) {
    next(error);
  }
};

module.exports = {
  getDestinations,
  getDestinationById,
  createDestination,
  updateDestination,
  deleteDestination,
};
