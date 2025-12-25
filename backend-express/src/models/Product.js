const mongoose = require('mongoose');

const productSchema = new mongoose.Schema({
  name: { type: String, required: true },
  slug: { type: String, required: true, unique: true },
  description: { type: String, default: '' },
  price: { type: Number, required: true, min: 0 },
  actualPrice: { type: Number, default: 0, min: 0 },
  marginPrice: { type: Number, default: 0, min: 0 },
  stockQuantity: { type: Number, default: 0, min: 0 },
  images: { type: [String], default: [] },
  createdAt: { type: Date, default: Date.now }
});

module.exports = mongoose.model('Product', productSchema);

