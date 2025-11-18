const Admin = require('../models/Admin');
const User = require('../models/User');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');

// Register regular user
exports.register = async (req, res) => {
  try {
    const { name, email, password } = req.body;

    if (!name || !email || !password) {
      return res.status(400).json({ error: 'Name, email and password are required' });
    }

    const existingAdmin = await Admin.findOne({ email: email.toLowerCase() });
    const existingUser = await User.findOne({ email: email.toLowerCase() });

    if (existingAdmin || existingUser) {
      return res.status(400).json({ error: 'Email is already in use' });
    }

    const passwordHash = await bcrypt.hash(password, 10);

    const user = await User.create({
      name,
      email: email.toLowerCase(),
      passwordHash
    });

    const token = jwt.sign(
      { id: user._id, email: user.email, role: 'user' },
      process.env.JWT_SECRET,
      { expiresIn: '12h' }
    );

    res.status(201).json({
      token,
      email: user.email,
      name: user.name,
      role: 'user'
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

// Login (admin or user)
exports.login = async (req, res) => {
  try {
    const { email, password } = req.body;
    
    if (!email || !password) {
      return res.status(400).json({ error: 'Email and password are required' });
    }

    const lowerEmail = email.toLowerCase();

    // Try admin first
    let account = await Admin.findOne({ email: lowerEmail });
    let role = 'admin';

    if (!account) {
      // Fallback to regular user
      account = await User.findOne({ email: lowerEmail });
      role = 'user';
    }

    if (!account) {
      return res.status(401).json({ error: 'Invalid credentials' });
    }

    const isPasswordValid = await bcrypt.compare(password, account.passwordHash);
    if (!isPasswordValid) {
      return res.status(401).json({ error: 'Invalid credentials' });
    }

    const token = jwt.sign(
      { id: account._id, email: account.email, role },
      process.env.JWT_SECRET,
      { expiresIn: '12h' }
    );

    res.json({ token, email: account.email, role });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

