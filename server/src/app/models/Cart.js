const mongoose = require("mongoose");

const CartItem = new mongoose.Schema({
    product_id: {
        type: mongoose.Schema.Types.ObjectId,
        ref: "Product",
        required: true
    },

    quantity: {
        type: Number,
        min: 1,
        default: 1,
    },

    price: {
        type: Number,
        required: true
    }
}, {
    _id: false
});

const Cart = new mongoose.Schema({
    user_id: {
        type: mongoose.Schema.Types.ObjectId,
        ref: "User",
        required: true,
        unique: true         
    },

    cart_items: [CartItem],

    total_price: {
        type: Number,
        default: 0
    }

}, {
    timestamps: true
});

module.exports = mongoose.model("Cart", Cart);
