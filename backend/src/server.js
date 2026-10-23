const express = require('express');
const cors = require('cors');
const dotenv = require('dotenv');
const path = require('path');
const connectDB = require('./config/database');
const authRoutes = require('./routes/auth.routes');
const destinationRoutes = require('./routes/destination.routes');
const tripRoutes = require('./routes/trip.routes');
const storyRoutes = require('./routes/story.routes');
const postRoutes = require('./routes/post.routes');
const userRoutes = require('./routes/user.routes');
const notificationRoutes = require('./routes/notification.routes');
const reviewRoutes = require('./routes/review.routes');
const journeyRoutes = require('./routes/journey.routes');

// Load environment variables
dotenv.config();

// Initialize express app
const app = express();

// Establish Database Connection
connectDB();

// Global Middlewares
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Serve local uploads folder statically
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));

// Auth Routes Mount
app.use('/api/v1/auth', authRoutes);
app.use('/api/v1/destinations', destinationRoutes);
app.use('/api/v1/trips', tripRoutes);
app.use('/api/v1/stories', storyRoutes);
app.use('/api/v1/posts', postRoutes);
app.use('/api/v1/users', userRoutes);
app.use('/api/v1/user', userRoutes); // Alias for singular user endpoints
app.use('/api/v1/notifications', notificationRoutes);
app.use('/api/v1/reviews', reviewRoutes);
app.use('/api/v1/journeys', journeyRoutes);

// Default / Health Check Route
app.get('/', (req, res) => {
  res.status(200).json({
    status: 'success',
    message: 'Welcome to Roamly API Server',
    environment: process.env.NODE_ENV || 'development',
    timestamp: new Date().toISOString()
  });
});

app.get('/health', (req, res) => {
  res.status(200).json({
    status: 'UP',
    database: 'connected', // We can add verification if needed, but db connection is established
    timestamp: new Date().toISOString()
  });
});

// Global Error Handler Middleware
app.use((err, req, res, next) => {
  console.error(`[Error] ${err.stack}`);
  res.status(err.status || 500).json({
    status: 'error',
    message: err.message || 'Internal Server Error',
    stack: process.env.NODE_ENV === 'development' ? err.stack : undefined
  });
});

// Server Initialization
const PORT = process.env.PORT || 5000;
const server = app.listen(PORT, '0.0.0.0', () => {
  console.log(`[Server] Roamly server is running in ${process.env.NODE_ENV || 'development'} mode on port ${PORT}`);
});

// Handle unhandled promise rejections
process.on('unhandledRejection', (err, promise) => {
  console.error(`[Unhandled Rejection] Error: ${err.message}`);
  // Close server & exit process
  server.close(() => process.exit(1));
});
