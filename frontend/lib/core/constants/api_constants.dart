class ApiConstants {
  static const String baseUrl = 'http://10.0.2.2:5000/api'; 
  // 10.0.2.2 = localhost for Android emulator
  static const String socketUrl = 'http://10.0.2.2:5000';
  static const String cloudinaryBase = 'https://api.cloudinary.com/v1_1';
  
  // Auth endpoints
  static const String signup = '/auth/signup';
  static const String login = '/auth/login';
  static const String logout = '/auth/logout';
  static const String verifyOtp = '/auth/verify-otp';
  static const String forgotPasskey = '/auth/forgot-passkey';
  static const String resetPasskey = '/auth/reset-passkey';
  static const String deleteAccount = '/auth/delete-account';
  
  // User endpoints
  static const String getProfile = '/user/profile';
  static const String updateProfile = '/user/update';
  static const String searchUsers = '/user/search';
  static const String getContacts = '/user/contacts';
  
  // Chat endpoints
  static const String getConversations = '/chat/conversations';
  static const String getMessages = '/chat/messages';
  static const String sendMessage = '/chat/send';
  static const String deleteMessage = '/chat/delete';
  static const String editMessage = '/chat/edit';
  
  // Media
  static const String uploadMedia = '/media/upload';
}
