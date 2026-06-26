const express = require('express');
const router = express.Router();

const {
  registerUser,
  loginUser,
  logoutUser,
  getUserProfile,
  updateUserProfile,
  refreshAccessToken,
  forgotPassword,
} = require('../controllers/auth.controller');

const {
  validateRegister,
  validateLogin,
  validateUpdateProfile,
} = require('../middleware/validation');

const { protect } = require('../middleware/auth');

// Public routes
router.post('/register', validateRegister, registerUser);
router.post('/login', validateLogin, loginUser);
router.post('/refresh', refreshAccessToken);
router.post('/forgot-password', forgotPassword);

// Private/Protected routes
router.post('/logout', protect, logoutUser);
router.get('/profile', protect, getUserProfile);
router.put('/profile', protect, validateUpdateProfile, updateUserProfile);

module.exports = router;
