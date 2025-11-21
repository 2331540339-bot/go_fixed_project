const mongoose = require("mongoose");

const OrderItem = new mongoose.Schema({
    product_id: {
        type: mongoose.Schema.Types.ObjectId,
        ref: "Product",
        required: true
    },
    quantity: {
        type: Number,
        required: true,
        min: 1
    },
    price: {
        type: Number,
        required: true
    }
});

const Order = new mongoose.Schema(
    {
        user_id: {
            type: mongoose.Schema.Types.ObjectId,
            ref: "User",
            required: true
        },

        items: [OrderItem],

        total_price: {
            type: Number,
            required: true
        },

        payment_method: {
            type: String,
            enum: ["cod", "banking", "momo"],
            default: "cod"
        },

        shipping_address: {
            type: String,
            required: true
        },

        status: {
            type: String,
            enum: ["pending", "paid", "shipping", "completed", "canceled"],
            default: "pending"
        }
    },
    {
        timestamps: true
    }
);

module.exports = mongoose.model("Order", Order);
