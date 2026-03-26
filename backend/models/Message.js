const mongoose = require('mongoose');

const MessageSchema = new mongoose.Schema({
  conversationId: {
    type: mongoose.Schema.ObjectId,
    ref: 'Conversation',
    required: true,
  },
  senderId: {
    type: mongoose.Schema.ObjectId,
    ref: 'User',
    required: true,
  },
  text: {
    type: String,
    trim: true,
  },
  type: {
    type: String,
    enum: ['text', 'image', 'pdf', 'voice', 'video', 'location'],
    default: 'text',
  },
  mediaUrl: String,
  duration: Number, // For voice/video
  status: {
    type: String,
    enum: ['sent', 'delivered', 'read'],
    default: 'sent',
  },
  replyTo: {
    type: mongoose.Schema.ObjectId,
    ref: 'Message',
  },
  reactions: {
    type: Map,
    of: [String], // List of emojis
    default: {},
  },
  isStarred: {
    type: Boolean,
    default: false,
  },
  isEdited: {
    type: Boolean,
    default: false,
  },
  isDeleted: {
    type: Boolean,
    default: false,
  },
  timestamp: {
    type: Date,
    default: Date.now,
  },
});

module.exports = mongoose.model('Message', MessageSchema);
