const express = require('express');
const { 
  getPrivateChat, 
  createGroup, 
  getConversations, 
  getMessages, 
  deleteMessage 
} = require('../controllers/chat.controller');
const protect = require('../middleware/auth.middleware');

const router = express.Router();

router.use(protect); // All chat routes protected

router.post('/private', getPrivateChat);
router.post('/group', createGroup);
router.get('/', getConversations);
router.get('/:id/messages', getMessages);
router.delete('/:id/clear', clearChat);
router.delete('/messages/:id', deleteMessage);

module.exports = router;
