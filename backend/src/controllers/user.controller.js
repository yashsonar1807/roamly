const User = require('../models/User');
const Post = require('../models/Post');
const Trip = require('../models/Trip');

/**
 * @desc    Search users by name or username
 * @route   GET /api/v1/users/search
 * @access  Public
 */
const searchUsers = async (req, res) => {
  try {
    const { q = '', limit = 20 } = req.query;

    const query = {};
    if (q.trim()) {
      query.$or = [
        { name: { $regex: q, $options: 'i' } },
        { username: { $regex: q, $options: 'i' } },
      ];
    }

    const users = await User.find(query)
      .select('_id name username profileImage bio')
      .limit(parseInt(limit, 10))
      .sort({ name: 1 });

    res.json({
      success: true,
      count: users.length,
      users,
    });
  } catch (error) {
    console.error('Error searching users:', error);
    res.status(500).json({ success: false, message: 'Server Error' });
  }
};

/**
 * @desc    Get user profile data including followers/following counts
 * @route   GET /api/v1/users/profile/:id?
 * @access  Private
 */
const getProfile = async (req, res) => {
  try {
    let userId = req.params.id || req.user._id;
    if (userId === 'me' || userId === 'profile') {
      userId = req.user._id;
    }
    const user = await User.findById(userId).select('-password');
    if (!user) {
      return res.status(404).json({ success: false, message: 'User not found' });
    }

    const postsCount = await Post.countDocuments({ user: userId });
    const tripsCount = await Trip.countDocuments({ user: userId });

    const profileData = {
      ...user.toObject(),
      followersCount: user.followers.length,
      followingCount: user.following.length,
      postsCount,
      tripsCount,
    };

    res.json({ success: true, data: profileData });
  } catch (error) {
    console.error('Error getting profile:', error);
    res.status(500).json({ success: false, message: 'Server Error' });
  }
};

/**
 * @desc    Update user profile
 * @route   PUT /api/v1/users/profile
 * @access  Private
 */
const updateProfile = async (req, res) => {
  try {
    const { name, bio, profileImage } = req.body;
    const user = await User.findById(req.user._id);

    if (name) user.name = name;
    if (bio !== undefined) user.bio = bio;
    if (profileImage !== undefined) user.profileImage = profileImage;

    await user.save();

    res.json({
      success: true,
      data: {
        _id: user._id,
        name: user.name,
        username: user.username,
        email: user.email,
        bio: user.bio,
        profileImage: user.profileImage,
        followersCount: user.followers.length,
        followingCount: user.following.length,
      }
    });
  } catch (error) {
    console.error('Error updating profile:', error);
    res.status(500).json({ success: false, message: 'Server Error' });
  }
};

/**
 * @desc    Save a post
 * @route   POST /api/v1/users/save/:postId
 * @access  Private
 */
const toggleSavePost = async (req, res) => {
  try {
    const user = await User.findById(req.user._id);
    const postId = req.params.postId;

    const isSaved = user.savedPosts.includes(postId);
    if (isSaved) {
      user.savedPosts.pull(postId);
    } else {
      user.savedPosts.push(postId);
    }
    await user.save();

    res.json({ success: true, isSaved: !isSaved, savedPosts: user.savedPosts });
  } catch (error) {
    console.error('Error toggling saved post:', error);
    res.status(500).json({ success: false, message: 'Server Error' });
  }
};

/**
 * @desc    Get saved posts
 * @route   GET /api/v1/users/saved
 * @access  Private
 */
const getSavedPosts = async (req, res) => {
  try {
    const user = await User.findById(req.user._id).populate({
      path: 'savedPosts',
      populate: { path: 'user', select: 'name username profileImage' }
    });

    res.json({ success: true, data: user.savedPosts });
  } catch (error) {
    console.error('Error getting saved posts:', error);
    res.status(500).json({ success: false, message: 'Server Error' });
  }
};

/**
 * @desc    Get user's posts
 * @route   GET /api/v1/users/:userId/posts
 * @access  Private
 */
const getUserPosts = async (req, res) => {
  try {
    const userId = req.params.userId === 'me' ? req.user._id : req.params.userId;
    const posts = await Post.find({ user: userId })
      .populate('user', 'name username profileImage')
      .sort({ createdAt: -1 });

    res.json({ success: true, data: posts });
  } catch (error) {
    console.error('Error getting user posts:', error);
    res.status(500).json({ success: false, message: 'Server Error' });
  }
};

/**
 * @desc    Save a destination
 * @route   POST /api/v1/users/save-destination/:destinationId
 * @access  Private
 */
const toggleSaveDestination = async (req, res) => {
  try {
    const user = await User.findById(req.user._id);
    const destinationId = req.params.destinationId;

    const isSaved = user.savedDestinations.includes(destinationId);
    if (isSaved) {
      user.savedDestinations.pull(destinationId);
    } else {
      user.savedDestinations.push(destinationId);
    }
    await user.save();

    res.json({ success: true, isSaved: !isSaved, savedDestinations: user.savedDestinations });
  } catch (error) {
    console.error('Error toggling saved destination:', error);
    res.status(500).json({ success: false, message: 'Server Error' });
  }
};

/**
 * @desc    Get saved destinations
 * @route   GET /api/v1/users/saved-destinations
 * @access  Private
 */
const getSavedDestinations = async (req, res) => {
  try {
    const user = await User.findById(req.user._id).populate({
      path: 'savedDestinations',
    });

    res.json({ success: true, data: user.savedDestinations });
  } catch (error) {
    console.error('Error getting saved destinations:', error);
    res.status(500).json({ success: false, message: 'Server Error' });
  }
};

module.exports = {
  searchUsers,
  getProfile,
  updateProfile,
  toggleSavePost,
  getSavedPosts,
  getUserPosts,
  toggleSaveDestination,
  getSavedDestinations,
};
