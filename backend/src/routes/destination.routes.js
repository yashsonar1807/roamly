const express = require('express');
const router = express.Router();
const { getDestinations } = require('../controllers/destination.controller');

router.get('/', getDestinations);

module.exports = router;
