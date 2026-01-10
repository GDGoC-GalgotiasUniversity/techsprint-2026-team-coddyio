// Check if data is in MongoDB
const mongoose = require('mongoose');

mongoose.connect('mongodb://localhost:27017/iot_sensors')
  .then(async () => {
    console.log('Connected to MongoDB');
    
    const SensorData = mongoose.model('SensorData', new mongoose.Schema({
      temperature: Number,
      humidity: Number,
      soil_raw: Number,
      soil_pct: Number,
      timestamp: Date
    }));
    
    const count = await SensorData.countDocuments();
    console.log(`\nTotal records in database: ${count}`);
    
    if (count > 0) {
      const latest = await SensorData.findOne().sort({ timestamp: -1 });
      console.log('\nLatest record:');
      console.log('  Temperature:', latest.temperature, '°C');
      console.log('  Humidity:', latest.humidity, '%');
      console.log('  Soil Raw:', latest.soil_raw);
      console.log('  Soil %:', latest.soil_pct, '%');
      console.log('  Timestamp:', latest.timestamp);
      console.log('  ID:', latest._id);
    } else {
      console.log('\n⚠ No data in database yet!');
    }
    
    mongoose.connection.close();
  })
  .catch(err => {
    console.error('MongoDB connection error:', err.message);
    process.exit(1);
  });
