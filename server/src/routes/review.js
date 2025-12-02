const express = require('express')
const router = express.Router()

const ReviewController = require('../app/controllers/Review.Controller')
const upload = require('../app/controllers/MiddlewaresUpload')

router.post("/add", upload.array("images", 5) ,ReviewController.addReview)
router.get("/product/:product_id", ReviewController.getReviewsByProduct);

module.exports = router;