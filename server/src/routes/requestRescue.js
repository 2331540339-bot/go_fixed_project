const express = require('express');
const router = express.Router();
const requestRescueController = require('../app/controllers/RequestRescueController');
const middleware = require('../app/controllers/MiddlewareController');
router.post('/', middleware.verifyToken, requestRescueController.getRescuing);

module.exports = router