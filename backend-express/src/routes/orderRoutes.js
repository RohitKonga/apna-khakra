const express = require('express');
const router = express.Router();
const orderController = require('../controllers/orderController');
const authMiddleware = require('../middlewares/auth');

// Public route
router.post('/', orderController.createOrder);

// Admin routes (protected)
router.get('/', authMiddleware, orderController.getAllOrders);
router.get('/:id', authMiddleware, orderController.getOrderById);
router.patch('/:id', authMiddleware, orderController.updateOrderStatus);

module.exports = router;

