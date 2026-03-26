const multer = require('multer');
const path = require('path');

// Multer config
const storage = multer.memoryStorage();

const upload = multer({
  storage,
  limits: { fileSize: 1024 * 1024 * 50 }, // 50MB limit
  fileFilter: (req, file, cb) => {
    const ext = path.extname(file.originalname).toLowerCase();
    if (
      ext !== '.jpg' && 
      ext !== '.jpeg' && 
      ext !== '.png' && 
      ext !== '.mp4' && 
      ext !== '.pdf' && 
      ext !== '.mp3'
    ) {
      return cb(new Error('Only images, videos, audio and PDFs are allowed'));
    }
    cb(null, true);
  },
});

module.exports = upload;
