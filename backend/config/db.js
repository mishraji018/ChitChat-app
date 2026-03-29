const mongoose = require('mongoose');

const connectDB = async () => {
  try {
    const conn = await mongoose.connect(process.env.MONGODB_URI, {
      useNewUrlParser: true,
      useUnifiedTopology: true,
      serverSelectionTimeoutMS: 5000, // Fail fast in dev
    });

    console.log(`✅ MongoDB Connected: ${conn.connection.host}`);
  } catch (error) {
    console.error(`❌ MongoDB Connection Error: ${error.message}`);
    console.warn(`⚠️  Server running WITHOUT database. Set MONGODB_URI in .env to connect.`);
    // Do not exit — allows server to run in dev without MongoDB
    // process.exit(1);
  }
};

module.exports = connectDB;
