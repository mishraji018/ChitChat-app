const express = require('express');
const router = express.Router();
const protect = require('../middleware/auth.middleware');
const {
  getChats,
  getChatById,
  createChat,
  createGroupChat,
  sendMessage,
  getMessages,
  editMessage,
  deleteMessage,
  reactToMessage,
  clearChat,
} = require('../controllers/chat.controller');

router.get('/', protect, getChats);
router.get('/:id', protect, getChatById);
router.post('/', protect, createChat);
router.post('/group', protect, createGroupChat);
router.post('/:id/messages', protect, sendMessage);
router.get('/:id/messages', protect, getMessages);
router.put('/messages/:messageId', protect, editMessage);
router.delete('/messages/:messageId', protect, deleteMessage);
router.post('/messages/:messageId/react', protect, reactToMessage);
router.delete('/:id/clear', protect, clearChat);

module.exports = router;