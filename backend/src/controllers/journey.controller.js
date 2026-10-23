const Journey = require('../models/Journey');
const { uploadToCloudinary } = require('../middleware/upload');

exports.createJourney = async (req, res, next) => {
  try {
    const { title, description, budget, duration, itinerary, trip, destinationName } = req.body;

    // Handle photo uploads if any
    const photos = [];
    if (req.files && req.files.length > 0) {
      for (const file of req.files) {
        const uploadResult = await uploadToCloudinary(file.path, 'image');
        if (uploadResult) {
          photos.push(uploadResult.url);
        } else {
          const serverUrl = `${req.protocol}://${req.get('host')}`;
          photos.push(`${serverUrl}/uploads/${file.filename}`);
        }
      }
    }

    const journey = await Journey.create({
      user: req.user._id,
      trip,
      title,
      description,
      budget,
      duration,
      itinerary,
      photos,
      destinationName: destinationName || 'Unknown',
    });

    res.status(201).json({
      status: 'success',
      data: { journey },
    });
  } catch (error) {
    next(error);
  }
};

exports.getJourneys = async (req, res, next) => {
  try {
    const { search, minRating, maxBudget } = req.query;
    let query = {};

    if (search) {
      query.$or = [
        { title: { $regex: search, $options: 'i' } },
        { destinationName: { $regex: search, $options: 'i' } },
      ];
    }

    if (minRating) {
      query.rating = { $gte: Number(minRating) };
    }
    
    // Budget filtering is tricky since it's a string, but we can do a naive check if requested,
    // or leave it to frontend. We'll leave budget filtering to frontend for now due to currency parsing complexity.

    const journeys = await Journey.find(query)
      .populate('user', 'name username avatar rank')
      .populate('trip', 'title destination status startDate endDate')
      .sort({ createdAt: -1 });

    res.status(200).json({
      status: 'success',
      results: journeys.length,
      data: { journeys },
    });
  } catch (error) {
    next(error);
  }
};
