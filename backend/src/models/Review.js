const mongoose = require('mongoose');

const reviewSchema = new mongoose.Schema(
  {
    rating: {
      type: Number,
      min: 1,
      max: 5,
      required: [true, 'Please add a rating between 1 and 5'],
    },
    comment: {
      type: String,
      required: [true, 'Please add a comment text'],
    },
    images: {
      type: [String],
      default: [],
    },
    destination: {
      type: mongoose.Schema.ObjectId,
      ref: 'Destination',
      required: true,
    },
    user: {
      type: mongoose.Schema.ObjectId,
      ref: 'User',
      required: true,
    },
  },
  {
    timestamps: true,
  }
);

// Prevent user from submitting more than one review per destination
reviewSchema.index({ destination: 1, user: 1 }, { unique: true });

// Static method to get avg rating and update destination
reviewSchema.statics.getAverageRating = async function (destinationId) {
  const obj = await this.aggregate([
    {
      $match: { destination: destinationId },
    },
    {
      $group: {
        _id: '$destination',
        averageRating: { $avg: '$rating' },
      },
    },
  ]);

  try {
    const Destination = this.model('Destination');
    if (obj.length > 0) {
      await Destination.findByIdAndUpdate(destinationId, {
        rating: Math.round(obj[0].averageRating * 10) / 10, // round to 1 decimal
      });
    } else {
      await Destination.findByIdAndUpdate(destinationId, {
        rating: 0,
      });
    }
  } catch (err) {
    console.error(err);
  }
};

// Call getAverageRating after save
reviewSchema.post('save', function () {
  this.constructor.getAverageRating(this.destination);
});

// Call getAverageRating after remove
reviewSchema.post('remove', function () {
  this.constructor.getAverageRating(this.destination);
});

module.exports = mongoose.model('Review', reviewSchema);
