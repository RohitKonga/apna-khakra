require('dotenv').config();
const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');
const Product = require('../models/Product');
const Admin = require('../models/Admin');

const seedData = async () => {
  try {
    // Connect to MongoDB
    await mongoose.connect(process.env.MONGODB_URI);
    console.log('Connected to MongoDB');

    // Clear existing data (optional - comment out if you want to keep existing data)
    await Product.deleteMany({});
    await Admin.deleteMany({});
    console.log('Cleared existing data');

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
    console.log('Created seed product:', product.name);

    // Create admin user
    const adminPassword = process.env.ADMIN_PASSWORD || 'admin123';
    const passwordHash = await bcrypt.hash(adminPassword, 10);
    
    const admin = await Admin.create({
      email: 'admin@apnakhakra.com',
      passwordHash
    });
    console.log('Created admin user:', admin.email);
    console.log('Admin password:', adminPassword);

    console.log('\n✅ Seed data created successfully!');
    console.log('You can now login with:');
    console.log('Email: admin@apnakhakra.com');
    console.log('Password:', adminPassword);
    
    process.exit(0);
  } catch (error) {
    console.error('Error seeding data:', error);
    process.exit(1);
  }
};

seedData();

