const mongoose = require('mongoose');

const destinationSchema = new mongoose.Schema(
  {
    name: {
      type: String,
      required: [true, 'Please provide a destination name'],
      unique: true,
      trim: true,
    },
    description: {
      type: String,
      trim: true,
    },
    iconName: {
      type: String,
      default: 'explore_outlined', // Flutter icon identifier
    },
    state: {
      type: String,
      trim: true,
    },
  },
  {
    timestamps: true,
  }
);

const Destination = mongoose.model('Destination', destinationSchema);

module.exports = Destination;
