const Review = require('../models/Review');
const Destination = require('../models/Destination');

/**
 * @desc    Get reviews for a destination
 * @route   GET /api/v1/reviews/:destinationId
 * @access  Public
 */
const getReviews = async (req, res, next) => {
  try {
    const page = parseInt(req.query.page, 10) || 1;
    const limit = parseInt(req.query.limit, 10) || 10;
    const skip = (page - 1) * limit;

    const query = { destination: req.params.destinationId };

    const total = await Review.countDocuments(query);
    const reviews = await Review.find(query).lean()
      .populate('user', 'name username profileImage')
      .sort({ createdAt: -1 })
      .skip(skip)
      .limit(limit);

    res.status(200).json({
      status: 'success',
      results: reviews.length,
      pagination: {
        total,
        page,
        limit,
        pages: Math.ceil(total / limit) || 1,
      },
      data: {
        reviews,
      },
    });
  } catch (error) {
    next(error);
  }
};

/**
 * @desc    Add a review
 * @route   POST /api/v1/reviews/:destinationId
 * @access  Private
 */
const addReview = async (req, res, next) => {
  req.body.destination = req.params.destinationId;
  req.body.user = req.user.id;

  try {
    const destination = await Destination.findById(req.params.destinationId);
    if (!destination) {
      return res.status(404).json({
        status: 'error',
        message: 'Destination not found',
      });
    }

    // Create review
    const review = await Review.create(req.body);
    await review.populate('user', 'name username profileImage');

    res.status(201).json({
      status: 'success',
      data: {
        review,
      },
    });
  } catch (error) {
    // Check for duplicate key error (user already reviewed)
    if (error.code === 11000) {
      return res.status(400).json({
        status: 'error',
        message: 'You have already reviewed this destination',
      });
    }
    next(error);
  }
};

/**
 * @desc    Update a review
 * @route   PUT /api/v1/reviews/:id
 * @access  Private
 */
const updateReview = async (req, res, next) => {
  try {
    let review = await Review.findById(req.params.id);

    if (!review) {
      return res.status(404).json({
        status: 'error',
        message: 'Review not found',
      });
    }

    // Make sure review belongs to user
    if (review.user.toString() !== req.user.id) {
      return res.status(401).json({
        status: 'error',
        message: 'Not authorized to update this review',
      });
    }

    review = await Review.findByIdAndUpdate(req.params.id, req.body, {
      new: true,
      runValidators: true,
    }).populate('user', 'name username profileImage');

    // Trigger post save hook manually for update
    await review.constructor.getAverageRating(review.destination);

    res.status(200).json({
      status: 'success',
      data: {
        review,
      },
    });
  } catch (error) {
    next(error);
  }
};

/**
 * @desc    Delete a review
 * @route   DELETE /api/v1/reviews/:id
 * @access  Private
 */
const deleteReview = async (req, res, next) => {
  try {
    const review = await Review.findById(req.params.id);

    if (!review) {
      return res.status(404).json({
        status: 'error',
        message: 'Review not found',
      });
    }

    // Make sure review belongs to user
    if (review.user.toString() !== req.user.id) {
      return res.status(401).json({
        status: 'error',
        message: 'Not authorized to delete this review',
      });
    }

    await review.deleteOne();
    // note: post('remove') hook is deprecated in newer mongoose, often pre('deleteOne') or post('deleteOne') is used, or we call the static directly
    // Let's call it manually just to be safe
    await review.constructor.getAverageRating(review.destination);

    res.status(200).json({
      status: 'success',
      data: {},
    });
  } catch (error) {
    next(error);
  }
};

module.exports = {
  getReviews,
  addReview,
  updateReview,
  deleteReview,
};
