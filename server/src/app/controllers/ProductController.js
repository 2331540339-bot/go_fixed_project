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
        .then((product) => res.status(200).json(product))
        .catch((err) => res.status(400).json({'error': err.message}))
    }
};
module.exports = new ProductController()