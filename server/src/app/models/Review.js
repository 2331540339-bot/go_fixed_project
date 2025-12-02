const mongoose = require("mongoose")
const Schema = mongoose.Schema;

const ReviewSchema = new Schema(
    {
        product_id:{
            type: mongoose.Schema.Types.ObjectId,
            ref: "Product",
            required: true,
        },

        user_id: {
            type: mongoose.Schema.Types.ObjectId,
            ref: "User",
            required: true,
        },

        rating: {
            type: Number,
            min: 1,
            max: 5,
            required: true,
        },

        comment: {
            type: String,
            default: "",
        },

        images: {
            type: [String],
            default: [],
        },

        likes: {
            type: Number,
            default: 0,
        },   
    },
    { timestamps: true }
)

module.exports = mongoose.model("Review", ReviewSchema);