const Conversation = require('../models/Conversation');
const Message = require('../models/Message');
const User = require('../models/User');

// @desc    Get all conversations for current user
// @route   GET /api/chats
// @access  Private
exports.getChats = async (req, res) => {
  try {
    const conversations = await Conversation.find({
      participants: req.user.id,
    })
      .populate('participants', 'name phone avatar status isOnline lastSeen')
      .populate('lastMessage')
      .sort('-updatedAt');

    res.json({ success: true, data: conversations });
  } catch (error) {
    console.error('getChats:', error);
    res.status(500).json({ success: false, message: 'Server error' });
  }
};

// @desc    Get a single conversation by ID
// @route   GET /api/chats/:id
// @access  Private
exports.getChatById = async (req, res) => {
  try {
    const conversation = await Conversation.findOne({
      _id: req.params.id,
      participants: req.user.id,
    })
      .populate('participants', 'name phone avatar status isOnline lastSeen')
      .populate('lastMessage');

    if (!conversation) {
      return res.status(404).json({ success: false, message: 'Conversation not found' });
    }

    res.json({ success: true, data: conversation });
  } catch (error) {
    console.error('getChatById:', error);
    res.status(500).json({ success: false, message: 'Server error' });
  }
};

// @desc    Create or get a private conversation
// @route   POST /api/chats
// @access  Private
exports.createChat = async (req, res) => {
  try {
    const { receiverId } = req.body;

    if (!receiverId) {
      return res.status(400).json({ success: false, message: 'receiverId is required' });
    }

    // Check if conversation already exists
    let conversation = await Conversation.findOne({
      isGroup: false,
      participants: { $all: [req.user.id, receiverId] },
    }).populate('participants', 'name phone avatar status isOnline lastSeen');

    if (!conversation) {
      conversation = await Conversation.create({
        participants: [req.user.id, receiverId],
        isGroup: false,
      });
      conversation = await conversation.populate('participants', 'name phone avatar status isOnline lastSeen');
    }

    res.status(201).json({ success: true, data: conversation });
  } catch (error) {
    console.error('createChat:', error);
    res.status(500).json({ success: false, message: 'Server error' });
  }
};

// @desc    Create a group conversation
// @route   POST /api/chats/group
// @access  Private
exports.createGroupChat = async (req, res) => {
  try {
    const { name, participantIds, avatar } = req.body;

    if (!name || !participantIds || !participantIds.length) {
      return res.status(400).json({ success: false, message: 'name and participantIds are required' });
    }

    const conversation = await Conversation.create({
      groupName: name,
      participants: [...participantIds, req.user.id],
      isGroup: true,
      admin: req.user.id,
      groupAvatar: avatar,
    });

    const populated = await conversation.populate('participants', 'name phone avatar status isOnline lastSeen');

    res.status(201).json({ success: true, data: populated });
  } catch (error) {
    console.error('createGroupChat:', error);
    res.status(500).json({ success: false, message: 'Server error' });
  }
};

// @desc    Send a message to a conversation
// @route   POST /api/chats/:id/messages
// @access  Private
exports.sendMessage = async (req, res) => {
  try {
    const { text, type, mediaUrl, replyTo, duration } = req.body;
    const conversationId = req.params.id;

    const conversation = await Conversation.findOne({
      _id: conversationId,
      participants: req.user.id,
    });

    if (!conversation) {
      return res.status(404).json({ success: false, message: 'Conversation not found' });
    }

    const message = await Message.create({
      conversationId,
      senderId: req.user.id,
      text,
      type: type || 'text',
      mediaUrl,
      replyTo,
      duration,
    });

    const populated = await message.populate('senderId', 'name avatar');

    // Update conversation's lastMessage
    await Conversation.findByIdAndUpdate(conversationId, {
      lastMessage: message._id,
      updatedAt: Date.now(),
    });

    res.status(201).json({ success: true, data: populated });
  } catch (error) {
    console.error('sendMessage:', error);
    res.status(500).json({ success: false, message: 'Server error' });
  }
};

// @desc    Get messages for a conversation
// @route   GET /api/chats/:id/messages
// @access  Private
exports.getMessages = async (req, res) => {
  try {
    const { page = 1, limit = 50 } = req.query;

    const messages = await Message.find({ conversationId: req.params.id })
      .populate('senderId', 'name avatar')
      .populate('replyTo')
      .sort('-timestamp')
      .limit(limit * 1)
      .skip((page - 1) * limit);

    res.json({ success: true, data: messages });
  } catch (error) {
    console.error('getMessages:', error);
    res.status(500).json({ success: false, message: 'Server error' });
  }
};

// @desc    Edit a message
// @route   PUT /api/chats/messages/:messageId
// @access  Private
exports.editMessage = async (req, res) => {
  try {
    const { text } = req.body;
    const message = await Message.findById(req.params.messageId);

    if (!message) {
      return res.status(404).json({ success: false, message: 'Message not found' });
    }

    if (message.senderId.toString() !== req.user.id.toString()) {
      return res.status(401).json({ success: false, message: 'Unauthorized' });
    }

    message.text = text;
    message.isEdited = true;
    await message.save();

    res.json({ success: true, data: message });
  } catch (error) {
    console.error('editMessage:', error);
    res.status(500).json({ success: false, message: 'Server error' });
  }
};

// @desc    Delete a message
// @route   DELETE /api/chats/messages/:messageId
// @access  Private
exports.deleteMessage = async (req, res) => {
  try {
    const { forEveryone } = req.body;
    const message = await Message.findById(req.params.messageId);

    if (!message) {
      return res.status(404).json({ success: false, message: 'Message not found' });
    }

    if (message.senderId.toString() !== req.user.id.toString()) {
      return res.status(401).json({ success: false, message: 'Unauthorized' });
    }

    if (forEveryone) {
      message.isDeleted = true;
      message.text = 'This message was deleted';
      message.mediaUrl = undefined;
      await message.save();
    } else {
      await Message.findByIdAndDelete(req.params.messageId);
    }

    res.json({ success: true, message: 'Message deleted' });
  } catch (error) {
    console.error('deleteMessage:', error);
    res.status(500).json({ success: false, message: 'Server error' });
  }
};

// @desc    React to a message
// @route   POST /api/chats/messages/:messageId/react
// @access  Private
exports.reactToMessage = async (req, res) => {
  try {
    const { emoji } = req.body;
    const message = await Message.findById(req.params.messageId);

    if (!message) {
      return res.status(404).json({ success: false, message: 'Message not found' });
    }

    if (!emoji) {
      return res.status(400).json({ success: false, message: 'emoji is required' });
    }

    const userId = req.user.id.toString();
    const reactions = message.reactions || new Map();

    if (!reactions.has(emoji)) {
      reactions.set(emoji, []);
    }

    const users = reactions.get(emoji);
    const idx = users.indexOf(userId);

    if (idx === -1) {
      users.push(userId); // add reaction
    } else {
      users.splice(idx, 1); // toggle off
    }

    reactions.set(emoji, users);
    message.reactions = reactions;
    await message.save();

    res.json({ success: true, data: message });
  } catch (error) {
    console.error('reactToMessage:', error);
    res.status(500).json({ success: false, message: 'Server error' });
  }
};

// @desc    Clear all messages in a conversation
// @route   DELETE /api/chats/:id/clear
// @access  Private
exports.clearChat = async (req, res) => {
  try {
    const chatId = req.params.id;

    const conversation = await Conversation.findOne({
      _id: chatId,
      participants: req.user.id,
    });

    if (!conversation) {
      return res.status(404).json({ success: false, message: 'Conversation not found' });
    }

    await Message.deleteMany({ conversationId: chatId });

    await Conversation.findByIdAndUpdate(chatId, {
      $unset: { lastMessage: 1 },
    });

    res.json({ success: true, message: 'Chat cleared' });
  } catch (error) {
    console.error('clearChat:', error);
    res.status(500).json({ success: false, message: 'Server error' });
  }
};