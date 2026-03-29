const User = require('../models/User');

// @desc    Search users by phone or name
// @route   GET /api/users/search
// @access  Private
exports.searchUsers = async (req, res, next) => {
  try {
    const { query } = req.query;

    const users = await User.find({
      $and: [
        { _id: { $ne: req.user.id } }, // Exclude self
        {
          $or: [
            { name: { $regex: query, $options: 'i' } },
            { phone: { $regex: query, $options: 'i' } }
          ]
        }
      ]
    }).select('name phone avatar status isOnline lastSeen');

    res.status(200).json({
      success: true,
      message: `Found ${users.length} users`,
      data: users
    });
  } catch (err) {
    next(err);
  }
};

// @desc    Get user by ID
// @route   GET /api/users/:id
// @access  Private
exports.getUserById = async (req, res, next) => {
  try {
    const user = await User.findById(req.params.id).select('name phone avatar status isOnline lastSeen about');

    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'User not found',
        data: null
      });
    }

    res.status(200).json({
      success: true,
      message: 'User retrieved',
      data: user
    });
  } catch (err) {
    next(err);
  }
};

// @desc    Sync contacts
// @route   POST /api/users/sync
// @access  Private
exports.syncContacts = async (req, res, next) => {
  try {
    const { phones } = req.body; // Array of phone numbers from device

    const users = await User.find({
      phone: { $in: phones },
      _id: { $ne: req.user.id }
    }).select('name phone avatar status isOnline lastSeen');

    res.status(200).json({
      success: true,
      message: 'Contacts synced',
      data: users
    });
  } catch (err) {
    next(err);
  }
};

// @desc    Update user settings
// @route   PUT /api/users/settings
// @access  Private
exports.updateSettings = async (req, res, next) => {
  try {
    const user = await User.findByIdAndUpdate(
      req.user.id,
      { $set: { settings: req.body } },
      { new: true, runValidators: true }
    );

    res.status(200).json({
      success: true,
      message: 'Settings updated successfully',
      data: user.settings
    });
  } catch (err) {
    next(err);
  }
};

// @desc    Block user
// @route   PUT /api/users/block/:id
// @access  Private
exports.blockUser = async (req, res, next) => {
  try {
    await User.findByIdAndUpdate(req.user.id, {
      $addToSet: { blockedUsers: req.params.id }
    });

    res.status(200).json({ success: true, message: 'User blocked' });
  } catch (err) {
    next(err);
  }
};

// @desc    Unblock user
// @route   PUT /api/users/unblock/:id
// @access  Private
exports.unblockUser = async (req, res, next) => {
  try {
    await User.findByIdAndUpdate(req.user.id, {
      $pull: { blockedUsers: req.params.id }
    });

    res.status(200).json({ success: true, message: 'User unblocked' });
  } catch (err) {
    next(err);
  }
};

// @desc    Mute conversation
// @route   PUT /api/users/mute/:id
// @access  Private
exports.muteConversation = async (req, res, next) => {
  try {
    await User.findByIdAndUpdate(req.user.id, {
      $addToSet: { mutedConversations: req.params.id }
    });

    res.status(200).json({ success: true, message: 'Conversation muted' });
  } catch (err) {
    next(err);
  }
};

// @desc    Unmute conversation
// @route   PUT /api/users/unmute/:id
// @access  Private
exports.unmuteConversation = async (req, res, next) => {
  try {
    await User.findByIdAndUpdate(req.user.id, {
      $pull: { mutedConversations: req.params.id }
    });

    res.status(200).json({ success: true, message: 'Conversation unmuted' });
  } catch (err) {
    next(err);
  }
};

// @desc    Add a new contact
// @route   POST /api/users/contacts
// @access  Private
exports.addContact = async (req, res, next) => {
  try {
    const { name, phone, avatar } = req.body;

    if (!name || !phone) {
      return res.status(400).json({
        success: false,
        message: 'Name and phone number are required'
      });
    }

    // Find if the contact already exists on ChitChat
    const existingUser = await User.findOne({ phone: phone.replaceAll(' ', '') });

    const newContact = {
      name,
      phone,
      avatar,
      user: existingUser ? existingUser._id : null
    };

    // Add to contacts array (avoid duplicates if phone is same)
    const user = await User.findById(req.user.id);
    const alreadyExists = user.contacts.find(c => c.phone === phone);
    
    if (alreadyExists) {
      return res.status(400).json({
        success: false,
        message: 'Contact with this phone number already exists'
      });
    }

    user.contacts.push(newContact);
    await user.save();

    res.status(201).json({
      success: true,
      message: 'Contact added successfully',
      data: newContact
    });
  } catch (err) {
    next(err);
  }
};

// @desc    Get blocked users
// @route   GET /api/users/blocked
// @access  Private
exports.getBlockedUsers = async (req, res, next) => {
  try {
    const user = await User.findById(req.user.id).populate('blockedUsers', 'name phone avatar status isOnline lastSeen');
    
    res.status(200).json({
      success: true,
      data: user.blockedUsers
    });
  } catch (err) {
    next(err);
  }
};
