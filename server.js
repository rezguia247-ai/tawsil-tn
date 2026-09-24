const express = require('express');
const cors = require('cors');

const app = express();
app.use(cors());
app.use(express.json());

const stores = [
  { id: 1, name: 'Tunis Burger', category: 'Fast Food' },
  { id: 2, name: 'Pizza Carthage', category: 'Pizza' }
];

const products = [
  { id: 1, storeId: 1, name: 'Burger Classic', price: 12.5 },
  { id: 2, storeId: 1, name: 'Fries', price: 4.0 },
  { id: 3, storeId: 2, name: 'Pizza Margherita', price: 15.0 }
];

const orders = [];

app.get('/api/stores', (_, res) => res.json(stores));

app.get('/api/stores/:id/products', (req, res) => {
  const id = Number(req.params.id);
  res.json(products.filter(p => p.storeId === id));
});

app.post('/api/orders', (req, res) => {
  const order = {
    id: orders.length + 1,
    customerId: req.body.customerId || 1,
    items: req.body.items || [],
    address: req.body.address || '',
    status: 'pending',
    createdAt: new Date().toISOString()
  };
  orders.push(order);
  res.status(201).json(order);
});

app.get('/api/orders/:id', (req, res) => {
  const order = orders.find(o => o.id === Number(req.params.id));
  if (!order) return res.status(404).json({ message: 'Order not found' });
  res.json(order);
});

app.listen(3000, () => {
  console.log('Tawsil TN API running on http://localhost:3000');
});
