const {default: mongoose} = require('mongoose')
const Schema = mongoose.Schema


const bannerSchema = new Schema({
     hinh_anh: {
        type: String,
        required: true
     },
     link: {
        type: String,
        required: true
     },
     mo_ta: {
        type: String,
        required: true
     }
}, { timestamps: true });

module.exports = mongoose.model('Banner', bannerSchema);
