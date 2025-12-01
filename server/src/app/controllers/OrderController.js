const Order = require("../models/Order")
const Product = require("../models/Product")
const Cart = require("../models/Cart")
class OrderController{
    async showAll(req, res){
        try {
            const orders = await Order.find().sort({createdAt: -1});
            return res.status(200).json(orders);
        } catch (err) {
            console.log("Get Orders Error:", err);
            return res.status(500).json({ success: false, message: "Lỗi server." });
        }
    }

    async create(req, res){
        try {
            const {items, payment_method, shipping_address } = req.body;
            const user_id = req.user.id
            console.log(items)
            if (!items || items.length === 0) {
                return res.status(400).json({ success: false, message: "Không có sản phẩm nào trong đơn hàng." });
            }

            let total_price = 0;

            for (const item of items) {
                const product = await Product.findById(item.product_id);

                if (!product) {
                    return res.status(404).json({ success: false, message: "Sản phẩm không tồn tại." });
                }

                total_price += item.price * item.quantity;

                item.price = product.price;
            }

            const newOrder = await Order.create({
                user_id,
                items,
                total_price,
                payment_method,
                shipping_address
            });
            const productIds = items.map(item => item.product_id);
            const cart = await Cart.findOne({ user_id });

            if (cart) {

                cart.cart_items = cart.cart_items.filter(
                    ci => !productIds.includes(ci.product_id.toString())
                );

                cart.total_price = cart.cart_items.reduce(
                    (sum, item) => sum + item.price * item.quantity,
                    0
                );

                await cart.save();
            }

            return res.status(201).json({
                success: true,
                message: "Tạo đơn hàng thành công!",
                order: newOrder
            });

        } catch (err) {
            console.log("Order Error:", err);
            return res.status(500).json({ success: false, message: "Lỗi server." });
        }
        
    }
    

};
module.exports = new OrderController()
