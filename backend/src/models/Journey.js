const mongoose = require('mongoose');

const journeySchema = new mongoose.Schema(
  {
    user: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
    },
    trip: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Trip',
      required: true,
    },
    destinationName: {
      type: String,
      required: true,
    },
    title: {
      type: String,
      required: [true, 'Please add a journey title'],
      trim: true,
      maxlength: [100, 'Title cannot be more than 100 characters'],
    },
    description: {
      type: String,
      required: [true, 'Please add a description'],
      maxlength: [2000, 'Description cannot be more than 2000 characters'],
    },
    budget: {
      type: String,
    },
    duration: {
      type: String,
    },
    itinerary: {
      type: String,
    },
    photos: {
      type: [String],
      default: [],
    },
    rating: {
      type: Number,
      default: 0,
    },
    ratingCount: {
      type: Number,
      default: 0,
    },
  },
  {
    timestamps: true,
  }
);

// Add index to fetch by user easily, and reverse chronologically
journeySchema.index({ user: 1, createdAt: -1 });

module.exports = mongoose.model('Journey', journeySchema);
