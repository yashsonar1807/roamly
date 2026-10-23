const mongoose = require('mongoose');

const storySchema = new mongoose.Schema(
  {
    user: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
    },
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

storySchema.index({ user: 1 });
storySchema.index({ createdAt: -1 });

const Story = mongoose.model('Story', storySchema);

module.exports = Story;
