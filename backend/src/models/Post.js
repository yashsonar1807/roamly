const mongoose = require('mongoose');

const postSchema = new mongoose.Schema(
  {
    authorName: {
      type: String,
      required: [true, 'Author name is required'],
      trim: true,
    },
    authorRole: {
      type: String,
      default: 'Explorer',
      trim: true,
    },
    authorAvatar: {
      type: String,
      trim: true,
    },
    title: {
      type: String,
      required: [true, 'Post title is required'],
      trim: true,
    },
    description: {
      type: String,
      required: [true, 'Post description is required'],
      trim: true,
    },
    image: {
      type: String,
      trim: true,
    },
    likesCount: {
      type: Number,
      default: 0,
    },
    commentsCount: {
      type: Number,
      default: 0,
    },
  },
  {
    timestamps: true,
  }
);

const Post = mongoose.model('Post', postSchema);

module.exports = Post;
