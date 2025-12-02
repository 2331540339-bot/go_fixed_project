const Review = require("../models/Review");
const Product = require("../models/Product");
const User = require("../models/User");
const cloudinary = require("../../config/cloudinary")

const uploadToCloudinary = (fileBuffer) => {
  return new Promise((resolve, reject) => {
    const stream = cloudinary.uploader.upload_stream(
      { folder: "reviews" },
      (error, result) => {
        if (error) reject(error);
        else resolve(result.secure_url);
      }
    );
    stream.end(fileBuffer);
  });
};

class ReviewController {
    //[POST] /review/add
    async addReview(req, res){
        try {
            const { product_id, user_id, rating, comment} = req.body;

            if (!product_id || !user_id || !rating) {
                return res.status(400).json({
                message: "product_id, user_id và rating là bắt buộc!",
                });
            }
            
            // Upload ảnh lên Cloudinary
            let images = [];

            if (req.files && req.files.length > 0) {
                for (let file of req.files) {
                const url = await uploadToCloudinary(file.buffer);
                images.push(url);
                }
            }

            // Kiểm tra product tồn tại
            const product = await Product.findById(product_id);
            if (!product) {
                return res.status(404).json({ message: "Sản phẩm không tồn tại" });
            }

            // Kiểm tra user tồn tại
            const user = await User.findById(user_id);
            if (!user) {
                return res.status(404).json({ message: "Người dùng không tồn tại" });
            }

            // Tạo review mới
            const newReview = await Review.create({
                product_id,
                user_id,
                rating,
                comment: comment || "",
                images: images || [],
            });
            
            return res.status(201).json({
                message: "Thêm review thành công!",
                review: newReview,
            });
        } catch (error) {
            console.error(error);
            return res.status(500).json({ message: "Lỗi server!" });
        }
    }

    //[GET] /review/product/:product_id
    async getReviewsByProduct(req, res) {
        try {
            const { product_id } = req.params;

            if (!product_id) {
                return res.status(400).json({ message: "Thiếu product_id" });
            }

            // Lấy toàn bộ review của sản phẩm
            const reviews = await Review.find({ product_id })
                .populate("user_id", "fullname avatar")
                .sort({ createdAt: -1 });
            
            // Tính tổng số review
            const totalReviews = reviews.length;

            // Tính rating trung bình
            const averageRating =
            totalReviews > 0
                ? reviews.reduce((sum, r) => sum + r.rating, 0) / totalReviews
                : 0;
            
            return res.status(200).json({
                message: "Lấy review thành công",
                reviews,
                totalReviews,
                averageRating: Number(averageRating.toFixed(1)),
            });
        } catch (error) {
            console.error(error);
            return res.status(500).json({ message: "Lỗi server", error: error.message });
        }
    }
}

module.exports = new ReviewController();