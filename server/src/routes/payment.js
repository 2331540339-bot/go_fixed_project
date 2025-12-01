const express = require("express");
const router = express.Router();
const vnPayController = require("../app/controllers/VnPayController");
const middlewareController = require("../app/controllers/MiddlewareController");
const jsonParser = express.json();
const urlencodedParser = express.urlencoded({ extended: true });

router.post(
  "/create-qr",
  jsonParser,
  urlencodedParser,
  middlewareController.verifyPayment,
  vnPayController.createVnPayQR
);

router.get("/vnpay-return", vnPayController.vnpayReturn );
module.exports = router;
