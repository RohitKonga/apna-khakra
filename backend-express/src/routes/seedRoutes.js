const express = require('express');
const router = express.Router();
const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');
const Product = require('../models/Product');
const Admin = require('../models/Admin');

// TEMPORARY: One-time seed endpoint
// Remove this route after seeding production database for security
router.post('/seed', async (req, res) => {
  try {
    // Optional: Add a secret key check for security
    const { secret } = req.body;
    if (secret !== process.env.SEED_SECRET) {
      return res.status(401).json({ error: 'Unauthorized' });
    }

    // Clear existing data
    await Product.deleteMany({});
    await Admin.deleteMany({});

    // Create seed product
    const product = await Product.create({
      name: 'Premium Khakra',
      slug: 'premium-khakra',
      description: 'Crispy, delicious traditional khakra made with finest ingredients. Perfect for snacking anytime!',
      price: 299,
      images: [
        'https://images.unsplash.com/photo-1608198093002-ad4e81c0a457?w=800',
        'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=800'
      ]
    });

    // Create admin user
    const adminPassword = process.env.ADMIN_PASSWORD || 'admin123';
    const passwordHash = await bcrypt.hash(adminPassword, 10);
    
    const admin = await Admin.create({
      email: 'admin@apnakhakra.com',
      passwordHash
    });

    res.json({
      success: true,
      message: 'Database seeded successfully',
      admin: {
        email: admin.email,
        password: adminPassword
      }
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

module.exports = router;

