# ChitChat Backend API

Modern, secure, and scalable backend for the ChitChat message application.

## Tech Stack
- **Runtime:** Node.js
- **Framework:** Express.js
- **Database:** MongoDB with Mongoose
- **Real-time:** Socket.IO
- **Storage:** Cloudinary
- **Auth:** JWT & Bcrypt
- **Security:** Helmet, Express Rate Limit, Encryption

## Features
- Real-time text messaging
- Media sharing (Images, PDF, Video, Audio)
- Interactive typing indicators
- User online/offline status
- JWT Authentication with OTP support
- Message reactions and replies
- Group and individual chats

## Setup Instructions

1. **Install Dependencies:**
   ```bash
   npm install
   ```

2. **Environment Configuration:**
   - Copy `.env.example` to `.env`
   - Fill in your MongoDB URI, JWT Secret, and service credentials.

3. **Run in Development:**
   ```bash
   npm run dev
   ```

4. **Production Build:**
   ```bash
   npm start
   ```

## Folder Structure
- `config/`: Configuration modules for DB and external services.
- `models/`: Mongoose schemas.
- `routes/`: API endpoint definitions.
- `controllers/`: Request handling logic.
- `middleware/`: Authentication and security layers.
- `utils/`: Helper functions.
- `socket/`: Real-time event handlers.
