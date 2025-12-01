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
        .then((catalog) => {
            if(!catalog){
                return res.status(404).json({error: 'Catalog not found'});
            }
            return res.status(200).json(catalog);
        })
        .catch((err) => res.status(400).json({'error': err.message}))
    }

    async create(req, res){
        try {
            const { catalog_name, image } = req.body;
            if(!catalog_name){
                return res.status(400).json({error: 'Tên catalog là bắt buộc'});
            }
            const newCatalog = await Catalog.create({ catalog_name, image });
            return res.status(201).json({message: 'Tạo catalog thành công', catalog: newCatalog});
        } catch (err) {
            return res.status(500).json({error: err.message});
        }
    }

    async update(req, res){
        try {
            const { catalog_name, image } = req.body;
            const updatedCatalog = await Catalog.findByIdAndUpdate(
                req.params.id,
                { catalog_name, image },
                { new: true, runValidators: true }
            );
            if(!updatedCatalog){
                return res.status(404).json({error: 'Catalog not found'});
            }
            return res.status(200).json({message: 'Cập nhật catalog thành công', catalog: updatedCatalog});
        } catch (err) {
            return res.status(500).json({error: err.message});
        }
    }

    async delete(req, res){
        try {
            const deletedCatalog = await Catalog.findByIdAndDelete(req.params.id);
            if(!deletedCatalog){
                return res.status(404).json({error: 'Catalog not found'});
            }
            return res.status(200).json({message: 'Xoá catalog thành công', catalog: deletedCatalog});
        } catch (err) {
            return res.status(500).json({error: err.message});
        }
    }
};
module.exports = new CatalogController();
