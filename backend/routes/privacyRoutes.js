const express = require('express');
const router = express.Router();
const protect = require('../middleware/auth');
const {
  getPrivacySettings,
  updatePrivacySettings,
  getBlockedContacts,
  blockContact,
  unblockContact,
} = require('../controllers/privacyController');

router.route('/').get(protect, getPrivacySettings).put(protect, updatePrivacySettings);
router.route('/blocked').get(protect, getBlockedContacts).post(protect, blockContact);
router.route('/blocked/:contactId').delete(protect, unblockContact);

module.exports = router;
