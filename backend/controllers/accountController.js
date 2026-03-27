const User = require('../models/User');
const bcrypt = require('bcryptjs');
const crypto = require('crypto');

// @desc  Get account info (email, phone)
// @route GET /api/account
exports.getAccount = async (req, res) => {
  try {
    const user = await User.findById(req.user.id).select('email phone passkeys createdAt');
    if (!user) return res.status(404).json({ success: false, message: 'User not found' });
    res.json({ success: true, account: user });
  } catch (error) {
    console.error('getAccount:', error);
    res.status(500).json({ success: false, message: 'Server error' });
  }
};

// ─────────────────────────────────────────
// PASSKEYS
// ─────────────────────────────────────────

// @desc  Get passkeys list
// @route GET /api/account/passkeys
exports.getPasskeys = async (req, res) => {
  try {
    const user = await User.findById(req.user.id).select('passkeys');
    res.json({ success: true, passkeys: user.passkeys || [] });
  } catch (error) {
    console.error('getPasskeys:', error);
    res.status(500).json({ success: false, message: 'Server error' });
  }
};

// @desc  Add a passkey
// @route POST /api/account/passkeys
exports.addPasskey = async (req, res) => {
  try {
    const { deviceName } = req.body;
    if (!deviceName) return res.status(400).json({ success: false, message: 'deviceName required' });

    const newKey = {
      id: crypto.randomUUID(),
      deviceName,
      createdAt: new Date(),
    };

    await User.findByIdAndUpdate(req.user.id, {
      $push: { passkeys: newKey },
    });

    res.json({ success: true, passkey: newKey });
  } catch (error) {
    console.error('addPasskey:', error);
    res.status(500).json({ success: false, message: 'Server error' });
  }
};

// @desc  Remove a passkey
// @route DELETE /api/account/passkeys/:passkeyId
exports.removePasskey = async (req, res) => {
  try {
    await User.findByIdAndUpdate(req.user.id, {
      $pull: { passkeys: { id: req.params.passkeyId } },
    });
    res.json({ success: true, message: 'Passkey removed' });
  } catch (error) {
    console.error('removePasskey:', error);
    res.status(500).json({ success: false, message: 'Server error' });
  }
};

// ─────────────────────────────────────────
// EMAIL ADDRESS
// ─────────────────────────────────────────

// @desc  Update email address
// @route PUT /api/account/email
exports.updateEmail = async (req, res) => {
  try {
    const { email } = req.body;
    if (!email) return res.status(400).json({ success: false, message: 'Email required' });

    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRegex.test(email))
      return res.status(400).json({ success: false, message: 'Invalid email format' });

    const existing = await User.findOne({ email, _id: { $ne: req.user.id } });
    if (existing)
      return res.status(409).json({ success: false, message: 'Email already in use' });

    const user = await User.findByIdAndUpdate(
      req.user.id,
      { email },
      { new: true }
    ).select('email');

    res.json({ success: true, email: user.email });
  } catch (error) {
    console.error('updateEmail:', error);
    res.status(500).json({ success: false, message: 'Server error' });
  }
};

// ─────────────────────────────────────────
// CHANGE PHONE NUMBER
// ─────────────────────────────────────────

// @desc  Request phone number change (sends OTP to new number)
// @route POST /api/account/change-phone
exports.requestPhoneChange = async (req, res) => {
  try {
    const { newPhone } = req.body;
    if (!newPhone) return res.status(400).json({ success: false, message: 'newPhone required' });

    const existing = await User.findOne({ phone: newPhone, _id: { $ne: req.user.id } });
    if (existing)
      return res.status(409).json({ success: false, message: 'Phone already registered' });

    // Generate OTP and save temporarily
    const otp = Math.floor(100000 + Math.random() * 900000).toString();
    const otpExpiry = new Date(Date.now() + 10 * 60 * 1000); // 10 min

    await User.findByIdAndUpdate(req.user.id, {
      pendingPhone: newPhone,
      phoneChangeOtp: otp,
      phoneChangeOtpExpiry: otpExpiry,
    });

    // TODO: Send OTP via SMS (Twilio / Firebase)
    console.log(`[DEV] Phone change OTP for ${newPhone}: ${otp}`);

    res.json({ success: true, message: 'OTP sent to new number' });
  } catch (error) {
    console.error('requestPhoneChange:', error);
    res.status(500).json({ success: false, message: 'Server error' });
  }
};

// @desc  Confirm phone number change with OTP
// @route PUT /api/account/change-phone/confirm
exports.confirmPhoneChange = async (req, res) => {
  try {
    const { otp } = req.body;
    if (!otp) return res.status(400).json({ success: false, message: 'OTP required' });

    const user = await User.findById(req.user.id).select(
      'pendingPhone phoneChangeOtp phoneChangeOtpExpiry'
    );

    if (!user.pendingPhone)
      return res.status(400).json({ success: false, message: 'No pending phone change' });

    if (user.phoneChangeOtp !== otp)
      return res.status(400).json({ success: false, message: 'Invalid OTP' });

    if (new Date() > user.phoneChangeOtpExpiry)
      return res.status(400).json({ success: false, message: 'OTP expired' });

    await User.findByIdAndUpdate(req.user.id, {
      phone: user.pendingPhone,
      $unset: { pendingPhone: 1, phoneChangeOtp: 1, phoneChangeOtpExpiry: 1 },
    });

    res.json({ success: true, message: 'Phone number updated successfully' });
  } catch (error) {
    console.error('confirmPhoneChange:', error);
    res.status(500).json({ success: false, message: 'Server error' });
  }
};

// ─────────────────────────────────────────
// DELETE ACCOUNT
// ─────────────────────────────────────────

// @desc  Delete account permanently
// @route DELETE /api/account
exports.deleteAccount = async (req, res) => {
  try {
    const { confirmText } = req.body;
    if (confirmText !== 'DELETE')
      return res.status(400).json({ success: false, message: 'Type DELETE to confirm' });

    await User.findByIdAndDelete(req.user.id);

    res.json({ success: true, message: 'Account deleted permanently' });
  } catch (error) {
    console.error('deleteAccount:', error);
    res.status(500).json({ success: false, message: 'Server error' });
  }
};
