const Story = require('../models/Story');

/**
 * @desc    Get all user stories from database
 * @route   GET /api/v1/stories
 * @access  Public
 */
const getStories = async (req, res, next) => {
  try {
    const stories = await Story.find().lean().sort({ createdAt: -1 });
    res.status(200).json({
      status: 'success',
      results: stories.length,
      data: {
        stories,
      },
    });
  } catch (error) {
    next(error);
  }
};

module.exports = {
  getStories,
};
