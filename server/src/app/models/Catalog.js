const {default: mongoose} = require('mongoose');
const Schema = mongoose.Schema;

const Catalog = new Schema(
    {
        catalog_name:{
            type: String,
            required: true
        },
        image:{
            type: String,
            default: "https://www.redpepperdigital.net/wp-content/uploads/2025/05/Catalog-integration-icon.png"
        }
    },
    {
        timestamps: true
    }
);
module.exports = new mongoose.model("Catalog", Catalog);