const express = require("express");
const router = express.Router();
// const vnPayController = require('../app/controllers/VnPayController');
const vnPayController = require("../app/controllers/VnPayController");
const middlewareController = require("../app/controllers/MiddlewareController");
const jsonParser = express.json();
const urlencodedParser = express.urlencoded({ extended: true });

// router.post('/createqr', middlewareController.verifyToken, vnPayController.createQR);
// router.get('/check-payment-vnpay', middlewareController.verifyToken, vnPayController.checkPayment);
router.post(
  "/create-qr",
  jsonParser,
  urlencodedParser,
  middlewareController.verifyPayment,
  vnPayController.createVnPayQR
);
module.exports = router;
