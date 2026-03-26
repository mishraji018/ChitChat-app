const mongoose = require('mongoose');

const ConversationSchema = new mongoose.Schema({
  participants: [{
    type: mongoose.Schema.ObjectId,
    ref: 'User',
    required: true,
  }],
  isGroup: {
    type: Boolean,
    default: false,
  },
  groupName: {
    type: String,
    trim: true,
  },
  groupAvatar: {
    type: String,
    default: 'https://cdn-icons-png.flaticon.com/512/633/633716.png',
  },
  admin: {
    type: mongoose.Schema.ObjectId,
    ref: 'User',
  },
  lastMessage: {
    type: mongoose.Schema.ObjectId,
    ref: 'Message',
  },
  unreadCount: {
    type: Map,
    of: Number,
    default: {},
  },
  createdAt: {
    type: Date,
    default: Date.now,
  },
  updatedAt: {
    type: Date,
    default: Date.now,
  },
});

module.exports = mongoose.model('Conversation', ConversationSchema);
