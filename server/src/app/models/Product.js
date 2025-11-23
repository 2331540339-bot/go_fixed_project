const { default: mongoose } = require("mongoose");
const Schema = mongoose.Schema;

const Product = new Schema({
    product_name:{
        type: String,
        required: true
    },
    image:{
        type: [String],
        default: ["https://cdn-icons-png.flaticon.com/512/1170/1170577.png"]
    },
    price:{
        type: Number,
        required: true
    },
    catalog_id:{
        type: mongoose.Schema.Types.ObjectId,
        ref: 'Catalog',
        required: true
    },
    quantity:{
        type: Number,
        required: true
    },
    description:{
        type: String
    }
}, {
    timestamps: true
})
module.exports = new mongoose.model('Product', Product);