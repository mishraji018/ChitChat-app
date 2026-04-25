const { Server } = require('socket.io');
const jwt = require('jsonwebtoken');
const User = require('../models/User');
const Conversation = require('../models/Conversation');
const Message = require('../models/Message');

let io;

const initSocket = (server) => {
  io = new Server(server, {
    pingTimeout: 60000, // Speed ke liye connection ko active rakhta hai
    cors: {
      origin: '*', 
      methods: ['GET', 'POST'],
    },
    // Flutter ke saath connection stable karne ke liye zaroori hai
    transports: ['websocket', 'polling'], 
  });

  // Authentication Middleware
  io.use(async (socket, next) => {
    try {
      // Flutter se token yaha milna chahiye: auth: { 'token': '...' }
      const token = socket.handshake.auth?.token || socket.handshake.headers?.token;

      if (!token) {
        console.log('❌ Socket Auth Failed: No token provided');
        return next(new Error('Authentication error: No token'));
      }

      const decoded = jwt.verify(token, process.env.JWT_SECRET);
      const user = await User.findById(decoded.id).select('-password');

      if (!user) {
        console.log('❌ Socket Auth Failed: User not found in DB');
        return next(new Error('User not found'));
      }

      socket.user = user;
      next();
    } catch (err) {
      console.log('❌ Socket Auth Error:', err.message);
      next(new Error('Authentication error'));
    }
  });

  io.on('connection', (socket) => {
    // Ye message aapke terminal mein aayega jab Flutter connect hoga
    console.log(`🚀 Socket Connected: ${socket.user.name} (ID: ${socket.id})`);

    updateUserStatus(socket.user.id, true);
    socket.join(socket.user.id.toString());

    // Join Chat Room
    socket.on('join_room', (data) => {
      const { conversationId } = data;
      if (conversationId) {
        socket.join(conversationId);
        console.log(`👤 ${socket.user.name} joined room: ${conversationId}`);
      }
    });

    // Handle Sending Messages (FAST DELIVERY LOGIC)
    socket.on('send_message', async (data) => {
      try {
        const { conversationId, text, type, mediaUrl, replyTo, duration } = data;

        // 1. Create message object (Save to DB)
        const message = await Message.create({
          conversationId,
          senderId: socket.user.id,
          text,
          type: type || 'text',
          mediaUrl,
          replyTo,
          duration,
        });

        const populatedMessage = await message.populate('senderId', 'name avatar');

        // 2. Immediate Broadcast (Delhi to anywhere in India instantly)
        io.to(conversationId).emit('new_message', populatedMessage);
        
        // 3. Background Update (Database cleanup)
        await Conversation.findByIdAndUpdate(conversationId, {
          lastMessage: message._id,
          updatedAt: Date.now(),
        });

        console.log(`📩 Message delivered from ${socket.user.name}`);
      } catch (err) {
        console.error('❌ send_message error:', err.message);
      }
    });

    // Typing Indicators
    socket.on('typing_start', (data) => {
      socket.to(data.conversationId).emit('typing_start', {
        conversationId: data.conversationId,
        userId: socket.user.id,
        userName: socket.user.name,
      });
    });

    socket.on('typing_stop', (data) => {
      socket.to(data.conversationId).emit('typing_stop', {
        conversationId: data.conversationId,
        userId: socket.user.id,
      });
    });

    // Disconnect
    socket.on('disconnect', () => {
      console.log(`🔌 Socket Disconnected: ${socket.user.name}`);
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
    // Sabko batayein ki ye user online/offline hua hai
    io.emit('user_status_change', {
      userId,
      isOnline,
      lastSeen: Date.now(),
    });
  } catch (err) {
    console.error('Status Update Error:', err);
  }
};

module.exports = { initSocket };