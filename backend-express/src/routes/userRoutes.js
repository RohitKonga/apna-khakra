const express = require('express');
const router = express.Router();
const userController = require('../controllers/userController');
const userAuthMiddleware = require('../middlewares/userAuth');

// Protected routes - require authentication
router.get('/profile', userAuthMiddleware, userController.getProfile);
router.put('/profile', userAuthMiddleware, userController.updateProfile);

module.exports = router;

