const express = require('express');
const router = express.Router();
const protect = require('../middleware/auth.middleware');
const {
  getAccount,
  getPasskeys,
  addPasskey,
  removePasskey,
  updateEmail,
  requestPhoneChange,
  confirmPhoneChange,
  deleteAccount,
} = require('../controllers/accountController');

router.get('/', protect, getAccount);
router.get('/passkeys', protect, getPasskeys);
router.post('/passkeys', protect, addPasskey);
router.delete('/passkeys/:passkeyId', protect, removePasskey);
router.put('/email', protect, updateEmail);
router.post('/change-phone', protect, requestPhoneChange);
router.put('/change-phone/confirm', protect, confirmPhoneChange);
router.delete('/', protect, deleteAccount);

module.exports = router;
