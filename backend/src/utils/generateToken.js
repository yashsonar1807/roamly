const jwt = require('jsonwebtoken');

const generateAccessToken = (userId) => {
  return jwt.sign(
    { id: userId },
    process.env.JWT_SECRET || 'super_secret_romaly_token_key_123456',
    { expiresIn: '15m' } // Access token valid for 15 minutes
  );
};

const generateRefreshToken = (userId) => {
  return jwt.sign(
    { id: userId },
    process.env.JWT_REFRESH_SECRET || process.env.JWT_SECRET || 'super_secret_romaly_token_key_123456',
    { expiresIn: '7d' } // Refresh token valid for 7 days
  );
};

module.exports = {
  generateAccessToken,
  generateRefreshToken,
};
