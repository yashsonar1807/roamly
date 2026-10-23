const { body, validationResult } = require('express-validator');

// Middleware to capture and format validation errors
const validate = (req, res, next) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(400).json({
      status: 'error',
      message: 'Validation failed',
      errors: errors.array().map((err) => ({
        field: err.path,
        message: err.msg,
      })),
    });
  }
  next();
};

// Validation rules for user registration
const validateRegister = [
  body('name')
    .trim()
    .notEmpty()
    .withMessage('Name is required')
    .isLength({ max: 50 })
    .withMessage('Name cannot exceed 50 characters'),
  body('username')
    .trim()
    .notEmpty()
    .withMessage('Username is required')
    .isLength({ min: 3, max: 30 })
    .withMessage('Username must be between 3 and 30 characters')
    .matches(/^[a-zA-Z0-9_.]+$/)
    .withMessage('Username can only contain letters, numbers, dots, and underscores'),
  body('email')
    .trim()
    .notEmpty()
    .withMessage('Email is required')
    .isEmail()
    .withMessage('Please provide a valid email address'),
  body('password')
    .trim()
    .notEmpty()
    .withMessage('Password is required')
    .isLength({ min: 6 })
    .withMessage('Password must be at least 6 characters'),
  body('phone')
    .optional({ checkFalsy: true })
    .trim()
    .matches(/^\+?[1-9]\d{1,14}$/)
    .withMessage('Please provide a valid phone number (e.g. +1234567890)'),
  body('country').optional({ checkFalsy: true }).trim(),
  body('bio')
    .optional({ checkFalsy: true })
    .trim()
    .isLength({ max: 160 })
    .withMessage('Bio cannot exceed 160 characters'),
  validate,
];

// Validation rules for user login
const validateLogin = [
  body('emailOrUsername')
    .trim()
    .notEmpty()
    .withMessage('Please provide your email address or username'),
  body('password').trim().notEmpty().withMessage('Password is required'),
  validate,
];

// Validation rules for profile updates
const validateUpdateProfile = [
  body('name')
    .optional({ checkFalsy: true })
    .trim()
    .isLength({ max: 50 })
    .withMessage('Name cannot exceed 50 characters'),
  body('phone')
    .optional({ checkFalsy: true })
    .trim()
    .matches(/^\+?[1-9]\d{1,14}$/)
    .withMessage('Please provide a valid phone number'),
  body('bio')
    .optional({ checkFalsy: true })
    .trim()
    .isLength({ max: 160 })
    .withMessage('Bio cannot exceed 160 characters'),
  body('country').optional({ checkFalsy: true }).trim(),
  validate,
];

module.exports = {
  validateRegister,
  validateLogin,
  validateUpdateProfile,
};
