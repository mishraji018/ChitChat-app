# 🐻 ChitChat App

> [!NOTE]
> **Project Status:** Under Active Development 🚀

A premium, secure real-time messaging application with **Phone-based SMS OTP Authentication**. 

Built with **Flutter** for the mobile experience and **Node.js** for a robust, scalable backend.

---

## 🚀 Features

*   📱 **Phone Number Login**: Secure authentication using 6-digit OTP codes.
*   ⚡ **SMS Auto-Fill**: Automatically detects and fills your OTP on Android using the SMS Retriever API.
*   💬 **Real-time Chatting**: Instant message delivery powered by Socket.io.
*   ☁️ **Cloud Database**: Integrated with MongoDB Atlas for persistent storage.
*   🧪 **Developer Friendly**: Easily run the entire stack locally for testing.

---

## 📂 Project Structure

*   **/frontend**: Flutter mobile application.
*   **/backend**: Node.js / Express server and Socket.io controller.

---

## 🛠️ Local Setup Guide

Follow these steps to run the app on your local machine:

### 1. Backend Setup
1.  Navigate to the `backend` folder: `cd backend`
2.  Install dependencies: `npm install`
3.  Configure your environment:
    *   Rename `.env.example` to **`.env`** (if not already there).
    *   Update **`MONGODB_URI`** with your MongoDB Atlas connection string.
    *   Ensure the username and password in the link match your Atlas configuration.
4.  Launch the server:
    ```powershell
    npm run dev
    ```
    *The terminal should say:* `✅ MongoDB Connected`

### 2. Frontend Setup
1.  Navigate to the `frontend` folder: `cd frontend`
2.  Install Flutter packages: 
    ```powershell
    flutter pub get
    ```
3.  **Configure API Endpoint**:
    *   Open `lib/services/v2/api_service.dart`.
    *   For **Android Emulator**, use: `http://10.0.2.2:5000`
    *   For **Real Devices**, use your computer's local IP (e.g., `http://192.168.1.5:5000`).
4.  Run the app:
    ```powershell
    flutter run
    ```

---

## 🔑 SMS OTP Testing

Since the backend is running locally, it does not send "real" carrier SMS. 

1.  Enter your phone number in the app and click **Login**.
2.  Go to your **Backend terminal** (where `npm run dev` is running).
3.  You will see a message like: 
    `[SMS] <#> Your ChitChat OTP is: 123456 [APP_HASH]`
4.  Type the 6-digit code into the app. On many Android devices, it will be automatically detected!

---

## 🛡️ Requirements
*   **Node.js**: v18 or later recommended.
*   **Flutter**: Stable channel.
*   **Database**: MongoDB Atlas (Free Tier works great).
*   **Android Device/Emulator**: Recommended for full SMS Auto-fill support.

---

*Made with ❤️ for premium messaging.*
