const Catalog = require("../models/Catalog");

class CatalogController{
    showall(req, res){
            Catalog.find()
            .then((catalogs) => res.status(200).json(catalogs))
            .catch((err) => res.status(400).json({'error': err.message}))
    }

    detail(req, res){
        console.log(req.params.id);
        Catalog.findById(req.params.id)
        .then((catalog) => res.status(200).json(catalog))
        .catch((err) => res.status(400).json({'error': err.message}))
    }
};
module.exports = new CatalogController();