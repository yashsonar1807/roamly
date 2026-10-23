const mongoose = require('mongoose');

const destinationSchema = new mongoose.Schema(
  {
    name: {
      type: String,
      required: [true, 'Destination name is required'],
      unique: true,
      trim: true,
    },
    city: {
      type: String,
      required: [true, 'City name is required'],
      trim: true,
    },
    country: {
      type: String,
      required: [true, 'Country name is required'],
      default: 'India',
      trim: true,
    },
    description: {
      type: String,
      trim: true,
    },
    images: {
      type: [String],
      default: [],
    },
    latitude: {
      type: Number,
    },
    longitude: {
      type: Number,
    },
    rating: {
      type: Number,
      default: 0,
      min: [0, 'Rating cannot be less than 0'],
      max: [5, 'Rating cannot be more than 5'],
    },
    category: {
      type: String,
      required: [true, 'Category is required'],
      trim: true,
      enum: {
        values: ['Mountains', 'Beaches', 'Heritage', 'Forests', 'Adventure'],
        message: '{VALUE} is not a valid category',
      },
    },
    iconName: {
      type: String,
      default: 'explore_outlined', // Kept for Flutter icons mapping support
    },
  },
  {
    timestamps: true,
  }
);

destinationSchema.index({ name: 'text', city: 'text', country: 'text' });

const Destination = mongoose.model('Destination', destinationSchema);

module.exports = Destination;
