const Admin = require('../models/Admin');
const User = require('../models/User');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');

// Register regular user
exports.register = async (req, res) => {
  try {
    const { name, email, password, phone } = req.body;

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
      passwordHash,
      phone: phone || ''
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

    if (role === 'user') {
      // Return user data
      res.json({ 
        token, 
        email: account.email, 
        name: account.name,
        phone: account.phone || '',
        address: account.address || '',
        role 
      });
    } else {
      // Admin login
      res.json({ token, email: account.email, role });
    }
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

// Forgot Password - Verify email and phone, then reset password
exports.forgotPassword = async (req, res) => {
  try {
    const { email, phone, newPassword } = req.body;

    if (!email || !phone || !newPassword) {
      return res.status(400).json({ error: 'Email, phone, and new password are required' });
    }

    if (newPassword.length < 6) {
      return res.status(400).json({ error: 'Password must be at least 6 characters' });
    }

    const lowerEmail = email.toLowerCase();
    // Normalize phone: remove spaces, dashes, and other non-digit characters (except +)
    const normalizedPhone = phone.trim().replace(/[\s\-\(\)]/g, '');

    // Find user with matching email
    const user = await User.findOne({ email: lowerEmail });

    if (!user) {
      return res.status(404).json({ 
        error: 'Email and phone number do not match any account' 
      });
    }

    // Normalize stored phone for comparison
    const storedPhoneNormalized = (user.phone || '').replace(/[\s\-\(\)]/g, '');

    // Verify phone number matches
    if (storedPhoneNormalized !== normalizedPhone) {
      return res.status(404).json({ 
        error: 'Email and phone number do not match any account' 
      });
    }

    if (!user) {
      return res.status(404).json({ 
        error: 'Email and phone number do not match any account' 
      });
    }

    // Update password
    const passwordHash = await bcrypt.hash(newPassword, 10);
    user.passwordHash = passwordHash;
    await user.save();

    return res.json({ 
      success: true, 
      message: 'Password reset successfully. You can now login with your new password.'
    });
  } catch (error) {
    console.error('Forgot password error:', error);
    res.status(500).json({ error: 'Failed to reset password. Please try again.' });
  }
};

