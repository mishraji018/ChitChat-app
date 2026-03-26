const cloudinary = require('../config/cloudinary');
const { encrypt } = require('../utils/encryption.utils');

// @desc    Upload media to Cloudinary
// @route   POST /api/media/upload
// @access  Private
exports.uploadMedia = async (req, res, next) => {
  try {
    if (!req.file) {
      return res.status(400).json({
        success: false,
        message: 'Please upload a file',
        data: null
      });
    }

    // Upload to cloudinary
    const result = await new Promise((resolve, reject) => {
      const uploadStream = cloudinary.uploader.upload_stream(
        {
          folder: 'chitchat/media',
          resource_type: 'auto',
          use_filename: true,
          unique_filename: true,
        },
        (error, result) => {
          if (error) reject(error);
          else resolve(result);
        }
      );
      uploadStream.end(req.file.buffer);
    });

    res.status(200).json({
      success: true,
      message: 'File uploaded successfully',
      data: {
        url: result.secure_url,
        public_id: result.public_id,
        bytes: result.bytes,
        format: result.format,
        resource_type: result.resource_type
      }
    });
  } catch (err) {
    next(err);
  }
};

// @desc    Delete media from Cloudinary
// @route   DELETE /api/media/:public_id
// @access  Private
exports.deleteMedia = async (req, res, next) => {
  try {
    const { public_id } = req.params;
    
    await cloudinary.uploader.destroy(public_id);

    res.status(200).json({
      success: true,
      message: 'Media deleted',
      data: null
    });
  } catch (err) {
    next(err);
  }
};
