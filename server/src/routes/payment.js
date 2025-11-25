const express = require('express');
const router = express.Router();
const vnPayController = require('../app/controllers/VnPayController');
const middlewareController = require('../app/controllers/MiddlewareController');

router.post('/createqr', middlewareController.verifyToken, vnPayController.createQR);
router.get('/check-payment-vnpay', middlewareController.verifyToken, vnPayController.checkPayment);

module.exports = router;