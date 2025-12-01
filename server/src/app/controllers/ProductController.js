const Product = require("../models/Product")

class ProductController{
    showall(req, res){
        Product.find()
        .then((products) => res.status(200).json(products))
        .catch((err) => res.status(400).json({'error': err.message}))
    }
    
    detail(req, res){
        console.log(req.params.id);
        Product.findById(req.params.id)
        .then((product) => {
            if (!product) {
                return res.status(404).json({ error: 'Sản phẩm không tồn tại' });
            }
            return res.status(200).json(product);
        })
        .catch((err) => res.status(400).json({'error': err.message}))
    }
    async create(req, res){
        try {
            const { product_name, image, price, catalog_id, quantity, description } = req.body;
            if (!product_name || price === undefined || !catalog_id || quantity === undefined) {
                return res.status(400).json({ error: 'Thiếu thông tin bắt buộc' });
            }

            const newProduct = await Product.create({
                product_name,
                image,
                price,
                catalog_id,
                quantity,
                description
            });

            return res.status(201).json({ message: 'Tạo sản phẩm thành công', product: newProduct });
        } catch (err) {
            return res.status(500).json({ error: err.message });
        }
    }

    async update(req, res){
        try {
            const { id } = req.params;
            const updates = req.body;
            const updatedProduct = await Product.findByIdAndUpdate(
                id,
                updates,
                { new: true, runValidators: true }
            );

            if (!updatedProduct) {
                return res.status(404).json({ error: 'Sản phẩm không tồn tại' });
            }

            return res.status(200).json({ message: 'Cập nhật sản phẩm thành công', product: updatedProduct });
        } catch (err) {
            return res.status(500).json({ error: err.message });
        }
    }

    async delete(req, res){
        try {
            const { id } = req.params;
            const deletedProduct = await Product.findByIdAndDelete(id);

            if (!deletedProduct) {
                return res.status(404).json({ error: 'Sản phẩm không tồn tại' });
            }

            return res.status(200).json({ message: 'Xóa sản phẩm thành công', product: deletedProduct });
        } catch (err) {
            return res.status(500).json({ error: err.message });
        }
    }
};
module.exports = new ProductController()
