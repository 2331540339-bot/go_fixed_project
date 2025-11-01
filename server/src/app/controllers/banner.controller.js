const Banner = require('../models/banner.model');

class BannerController {
    //GET - /banner/get
    async showAll(req, res) {
        try {
            const banners = await Banner.find();
            res.status(200).json(banners);
        } catch (error) {
            res.status(500).json({ message: 'Lỗi server' });
        }
    }

    //POST - /banner/add
    async add(req, res) {
        try {
            const { hinh_anh, link, mo_ta } = req.body;
            const newBanner = new Banner({
                hinh_anh,
                link,
                mo_ta
            });
            const savedBanner = await newBanner.save();
            res.status(201).json(savedBanner);
        } catch (error) {
            console.error(error);
            res.status(500).json({ message: 'Lỗi khi tạo banner' });
        }
    }
    
}

module.exports = new BannerController();     