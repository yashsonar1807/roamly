const mongoose = require('mongoose');

const storySchema = new mongoose.Schema(
  {
    userName: {
      type: String,
      required: [true, 'User name is required for a story'],
      trim: true,
    },
    userAvatar: {
      type: String,
      required: [true, 'User avatar URL is required'],
      trim: true,
    },
  },
  {
    timestamps: true,
  }
);

const Story = mongoose.model('Story', storySchema);

module.exports = Story;
