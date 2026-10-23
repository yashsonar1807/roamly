const mongoose = require('mongoose');

const notificationSchema = new mongoose.Schema(
  {
    recipient: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
    },
    sender: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: false, // Optional for system notifications (like trip reminders)
    },
    type: {
      type: String,
      enum: ['LIKE', 'COMMENT', 'FOLLOW', 'TRIP_REMINDER'],
      required: true,
    },
    relatedId: {
      type: mongoose.Schema.Types.ObjectId,
      required: false, // E.g. Post ID, Comment ID, User ID, or Trip ID
    },
    message: {
      type: String,
      required: true,
    },
    isRead: {
      type: Boolean,
      default: false,
    },
  },
  {
    timestamps: true,
  }
);

// Indexes to speed up queries for a user\'s notifications
notificationSchema.index({ recipient: 1, createdAt: -1 });
notificationSchema.index({ recipient: 1, isRead: 1 });

const Notification = mongoose.model('Notification', notificationSchema);

module.exports = Notification;
