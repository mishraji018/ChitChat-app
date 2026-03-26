const express = require('express');
const { uploadMedia, deleteMedia } = require('../controllers/media.controller');
const protect = require('../middleware/auth.middleware');
const upload = require('../middleware/upload.middleware');

const router = express.Router();

router.use(protect);

router.post('/upload', upload.single('file'), uploadMedia);
router.delete('/:public_id', deleteMedia);

module.exports = router;
