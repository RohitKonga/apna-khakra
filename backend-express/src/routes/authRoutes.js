const express = require('express');
const router = express.Router();
const authController = require('../controllers/authController');

// User registration
router.post('/register', authController.register);

// Login for both admin and user
router.post('/login', authController.login);

module.exports = router;

