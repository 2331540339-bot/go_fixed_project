const express = require('express');
const router = express.Router();
const catalogController = require('../app/controllers/CatalogController');
const productController = require('../app/controllers/ProductController');

router.get('/catalog/showall', catalogController.showall);
router.get('/catalog/detail/:id', catalogController.detail);

//---------------------------------------------------------//
router.get('/product/showall', productController.showall);
router.get('/product/detail/:id', productController.detail);

module.exports = router;