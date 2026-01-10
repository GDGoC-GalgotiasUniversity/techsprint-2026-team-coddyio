require('dotenv').config();
const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(express.json());

// MongoDB Connection
mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/iot_sensors')
  .then(() => console.log('MongoDB connected'))
  .catch(err => console.error('MongoDB connection error:', err));

// Sensor Data Schema
const sensorSchema = new mongoose.Schema({
  temperature: { type: Number, required: true },
  humidity: { type: Number, required: true },
  soil_raw: { type: Number, required: true },
  soil_pct: { type: Number, required: true },
  timestamp: { type: Date, default: Date.now }
});

const SensorData = mongoose.model('SensorData', sensorSchema);

// Routes

// POST endpoint for NodeMCU to send data
app.post('/api/ingest', async (req, res) => {
  console.log(`[${new Date().toISOString()}] POST /api/ingest from ${req.ip}`);
  console.log('Body:', req.body);
  try {
    const { temperature, humidity, soil_raw, soil_pct } = req.body;
    
    // Delete all existing data and insert new one (keep only latest)
    await SensorData.deleteMany({});
    
    const sensorData = new SensorData({
      temperature,
      humidity,
      soil_raw,
      soil_pct
    });
    
    await sensorData.save();
    res.status(201).json({ success: true, message: 'Data replaced', id: sensorData._id });
  } catch (error) {
    console.error('Error saving data:', error);
    res.status(500).json({ success: false, error: error.message });
  }
});

// GET latest sensor reading
app.get('/api/latest', async (req, res) => {
  try {
    const latest = await SensorData.findOne().sort({ timestamp: -1 });
    res.json(latest || {});
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// GET all readings with pagination
app.get('/api/readings', async (req, res) => {
  try {
    const limit = parseInt(req.query.limit) || 100;
    const skip = parseInt(req.query.skip) || 0;
    
    const readings = await SensorData.find()
      .sort({ timestamp: -1 })
      .limit(limit)
      .skip(skip);
    
    const total = await SensorData.countDocuments();
    
    res.json({ readings, total, limit, skip });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// GET readings within time range
app.get('/api/readings/range', async (req, res) => {
  try {
    const { start, end } = req.query;
    const query = {};
    
    if (start || end) {
      query.timestamp = {};
      if (start) query.timestamp.$gte = new Date(start);
      if (end) query.timestamp.$lte = new Date(end);
    }
    
    const readings = await SensorData.find(query).sort({ timestamp: -1 });
    res.json(readings);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Health check
app.get('/health', (req, res) => {
  res.json({ status: 'ok', timestamp: new Date() });
});

app.listen(PORT, '0.0.0.0', () => {
  console.log(`Server running on port ${PORT}`);
  console.log(`Accepting connections from all network interfaces`);
});
