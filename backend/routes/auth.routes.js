const express = require('express');
const { 
  register, 
  verifyOtp, 
  getMe, 
  updateProfile, 
  logout 
} = require('../controllers/auth.controller');
const protect = require('../middleware/auth.middleware');
const apiLimiter = require('../middleware/rateLimit.middleware');

const router = express.Router();

router.post('/register', apiLimiter, register);
router.post('/verify', apiLimiter, verifyOtp);
router.get('/me', protect, getMe);
router.put('/profile', protect, updateProfile);
router.post('/logout', protect, logout);

module.exports = router;
