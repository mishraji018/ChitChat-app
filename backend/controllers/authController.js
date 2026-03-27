const User = require('../models/User');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const nodemailer = require('nodemailer');

const generateToken = (id) =>
  jwt.sign({ id }, process.env.JWT_SECRET, { expiresIn: '30d' });

const generateOtp = () => Math.floor(100000 + Math.random() * 900000).toString();

const transporter = nodemailer.createTransport({
  service: 'gmail',
  auth: { user: process.env.EMAIL_USER, pass: process.env.EMAIL_PASS },
});

// @route POST /api/auth/signup
exports.signup = async (req, res) => {
  try {
    const { name, email, phone, password } = req.body;
    if (!name || !email || !phone || !password)
      return res.status(400).json({ success: false, message: 'All fields required' });

    const existing = await User.findOne({ $or: [{ email }, { phone }] });
    if (existing)
      return res.status(409).json({ success: false, message: 'Email or phone already registered' });

    const otp = generateOtp();
    const otpExpiry = new Date(Date.now() + 10 * 60 * 1000);
    const hashedPassword = await bcrypt.hash(password, 12);

    const user = await User.create({
      name,
      email,
      phone,
      password: hashedPassword,
      otp,
      otpExpiry,
      isVerified: false,
    });

    await transporter.sendMail({
      from: `ChitChat 🐻 <${process.env.EMAIL_USER}>`,
      to: email,
      subject: 'Your ChitChat OTP',
      html: `<h2>Your OTP is: <b>${otp}</b></h2><p>Valid for 10 minutes.</p>`,
    });

    res.status(201).json({
      success: true,
      message: 'OTP sent to your email',
      userId: user._id,
    });
  } catch (error) {
    console.error('signup:', error);
    res.status(500).json({ success: false, message: 'Server error' });
  }
};

// @route POST /api/auth/verify-otp
exports.verifyOtp = async (req, res) => {
  try {
    const { userId, otp } = req.body;
    if (!userId || !otp)
      return res.status(400).json({ success: false, message: 'userId and otp required' });

    const user = await User.findById(userId);
    if (!user) return res.status(404).json({ success: false, message: 'User not found' });

    if (user.otp !== otp)
      return res.status(400).json({ success: false, message: 'Invalid OTP' });

    if (new Date() > user.otpExpiry)
      return res.status(400).json({ success: false, message: 'OTP expired' });

    user.isVerified = true;
    user.otp = undefined;
    user.otpExpiry = undefined;
    await user.save();

    const token = generateToken(user._id);

    res.json({
      success: true,
      token,
      user: {
        id: user._id,
        name: user.name,
        email: user.email,
        phone: user.phone,
        profilePhoto: user.profilePhoto || '',
        about: user.about || 'Hey there! I am using ChitChat.',
      },
    });
  } catch (error) {
    console.error('verifyOtp:', error);
    res.status(500).json({ success: false, message: 'Server error' });
  }
};

// @route POST /api/auth/login
exports.login = async (req, res) => {
  try {
    const { email, password } = req.body;
    if (!email || !password)
      return res.status(400).json({ success: false, message: 'Email and password required' });

    const user = await User.findOne({ email }).select('+password');
    if (!user)
      return res.status(401).json({ success: false, message: 'Invalid credentials' });

    if (!user.isVerified)
      return res.status(403).json({ success: false, message: 'Email not verified', userId: user._id });

    const match = await bcrypt.compare(password, user.password);
    if (!match)
      return res.status(401).json({ success: false, message: 'Invalid credentials' });

    const token = generateToken(user._id);

    res.json({
      success: true,
      token,
      user: {
        id: user._id,
        name: user.name,
        email: user.email,
        phone: user.phone,
        profilePhoto: user.profilePhoto || '',
        about: user.about || 'Hey there! I am using ChitChat.',
      },
    });
  } catch (error) {
    console.error('login:', error);
    res.status(500).json({ success: false, message: 'Server error' });
  }
};

// @route POST /api/auth/resend-otp
exports.resendOtp = async (req, res) => {
  try {
    const { userId } = req.body;
    if (!userId) return res.status(400).json({ success: false, message: 'userId required' });

    const user = await User.findById(userId);
    if (!user) return res.status(404).json({ success: false, message: 'User not found' });

    const otp = generateOtp();
    user.otp = otp;
    user.otpExpiry = new Date(Date.now() + 10 * 60 * 1000);
    await user.save();

    await transporter.sendMail({
      from: `ChitChat 🐻 <${process.env.EMAIL_USER}>`,
      to: user.email,
      subject: 'ChitChat — New OTP',
      html: `<h2>Your new OTP: <b>${otp}</b></h2><p>Valid for 10 minutes.</p>`,
    });

    res.json({ success: true, message: 'OTP resent' });
  } catch (error) {
    console.error('resendOtp:', error);
    res.status(500).json({ success: false, message: 'Server error' });
  }
};

// @route POST /api/auth/logout
exports.logout = async (req, res) => {
  res.json({ success: true, message: 'Logged out' });
};
