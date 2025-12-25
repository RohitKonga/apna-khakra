const Product = require('../models/Product');

// Get all products
exports.getAllProducts = async (req, res) => {
  try {
    const products = await Product.find().sort({ createdAt: -1 });
    res.json(products);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

// Get single product
exports.getProductById = async (req, res) => {
  try {
    const product = await Product.findById(req.params.id);
    if (!product) {
      return res.status(404).json({ error: 'Product not found' });
    }
    res.json(product);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

// Create product (Admin only)
exports.createProduct = async (req, res) => {
  try {
    const { name, slug, description, actualPrice, marginPrice, stockQuantity, images } = req.body;
    
    if (!name || !slug) {
      return res.status(400).json({ error: 'Name and slug are required' });
    }

    // Calculate price from actualPrice + marginPrice
    const actualPriceNum = actualPrice !== undefined ? Number(actualPrice) : 0;
    const marginPriceNum = marginPrice !== undefined ? Number(marginPrice) : 0;
    const calculatedPrice = actualPriceNum + marginPriceNum;

    const product = await Product.create({
      name,
      slug,
      description: description || '',
      price: calculatedPrice, // Price is calculated from actualPrice + marginPrice
      actualPrice: actualPriceNum,
      marginPrice: marginPriceNum,
      stockQuantity: stockQuantity !== undefined ? Number(stockQuantity) : 0,
      images: images || []
    });

    res.status(201).json(product);
  } catch (error) {
    if (error.code === 11000) {
      return res.status(400).json({ error: 'Product with this slug already exists' });
    }
    res.status(500).json({ error: error.message });
  }
};

// Update product (Admin only)
exports.updateProduct = async (req, res) => {
  try {
    const { name, slug, description, actualPrice, marginPrice, stockQuantity, images } = req.body;
    
    const product = await Product.findById(req.params.id);
    if (!product) {
      return res.status(404).json({ error: 'Product not found' });
    }

    if (name) product.name = name;
    if (slug) product.slug = slug;
    if (description !== undefined) product.description = description;
    if (actualPrice !== undefined) product.actualPrice = Number(actualPrice);
    if (marginPrice !== undefined) product.marginPrice = Number(marginPrice);
    if (stockQuantity !== undefined) product.stockQuantity = Number(stockQuantity);
    if (images !== undefined) product.images = images;

    // Recalculate price from actualPrice + marginPrice
    const actualPriceNum = product.actualPrice || 0;
    const marginPriceNum = product.marginPrice || 0;
    product.price = actualPriceNum + marginPriceNum;

    await product.save();
    res.json(product);
  } catch (error) {
    if (error.code === 11000) {
      return res.status(400).json({ error: 'Product with this slug already exists' });
    }
    res.status(500).json({ error: error.message });
  }
};

// Delete product (Admin only)
exports.deleteProduct = async (req, res) => {
  try {
    const product = await Product.findByIdAndDelete(req.params.id);
    if (!product) {
      return res.status(404).json({ error: 'Product not found' });
    }
    res.json({ message: 'Product deleted successfully' });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

