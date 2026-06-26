const jwt = require('jsonwebtoken');
const User = require('../models/User');

const protect = async (req, res, next) => {
  let token;

  // Check if authorization header is present and starts with 'Bearer'
  if (req.headers.authorization && req.headers.authorization.startsWith('Bearer')) {
    token = req.headers.authorization.split(' ')[1];
  }

  if (!token) {
    return res.status(401).json({
      status: 'error',
      message: 'Not authorized, token is missing',
    });
  }

  try {
    // Verify the token
    const decoded = jwt.verify(
      token,
      process.env.JWT_SECRET || 'super_secret_roamly_token_key_123456'
    );

    // Fetch the user from database and attach to request object
    const user = await User.findById(decoded.id);

    if (!user) {
      return res.status(401).json({
        status: 'error',
        message: 'Not authorized, user no longer exists',
      });
    }

    req.user = user;
    next();
  } catch (error) {
    console.error(`[Auth Middleware] Verification failed: ${error.message}`);
    
    let message = 'Not authorized, token verification failed';
    if (error.name === 'TokenExpiredError') {
      message = 'Session expired, please login again';
    }

    return res.status(401).json({
      status: 'error',
      message,
    });
  }
};

module.exports = { protect };
