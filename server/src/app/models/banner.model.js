const {default: mongoose} = require('mongoose')
const Schema = mongoose.Schema


const BennerSchema = new Schema({
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

module.exports = mongoose.model('Benner', BennerSchema);
