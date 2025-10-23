const mongoose = require('mongoose');

const ServiceSchema = new mongoose.Schema({
  name: {
    type: String,
    required: true,
    unique: true
  },
  base_price: {
    type: String,
    required: true,
  },
  icon_url: {
    type: String,
    required: false,
  },
  kind_services: {
    type: String,
    enum: ['simple_services', 'advance_services'], 
    default: 'simple_services',
  },
});

module.exports = mongoose.model('Service', ServiceSchema);
