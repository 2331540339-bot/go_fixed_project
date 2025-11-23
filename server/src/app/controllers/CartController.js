const Cart = require('../models/Cart')
const Product = require('../models/Product')
const mongoose = require("mongoose");
const calculateTotal = (cart_items) => {
    return cart_items.reduce((total, item) => {
        return total + item.price * item.quantity;
    }, 0);
};
class CartController{
    async get(req, res){
        try {

            let cart = await Cart.findOne({ user_id: new mongoose.Types.ObjectId(req.user.id) }).populate("cart_items.product_id");

            if (!cart) {
                return res.json({
                    success: true,
                    cart: { user_id, cart_items: [], total_price: 0 }
                });
            }

            return res.json({ success: true, cart });
        } catch (err) {
            console.log("Get Cart Error:", err);
            return res.status(500).json({ success: false, message: "Lỗi server." });
        }
    };

    async add(req, res){
        try {
            const { product_id, quantity } = req.body;
            console.log(req.user.id)
            const user_id = req.user.id
            const product = await Product.findById(product_id);
            if (!product) {
                return res.status(404).json({ success: false, message: "Sản phẩm không tồn tại." });
            }


            let cart = await Cart.findOne({ user_id });

            if (!cart) {
                cart = await Cart.create({
                    user_id,
                    cart_items: [{
                        product_id,
                        quantity,
                        price: product.price
                    }],
                    total_price: product.price * quantity
                });

                return res.json({ success: true, message: "Đã thêm vào giỏ hàng", cart });
            }

           
            const itemIndex = cart.cart_items.findIndex(item =>
                item.product_id.toString() === product_id
            );

            if (itemIndex > -1) {
                cart.cart_items[itemIndex].quantity += quantity;
            } else {
                cart.cart_items.push({
                    product_id,
                    quantity,
                    price: product.price
                });
            }

            cart.total_price = calculateTotal(cart.cart_items);

            await cart.save();

            return res.json({ success: true, message: "Đã thêm vào giỏ hàng", cart });
        } catch (err) {
            console.log("Add Cart Error:", err);
            return res.status(500).json({ success: false, message: "Lỗi server." });
        }
    };

    async updateQuantity (req, res){
        try {
            const {product_id, quantity } = req.body;
            const user_id = req.user.id;
            let cart = await Cart.findOne({ user_id });

            if (!cart) {
                return res.status(404).json({ success: false, message: "Giỏ hàng không tồn tại." });
            }

            const itemIndex = cart.cart_items.findIndex(
                (item) => item.product_id.toString() === product_id
            );

            if (itemIndex === -1) {
                return res.status(404).json({ success: false, message: "Sản phẩm không có trong giỏ." });
            }

            cart.cart_items[itemIndex].quantity = Math.max(1, quantity);

            cart.total_price = calculateTotal(cart.cart_items);

            await cart.save();

            return res.json({ success: true, message: "Cập nhật số lượng thành công", cart });
        } catch (err) {
            console.log("Update Cart Error:", err);
            return res.status(500).json({ success: false, message: "Lỗi server." });
        }
    
    };

    async removeItem  (req, res){
        try {
            console.log(req.body);
            const product_id= req.body.product_id;
            const user_id = req.user.id;
            let cart = await Cart.findOne({ user_id });

            if (!cart) {
                return res.status(404).json({ success: false, message: "Giỏ hàng không tồn tại." });
            }

            cart.cart_items = cart.cart_items.filter(
                (item) => item.product_id.toString() !== product_id
            );

            cart.total_price = calculateTotal(cart.cart_items);

            await cart.save();

            return res.json({ success: true, message: "Đã xoá sản phẩm", cart });
        } catch (err) {
            console.log("Remove Item Error:", err);
            return res.status(500).json({ success: false, message: "Lỗi server." });
        }
    };

};
module.exports = new CartController()