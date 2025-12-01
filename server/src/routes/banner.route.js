const express = require('express');
const bannerCtrl = require('../app/controllers/banner.controller');
const router = express.Router();

router.get('/get', bannerCtrl.showAll);
router.post('/add', bannerCtrl.add);
router.patch('/update/:id', bannerCtrl.update);
router.delete('/delete/:id', bannerCtrl.delete);

module.exports = router;
