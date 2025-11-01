const express = require('express');
const bannerCtrl = require('../app/controllers/banner.controller');
const router = express.Router();

router.get('/get', bannerCtrl.showAll);
router.post('/add', bannerCtrl.add);

module.exports = router;