const express = require('express');
const router = express.Router();
const serviceController = require('../app/controllers/ServiceController');
const middlewareController = require('../app/controllers/MiddlewareController');

router.get('/get', serviceController.showall)
router.post('/add', serviceController.add)
router.post('/rescue/:id',middlewareController.verifyService,serviceController.rescue)
router.post('/delete/:id', serviceController.delete)

module.exports = router;