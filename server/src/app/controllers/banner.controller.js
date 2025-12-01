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

    //PATCH - /banner/update/:id
    async update(req, res) {
        try {
            const { hinh_anh, link, mo_ta } = req.body;
            const updatedBanner = await Banner.findByIdAndUpdate(
                req.params.id,
                { hinh_anh, link, mo_ta },
                { new: true, runValidators: true }
            );

            if (!updatedBanner) {
                return res.status(404).json({ message: 'Không tìm thấy banner' });
            }

            res.status(200).json(updatedBanner);
        } catch (error) {
            console.error(error);
            res.status(500).json({ message: 'Lỗi khi cập nhật banner' });
        }
    }

    //DELETE - /banner/delete/:id
    async delete(req, res) {
        try {
            const deletedBanner = await Banner.findByIdAndDelete(req.params.id);
            if (!deletedBanner) {
                return res.status(404).json({ message: 'Không tìm thấy banner' });
            }
            res.status(200).json({ message: 'Đã xoá banner', banner: deletedBanner });
        } catch (error) {
            console.error(error);
            res.status(500).json({ message: 'Lỗi khi xoá banner' });
        }
    }
}

module.exports = new BannerController();     
