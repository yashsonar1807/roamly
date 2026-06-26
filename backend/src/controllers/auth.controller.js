const jwt = require('jsonwebtoken');
const User = require('../models/User');
const { generateAccessToken, generateRefreshToken } = require('../utils/generateToken');

/**
 * @desc    Register a new user
 * @route   POST /api/v1/auth/register
 * @access  Public
 */
const registerUser = async (req, res, next) => {
  const { name, username, email, password, phone, country, bio } = req.body;

  try {
    // Check if user already exists by email
    const emailExists = await User.findOne({ email });
    if (emailExists) {
      return res.status(400).json({
        status: 'error',
        message: 'A user with this email address already exists',
      });
    }

    // Check if user already exists by username
    const usernameExists = await User.findOne({ username });
    if (usernameExists) {
      return res.status(400).json({
        status: 'error',
        message: 'This username is already taken',
      });
    }

    // Create new user
    const user = await User.create({
      name,
      username,
      email,
      password,
      phone,
      country,
      bio,
    });

    // Generate Access and Refresh tokens
    const accessToken = generateAccessToken(user._id);
    const refreshToken = generateRefreshToken(user._id);

    // Prepare user response (excluding password)
    const userResponse = {
      id: user._id,
      name: user.name,
      username: user.username,
      email: user.email,
      phone: user.phone,
      country: user.country,
      bio: user.bio,
      profileImage: user.profileImage,
      followersCount: user.followers.length,
      followingCount: user.following.length,
      createdAt: user.createdAt,
    };

    res.status(201).json({
      status: 'success',
      message: 'User registered successfully',
      data: {
        user: userResponse,
        tokens: {
          accessToken,
          refreshToken,
        },
      },
    });
  } catch (error) {
    next(error);
  }
};

/**
 * @desc    Authenticate user & get tokens
 * @route   POST /api/v1/auth/login
 * @access  Public
 */
const loginUser = async (req, res, next) => {
  const { emailOrUsername, password } = req.body;

  try {
    // Find user by email OR username (need password field selected since it's hidden by default)
    const query = emailOrUsername.includes('@')
      ? { email: emailOrUsername.toLowerCase() }
      : { username: emailOrUsername.toLowerCase() };

    const user = await User.findOne(query).select('+password');

    if (!user) {
      return res.status(401).json({
        status: 'error',
        message: 'Invalid credentials',
      });
    }

    // Check password
    const isMatch = await user.comparePassword(password);
    if (!isMatch) {
      return res.status(401).json({
        status: 'error',
        message: 'Invalid credentials',
      });
    }

    // Generate tokens
    const accessToken = generateAccessToken(user._id);
    const refreshToken = generateRefreshToken(user._id);

    // Prepare user response
    const userResponse = {
      id: user._id,
      name: user.name,
      username: user.username,
      email: user.email,
      phone: user.phone,
      country: user.country,
      bio: user.bio,
      profileImage: user.profileImage,
      followersCount: user.followers.length,
      followingCount: user.following.length,
      createdAt: user.createdAt,
    };

    res.status(200).json({
      status: 'success',
      message: 'Login successful',
      data: {
        user: userResponse,
        tokens: {
          accessToken,
          refreshToken,
        },
      },
    });
  } catch (error) {
    next(error);
  }
};

/**
 * @desc    Logout user / clear session
 * @route   POST /api/v1/auth/logout
 * @access  Private
 */
const logoutUser = async (req, res, next) => {
  try {
    // Client is responsible for discarding the tokens. 
    // Here we can log session closure or blacklist the token if redis was integrated.
    res.status(200).json({
      status: 'success',
      message: 'Logged out successfully',
    });
  } catch (error) {
    next(error);
  }
};

/**
 * @desc    Get current user profile
 * @route   GET /api/v1/auth/profile
 * @access  Private
 */
const getUserProfile = async (req, res, next) => {
  try {
    const user = req.user;
    const userResponse = {
      id: user._id,
      name: user.name,
      username: user.username,
      email: user.email,
      phone: user.phone,
      country: user.country,
      bio: user.bio,
      profileImage: user.profileImage,
      followersCount: user.followers.length,
      followingCount: user.following.length,
      createdAt: user.createdAt,
    };

    res.status(200).json({
      status: 'success',
      data: {
        user: userResponse,
      },
    });
  } catch (error) {
    next(error);
  }
};

/**
 * @desc    Update user profile
 * @route   PUT /api/v1/auth/profile
 * @access  Private
 */
const updateUserProfile = async (req, res, next) => {
  const { name, phone, bio, country, profileImage } = req.body;

  try {
    const user = await User.findById(req.user._id);

    if (name) user.name = name;
    if (phone) user.phone = phone;
    if (bio) user.bio = bio;
    if (country) user.country = country;
    if (profileImage !== undefined) user.profileImage = profileImage;

    const updatedUser = await user.save();

    const userResponse = {
      id: updatedUser._id,
      name: updatedUser.name,
      username: updatedUser.username,
      email: updatedUser.email,
      phone: updatedUser.phone,
      country: updatedUser.country,
      bio: updatedUser.bio,
      profileImage: updatedUser.profileImage,
      followersCount: updatedUser.followers.length,
      followingCount: updatedUser.following.length,
      createdAt: updatedUser.createdAt,
    };

    res.status(200).json({
      status: 'success',
      message: 'Profile updated successfully',
      data: {
        user: userResponse,
      },
    });
  } catch (error) {
    next(error);
  }
};

/**
 * @desc    Refresh Access Token
 * @route   POST /api/v1/auth/refresh
 * @access  Public
 */
const refreshAccessToken = async (req, res, next) => {
  const { refreshToken } = req.body;

  if (!refreshToken) {
    return res.status(400).json({
      status: 'error',
      message: 'Refresh token is required',
    });
  }

  try {
    // Verify refresh token
    const decoded = jwt.verify(
      refreshToken,
      process.env.JWT_REFRESH_SECRET || process.env.JWT_SECRET || 'super_secret_roamly_token_key_123456'
    );

    // Verify user still exists
    const user = await User.findById(decoded.id);
    if (!user) {
      return res.status(401).json({
        status: 'error',
        message: 'Invalid refresh token, user no longer exists',
      });
    }

    // Generate a new access token
    const newAccessToken = generateAccessToken(user._id);

    res.status(200).json({
      status: 'success',
      message: 'Token refreshed successfully',
      data: {
        tokens: {
          accessToken: newAccessToken,
          refreshToken, // Return the same refresh token
        },
      },
    });
  } catch (error) {
    console.error(`[Auth Controller] Refresh failed: ${error.message}`);
    return res.status(401).json({
      status: 'error',
      message: 'Invalid or expired refresh token, please login again',
    });
  }
};

/**
 * @desc    Forgot Password (Placeholder)
 * @route   POST /api/v1/auth/forgot-password
 * @access  Public
 */
const forgotPassword = async (req, res, next) => {
  const { email } = req.body;

  if (!email) {
    return res.status(400).json({
      status: 'error',
      message: 'Email address is required',
    });
  }

  try {
    // Placeholder message - does not verify if email exists in DB to prevent enum attacks
    res.status(200).json({
      status: 'success',
      message: 'If a user with this email exists, a password reset link has been sent.',
    });
  } catch (error) {
    next(error);
  }
};

module.exports = {
  registerUser,
  loginUser,
  logoutUser,
  getUserProfile,
  updateUserProfile,
  refreshAccessToken,
  forgotPassword,
};
