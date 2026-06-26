const mongoose = require('mongoose');
const dotenv = require('dotenv');

// Load environment variables (failsafe if not loaded in server.js)
dotenv.config();

const MONGO_URI = process.env.MONGO_URI || 'mongodb://localhost:27017/roamly_db';

const connectDB = async () => {
  const options = {
    autoIndex: true, // Build indexes
    connectTimeoutMS: 10000, // Give up initial connection after 10 seconds
    socketTimeoutMS: 45000, // Close sockets after 45 seconds of inactivity
  };

  try {
    console.log('[MongoDB] Attempting connection...');
    await mongoose.connect(MONGO_URI, options);
    
    // Auto-seed default database entities (Destinations, Stories, Posts)
    const seedDatabase = require('./seedDatabase');
    await seedDatabase();
  } catch (err) {
    console.error(`[MongoDB] Initial connection error: ${err.message}`);
    // Trigger initial retry logic
    setTimeout(connectDB, 5000);
  }
};

// Connection event listeners for auto-reconnect and monitoring
mongoose.connection.on('connected', () => {
  console.log('[MongoDB] Connection established successfully.');
});

mongoose.connection.on('error', (err) => {
  console.error(`[MongoDB] Database error occurred: ${err.message}`);
});

mongoose.connection.on('disconnected', () => {
  console.warn('[MongoDB] Connection lost. Auto-reconnecting is handled by Mongoose...');
});

mongoose.connection.on('reconnected', () => {
  console.log('[MongoDB] Reconnected successfully.');
});

// If the Node process ends, close the Mongoose connection
process.on('SIGINT', async () => {
  await mongoose.connection.close();
  console.log('[MongoDB] Connection terminated due to application termination.');
  process.exit(0);
});

module.exports = connectDB;
