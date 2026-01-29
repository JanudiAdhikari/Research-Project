const express = require('express');
const { getProducts, createProduct, updateProduct } = require('../controllers/market.controller');
const verifyToken = require('../middleware/auth.middleware');

const router = express.Router();

router.get('/products', verifyToken, getProducts);
router.post('/products', verifyToken, createProduct);
router.put('/products/:id', verifyToken, updateProduct);

module.exports = router;
