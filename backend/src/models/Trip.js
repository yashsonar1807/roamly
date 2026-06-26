const mongoose = require('mongoose');

const tripSchema = new mongoose.Schema(
  {
    user: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: [true, 'A trip must belong to a user'],
    },
    title: {
      type: String,
      required: [true, 'Please provide a trip title'],
      trim: true,
    },
    destination: {
      type: String,
      required: [true, 'Please specify the trip destination'],
      trim: true,
    },
    startDate: {
      type: Date,
    },
    endDate: {
      type: Date,
    },
    spotsCount: {
      type: Number,
      default: 0,
    },
    notes: {
      type: String,
      trim: true,
      default: '',
    },
  },
  {
    timestamps: true,
  }
);

const Trip = mongoose.model('Trip', tripSchema);

module.exports = Trip;
