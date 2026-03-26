const { Server } = require('socket.io');
const jwt = require('jsonwebtoken');
const User = require('../models/User');
const Conversation = require('../models/Conversation');
const Message = require('../models/Message');

let io;

const initSocket = (server) => {
  io = new Server(server, {
    cors: {
      origin: '*',
      methods: ['GET', 'POST'],
    },
  });

  // Authentication Middleware for Socket
  io.use(async (socket, next) => {
    try {
      const token = socket.handshake.auth.token;
      if (!token) {
        return next(new Error('Authentication error'));
      }

      const decoded = jwt.verify(token, process.env.JWT_SECRET);
      const user = await User.findById(decoded.id);

      if (!user) {
        return next(new Error('User not found'));
      }

      socket.user = user;
      next();
    } catch (err) {
      next(new Error('Authentication error'));
    }
  });

  io.on('connection', (socket) => {
    console.log(`🔌 Socket connected: ${socket.user.name} (${socket.id})`);

    // Update user status to online
    updateUserStatus(socket.user.id, true);

    // Join user's personal room for notifications
    socket.join(socket.user.id.toString());

    // Join shared conversation rooms
    socket.on('join_room', (data) => {
      const { conversationId } = data;
      socket.join(conversationId);
      console.log(`👤 ${socket.user.name} joined room: ${conversationId}`);
    });

    socket.on('leave_room', (data) => {
      const { conversationId } = data;
      socket.leave(conversationId);
      console.log(`👤 ${socket.user.name} left room: ${conversationId}`);
    });

    // Handle sending messages
    socket.on('send_message', async (data) => {
      try {
        const { conversationId, text, type, mediaUrl, replyTo, duration } = data;

        const message = await Message.create({
          conversationId,
          senderId: socket.user.id,
          text,
          type,
          mediaUrl,
          replyTo,
          duration,
        });

        const populatedMessage = await message.populate('senderId', 'name avatar');

        // Update conversation's last message and updatedAt
        await Conversation.findByIdAndUpdate(conversationId, {
          lastMessage: message._id,
          updatedAt: Date.now(),
        });

        // Broadcast to everyone in the room
        io.to(conversationId).emit('new_message', populatedMessage);
        
        console.log(`📩 Message from ${socket.user.name} in ${conversationId}`);
      } catch (err) {
        console.error('Socket send_message error:', err);
      }
    });

    // Handle typing indicators
    socket.on('typing_start', (data) => {
      const { conversationId } = data;
      socket.to(conversationId).emit('typing_start', {
        conversationId,
        userId: socket.user.id,
        userName: socket.user.name,
      });
    });

    socket.on('typing_stop', (data) => {
      const { conversationId } = data;
      socket.to(conversationId).emit('typing_stop', {
        conversationId,
        userId: socket.user.id,
      });
    });

    // Handle message status updates (Delivered/Read)
    socket.on('message_read', async (data) => {
      const { conversationId } = data;
      await Message.updateMany(
        { conversationId, senderId: { $ne: socket.user.id }, status: { $ne: 'read' } },
        { status: 'read' }
      );
      socket.to(conversationId).emit('message_status', {
        conversationId,
        status: 'read',
      });
    });

    // Handle disconnection
    socket.on('disconnect', () => {
      console.log(`🔌 Socket disconnected: ${socket.user.name}`);
      updateUserStatus(socket.user.id, false);
    });
  });

  return io;
};

const updateUserStatus = async (userId, isOnline) => {
  try {
    await User.findByIdAndUpdate(userId, {
      isOnline,
      lastSeen: Date.now(),
    });
    io.emit('user_status_change', {
      userId,
      isOnline,
      lastSeen: Date.now(),
    });
  } catch (err) {
    console.error('Update status error:', err);
  }
};

module.exports = { initSocket };
