const MarketProduct = require('../models/market.model');

// GET /api/market/products
const getProducts = async (req, res) => {
  try {
    const products = await MarketProduct.find().lean().exec();
    return res.json(products);
  } catch (err) {
    console.error('getProducts error:', err);
    return res.status(500).json({ message: 'Server error', error: err.message });
  }
};

// POST /api/market/products
const createProduct = async (req, res) => {
  try {
    const uid = req.user?.uid;
    const { name, price, unit } = req.body;
    if (!name) return res.status(400).json({ message: 'Name is required' });

    const prod = new MarketProduct({ name, price: price || 0, unit: unit || 'unit', vendorUid: uid });
    await prod.save();
    return res.status(201).json(prod);
  } catch (err) {
    console.error('createProduct error:', err);
    return res.status(500).json({ message: 'Server error', error: err.message });
  }
};

// PUT /api/market/products/:id
const updateProduct = async (req, res) => {
  try {
    const { id } = req.params;
    const { name, price, unit } = req.body;
    const prod = await MarketProduct.findById(id).exec();
    if (!prod) return res.status(404).json({ message: 'Product not found' });

    if (name !== undefined) prod.name = name;
    if (price !== undefined) prod.price = price;
    if (unit !== undefined) prod.unit = unit;

    await prod.save();
    return res.json(prod);
  } catch (err) {
    console.error('updateProduct error:', err);
    return res.status(500).json({ message: 'Server error', error: err.message });
  }
};

module.exports = { getProducts, createProduct, updateProduct };
