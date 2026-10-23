const express = require('express');
const {
  getNotifications,
  getUnreadCount,
  markAsRead,
  markAllAsRead,
} = require('../controllers/notification.controller');
const { protect } = require('../middleware/auth');

const router = express.Router();

router.use(protect); // All notification routes require authentication

router.get('/', getNotifications);
router.get('/unread-count', getUnreadCount);
router.put('/read-all', markAllAsRead);
router.put('/:id/read', markAsRead);

module.exports = router;
