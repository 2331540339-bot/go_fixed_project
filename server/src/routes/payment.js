const express = require('express');
const router = express.Router();
const vnPayController = require('../app/controllers/VnPayController');
const middlewareController = require('../app/controllers/MiddlewareController');

router.post('/createqr', vnPayController.createVnPayQR);

module.exports = router;