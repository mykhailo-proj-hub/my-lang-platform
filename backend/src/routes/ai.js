// routes/ai.js
const express = require('express');
const router = express.Router();
const aiController = require('../controllers/aiController.js');
const authenticate = require('../middleware/authMiddleware');

router.post('/improveMessage', authenticate, aiController.improveMessage);
router.post('/analyzeMessage', authenticate, aiController.analyzeMessage);

module.exports = router;
