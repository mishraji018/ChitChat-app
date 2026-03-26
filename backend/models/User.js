const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');

const UserSchema = new mongoose.Schema({
  name: {
    type: String,
    required: [true, 'Please add a name'],
  },
  phone: {
    type: String,
    required: [true, 'Please add a phone number'],
    unique: true,
  },
  email: {
    type: String,
    match: [/^\w+([\.-]?\w+)*@\w+([\.-]?\w+)*(\.\w{2,3})+$/, 'Please add a valid email'],
  },
  avatar: {
    type: String,
    default: 'https://cdn-icons-png.flaticon.com/512/149/149071.png',
  },
  status: {
    type: String,
    default: 'Hey there! I am using ChitChat.',
  },
  isOnline: {
    type: Boolean,
    default: false,
  },
  lastSeen: {
    type: Date,
    default: Date.now,
  },
  settings: {
    type: Object,
    default: {}
  },
  about: {
    type: String,
    default: 'Hey there! I am using ChitChat.',
  },
  blockedUsers: [{
    type: mongoose.Schema.ObjectId,
    ref: 'User'
  }],
  mutedConversations: [{
    type: mongoose.Schema.ObjectId,
    ref: 'Conversation'
  }],
  pushToken: String,
  otp: String,
  otpExpire: Date,
  createdAt: {
    type: Date,
    default: Date.now,
  },
}, {
  toJSON: { virtuals: true },
  toObject: { virtuals: true },
});

// Encrypt OTP / Password if needed
UserSchema.pre('save', async function (next) {
  if (!this.isModified('otp')) {
    next();
  }
  const salt = await bcrypt.genSalt(10);
  this.otp = await bcrypt.hash(this.otp, salt);
});

// Sign JWT and return
UserSchema.methods.getSignedJwtToken = function () {
  return jwt.sign({ id: this._id }, process.env.JWT_SECRET, {
    expiresIn: process.env.JWT_EXPIRE,
  });
};

// Match user entered OTP to hashed OTP in database
UserSchema.methods.matchOtp = async function (enteredOtp) {
  return await bcrypt.compare(enteredOtp, this.otp);
};

module.exports = mongoose.model('User', UserSchema);
