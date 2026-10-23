const Notification = require('../models/Notification');

/**
 * @desc    Get user's notifications
 * @route   GET /api/v1/notifications
 * @access  Private
 */
const getNotifications = async (req, res, next) => {
  try {
    const limit = parseInt(req.query.limit, 10) || 50;

    const notifications = await Notification.find({ recipient: req.user._id })
      .populate('sender', 'name username profileImage avatar')
      .sort({ createdAt: -1 })
      .limit(limit)
      .lean();

    res.status(200).json({
      status: 'success',
      data: {
        notifications,
      },
    });
  } catch (error) {
    next(error);
  }
};

/**
 * @desc    Get unread notification count
 * @route   GET /api/v1/notifications/unread-count
 * @access  Private
 */
const getUnreadCount = async (req, res, next) => {
  try {
    const count = await Notification.countDocuments({
      recipient: req.user._id,
      isRead: false,
    });

    res.status(200).json({
      status: 'success',
      data: {
        unreadCount: count,
      },
    });
  } catch (error) {
    next(error);
  }
};

/**
 * @desc    Mark a notification as read
 * @route   PUT /api/v1/notifications/:id/read
 * @access  Private
 */
const markAsRead = async (req, res, next) => {
  try {
    const notification = await Notification.findOneAndUpdate(
      { _id: req.params.id, recipient: req.user._id },
      { isRead: true },
      { new: true }
    );

    if (!notification) {
      return res.status(404).json({ status: 'error', message: 'Notification not found' });
    }

    res.status(200).json({
      status: 'success',
      data: {
        notification,
      },
    });
  } catch (error) {
    next(error);
  }
};

/**
 * @desc    Mark all notifications as read
 * @route   PUT /api/v1/notifications/read-all
 * @access  Private
 */
const markAllAsRead = async (req, res, next) => {
  try {
    await Notification.updateMany(
      { recipient: req.user._id, isRead: false },
      { $set: { isRead: true } }
    );

    res.status(200).json({
      status: 'success',
      message: 'All notifications marked as read',
    });
  } catch (error) {
    next(error);
  }
};

/**
 * Helper to create a notification (Used internally by other controllers)
 */
const createNotification = async (recipientId, senderId, type, relatedId, message) => {
  try {
    // Don't notify oneself
    if (senderId && recipientId.toString() === senderId.toString()) {
      return;
    }

    await Notification.create({
      recipient: recipientId,
      sender: senderId,
      type,
      relatedId,
      message,
    });
  } catch (error) {
    console.error('Error creating notification:', error);
  }
};

module.exports = {
  getNotifications,
  getUnreadCount,
  markAsRead,
  markAllAsRead,
  createNotification,
};
