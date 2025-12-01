const express = require('express');
const router = express.Router();
const orderController = require('../app/controllers/OrderController');
const middlewareController = require('../app/controllers/MiddlewareController');

router.post('/create', middlewareController.verifyToken, orderController.create)
router.get('/all', middlewareController.verifyTokenAndAdmin, orderController.showAll)
module.exports = router;
