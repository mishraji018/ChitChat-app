const Conversation = require('../models/Conversation');
const Message = require('../models/Message');
const User = require('../models/User');

// @desc    Create or get a private conversation
// @route   POST /api/chats/private
// @access  Private
exports.getPrivateChat = async (req, res, next) => {
  try {
    const { receiverId } = req.body;

    if (!receiverId) {
      return res.status(400).json({ success: false, message: 'Receiver ID is required', data: null });
    }

    // Check if conversation exists
    let conversation = await Conversation.findOne({
      isGroup: false,
      participants: { $all: [req.user.id, receiverId] }
    }).populate('participants', 'name phone avatar status isOnline lastSeen');

    if (!conversation) {
      conversation = await Conversation.create({
        participants: [req.user.id, receiverId],
        isGroup: false
      });
      conversation = await conversation.populate('participants', 'name phone avatar status isOnline lastSeen');
    }

    res.status(200).json({
      success: true,
      message: 'Conversation retrieved',
      data: conversation
    });
  } catch (err) {
    next(err);
  }
};

// @desc    Create a group conversation
// @route   POST /api/chats/group
// @access  Private
exports.createGroup = async (req, res, next) => {
  try {
    const { name, participantIds, avatar } = req.body;

    const conversation = await Conversation.create({
      groupName: name,
      participants: [...participantIds, req.user.id],
      isGroup: true,
      admin: req.user.id,
      groupAvatar: avatar
    });

    const populated = await conversation.populate('participants', 'name phone avatar status isOnline lastSeen');

    res.status(201).json({
      success: true,
      message: 'Group created successfully',
      data: populated
    });
  } catch (err) {
    next(err);
  }
};

// @desc    Get all conversations for current user
// @route   GET /api/chats
// @access  Private
exports.getConversations = async (req, res, next) => {
  try {
    const conversations = await Conversation.find({
      participants: req.user.id
    })
    .populate('participants', 'name phone avatar status isOnline lastSeen')
    .populate('lastMessage')
    .sort('-updatedAt');

    res.status(200).json({
      success: true,
      message: 'Conversations retrieved',
      data: conversations
    });
  } catch (err) {
    next(err);
  }
};

// @desc    Get messages for a conversation
// @route   GET /api/chats/:id/messages
// @access  Private
exports.getMessages = async (req, res, next) => {
  try {
    const { page = 1, limit = 50 } = req.query;

    const messages = await Message.find({ conversationId: req.params.id })
      .populate('senderId', 'name avatar')
      .populate('replyTo')
      .sort('-timestamp')
      .limit(limit * 1)
      .skip((page - 1) * limit);

    res.status(200).json({
      success: true,
      message: 'Messages retrieved',
      data: messages
    });
  } catch (err) {
    next(err);
  }
};

// @desc    Delete message
// @route   DELETE /api/chats/messages/:id
// @access  Private
exports.deleteMessage = async (req, res, next) => {
  try {
    const { forEveryone } = req.body;
    const message = await Message.findById(req.params.id);

    if (!message) {
      return res.status(404).json({ success: false, message: 'Message not found', data: null });
    }

    if (message.senderId.toString() !== req.user.id.toString()) {
      return res.status(401).json({ success: false, message: 'Unauthorized', data: null });
    }

    if (forEveryone) {
      message.isDeleted = true;
      message.text = 'Message deleted';
      message.mediaUrl = undefined;
      await message.save();
    } else {
      await message.remove();
    }

    res.status(200).json({
      success: true,
      message: 'Message deleted',
      data: null
    });
  } catch (err) {
    next(err);
  }
};

// @desc    Clear all messages in a conversation
// @route   DELETE /api/chats/:id/clear
// @access  Private
exports.clearChat = async (req, res, next) => {
  try {
    // In a production app, we might mark as deleted for this specific user.
    // In this simplified context, we'll delete the messages if the user is a participant.
    const conversation = await Conversation.findOne({
      _id: req.params.id,
      participants: req.user.id
    });

    if (!conversation) {
      return res.status(404).json({ success: false, message: 'Conversation not found', data: null });
    }

    await Message.deleteMany({ conversationId: req.params.id });

    res.status(200).json({
      success: true,
      message: 'Chat cleared successfully',
      data: null
    });
  } catch (err) {
    next(err);
  }
};
