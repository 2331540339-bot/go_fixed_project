const express = require('express');
const router = express.Router();
const cartController = require('../app/controllers/CartController')
const middlewareController = require('../app/controllers/MiddlewareController')
router.get('/get', middlewareController.verifyToken ,cartController.get)
router.post('/add', middlewareController.verifyToken ,cartController.add)
router.patch('/update', middlewareController.verifyToken ,cartController.updateQuantity)
router.delete('/delete', middlewareController.verifyToken ,cartController.removeItem)

module.exports = router;