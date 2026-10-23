const express = require('express');
const router = express.Router();
const { protect } = require('../middleware/auth');
const { upload } = require('../middleware/upload');
const { createJourney, getJourneys } = require('../controllers/journey.controller');

router.get('/', getJourneys);
router.post('/', protect, upload.array('photos', 5), createJourney);

module.exports = router;
