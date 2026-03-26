const express = require('express');
const { 
  searchUsers, 
  getUserById, 
  syncContacts,
  updateSettings
} = require('../controllers/user.controller');
const protect = require('../middleware/auth.middleware');

const router = express.Router();

router.use(protect); // All user routes protected

router.get('/search', searchUsers);
router.put('/settings', updateSettings);
router.put('/block/:id', (req, res, next) => require('../controllers/user.controller').blockUser(req, res, next));
router.put('/unblock/:id', (req, res, next) => require('../controllers/user.controller').unblockUser(req, res, next));
router.put('/mute/:id', (req, res, next) => require('../controllers/user.controller').muteConversation(req, res, next));
router.put('/unmute/:id', (req, res, next) => require('../controllers/user.controller').unmuteConversation(req, res, next));
router.get('/:id', getUserById);
router.post('/sync', syncContacts);

module.exports = router;
