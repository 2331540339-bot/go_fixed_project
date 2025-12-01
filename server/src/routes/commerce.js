const express = require("express");
const router = express.Router();
const catalogController = require("../app/controllers/CatalogController");
const productController = require("../app/controllers/ProductController");
const middlewareController = require("../app/controllers/MiddlewareController");
router.get("/catalog/showall", catalogController.showall);
router.get("/catalog/detail/:id", catalogController.detail);
router.post(
  "/catalog/create",
  middlewareController.verifyTokenAndAdmin,
  catalogController.create
);
router.patch(
  "/catalog/update/:id",
  middlewareController.verifyTokenAndAdmin,
  catalogController.update
);
router.delete(
  "/catalog/delete/:id",
  middlewareController.verifyTokenAndAdmin,
  catalogController.delete
);

//---------------------------------------------------------//
router.get("/product/showall", productController.showall);
router.get("/product/detail/:id", productController.detail);
router.post(
  "/product/create",
  middlewareController.verifyTokenAndAdmin,
  productController.create
);
router.patch(
  "/product/update/:id",
  middlewareController.verifyTokenAndAdmin,
  productController.update
);
router.delete(
  "/product/delete/:id",
  middlewareController.verifyTokenAndAdmin,
  productController.delete
);

module.exports = router;
