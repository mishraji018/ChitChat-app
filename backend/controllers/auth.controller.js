const User = require('../models/User');
const { generateOtp } = require('../utils/otp.utils');
const sendEmail = require('../utils/email.utils');

// @desc    Register user / Send OTP
// @route   POST /api/auth/register
// @access  Public
exports.register = async (req, res, next) => {
  try {
    const { name, phone, email } = req.body;

    let user = await User.findOne({ phone });

    const otp = generateOtp();
    const otpExpire = new Date(Date.now() + 10 * 60 * 1000); // 10 mins

    if (user) {
      user.otp = otp;
      user.otpExpire = otpExpire;
      if (name) user.name = name;
      if (email) user.email = email;
      await user.save();
    } else {
      user = await User.create({
        name,
        phone,
        email,
        otp,
        otpExpire,
      });
    }

    // In production, send via SMS/Email. For now, log to console.
    console.log(`OTP for ${phone}: ${otp}`);
    
    // Optionally send email if provided
    if (email) {
      await sendEmail({
        email,
        subject: 'ChitChat Verification Code',
        message: `Your verification code is: ${otp}`,
        html: `<h1>Welcome to ChitChat</h1><p>Your verification code is: <b>${otp}</b></p>`
      });
    }

    res.status(200).json({
      success: true,
      message: 'OTP sent successfully',
      data: { phone }
    });
  } catch (err) {
    next(err);
  }
};

// @desc    Verify OTP & Login
// @route   POST /api/auth/verify
// @access  Public
exports.verifyOtp = async (req, res, next) => {
  try {
    const { phone, otp } = req.body;

    const user = await User.findOne({ 
      phone,
      otpExpire: { $gt: Date.now() }
    });

    if (!user) {
      return res.status(400).json({
        success: false,
        message: 'Invalid or expired OTP',
        data: null
      });
    }

    const isMatch = await user.matchOtp(otp);

    if (!isMatch) {
      return res.status(400).json({
        success: false,
        message: 'Invalid OTP',
        data: null
      });
    }

    // Clear OTP after successful verification
    user.otp = undefined;
    user.otpExpire = undefined;
    user.isOnline = true;
    await user.save();

    const token = user.getSignedJwtToken();

    res.status(200).json({
      success: true,
      message: 'Logged in successfully',
      data: {
        token,
        user: {
          id: user._id,
          name: user.name,
          phone: user.phone,
          email: user.email,
          avatar: user.avatar,
          status: user.status
        }
      }
    });
  } catch (err) {
    next(err);
  }
};

// @desc    Get current user
// @route   GET /api/auth/me
// @access  Private
exports.getMe = async (req, res, next) => {
  try {
    const user = await User.findById(req.user.id);

    res.status(200).json({
      success: true,
      message: 'User data retrieved',
      data: user
    });
  } catch (err) {
    next(err);
  }
};

// @desc    Update profile
// @route   PUT /api/auth/profile
// @access  Private
exports.updateProfile = async (req, res, next) => {
  try {
    const fieldsToUpdate = {
      name: req.body.name,
      email: req.body.email,
      status: req.body.status,
      avatar: req.body.avatar,
      pushToken: req.body.pushToken
    };

    const user = await User.findByIdAndUpdate(req.user.id, fieldsToUpdate, {
      new: true,
      runValidators: true
    });

    res.status(200).json({
      success: true,
      message: 'Profile updated successfully',
      data: user
    });
  } catch (err) {
    next(err);
  }
};

// @desc    Logout
// @route   POST /api/auth/logout
// @access  Private
exports.logout = async (req, res, next) => {
  try {
    await User.findByIdAndUpdate(req.user.id, {
      isOnline: false,
      lastSeen: Date.now()
    });

    res.status(200).json({
      success: true,
      message: 'Logged out successfully',
      data: null
    });
  } catch (err) {
    next(err);
  }
};
