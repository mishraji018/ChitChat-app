const User = require('../models/User');

// @desc  Get privacy settings
// @route GET /api/privacy
exports.getPrivacySettings = async (req, res) => {
  try {
    const user = await User.findById(req.user.id)
      .select('privacySettings')
      .populate('privacySettings.blockedContacts', 'name phone profilePhoto');

    if (!user) return res.status(404).json({ success: false, message: 'User not found' });

    res.json({ success: true, privacySettings: user.privacySettings });
  } catch (error) {
    console.error('getPrivacySettings:', error);
    res.status(500).json({ success: false, message: 'Server error' });
  }
};

// @desc  Update privacy settings
// @route PUT /api/privacy
exports.updatePrivacySettings = async (req, res) => {
  try {
    const allowed = [
      'lastSeen', 'profilePhoto', 'about', 'status',
      'readReceipts', 'silenceUnknownCallers', 'defaultMessageTimer', 'appLock',
    ];

    const updates = {};
    allowed.forEach((field) => {
      if (req.body[field] !== undefined) updates[`privacySettings.${field}`] = req.body[field];
    });

    if (!Object.keys(updates).length)
      return res.status(400).json({ success: false, message: 'No valid fields provided' });

    const user = await User.findByIdAndUpdate(
      req.user.id,
      { $set: updates },
      { new: true, runValidators: true }
    )
      .select('privacySettings')
      .populate('privacySettings.blockedContacts', 'name phone profilePhoto');

    res.json({ success: true, privacySettings: user.privacySettings });
  } catch (error) {
    console.error('updatePrivacySettings:', error);
    res.status(500).json({ success: false, message: 'Server error' });
  }
};

// @desc  Get blocked contacts
// @route GET /api/privacy/blocked
exports.getBlockedContacts = async (req, res) => {
  try {
    const user = await User.findById(req.user.id)
      .select('privacySettings.blockedContacts')
      .populate('privacySettings.blockedContacts', 'name phone profilePhoto');

    res.json({ success: true, blockedContacts: user.privacySettings.blockedContacts });
  } catch (error) {
    console.error('getBlockedContacts:', error);
    res.status(500).json({ success: false, message: 'Server error' });
  }
};

// @desc  Block a contact
// @route POST /api/privacy/blocked
exports.blockContact = async (req, res) => {
  try {
    const { contactId } = req.body;
    if (!contactId) return res.status(400).json({ success: false, message: 'contactId required' });
    if (contactId === req.user.id.toString())
      return res.status(400).json({ success: false, message: 'Cannot block yourself' });

    await User.findByIdAndUpdate(req.user.id, {
      $addToSet: { 'privacySettings.blockedContacts': contactId },
    });

    res.json({ success: true, message: 'Contact blocked' });
  } catch (error) {
    console.error('blockContact:', error);
    res.status(500).json({ success: false, message: 'Server error' });
  }
};

// @desc  Unblock a contact
// @route DELETE /api/privacy/blocked/:contactId
exports.unblockContact = async (req, res) => {
  try {
    const { contactId } = req.params;

    await User.findByIdAndUpdate(req.user.id, {
      $pull: { 'privacySettings.blockedContacts': contactId },
    });

    res.json({ success: true, message: 'Contact unblocked' });
  } catch (error) {
    console.error('unblockContact:', error);
    res.status(500).json({ success: false, message: 'Server error' });
  }
};
