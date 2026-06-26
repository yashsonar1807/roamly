const express = require('express');
const router = express.Router();
const { getStories } = require('../controllers/story.controller');

router.get('/', getStories);

module.exports = router;
