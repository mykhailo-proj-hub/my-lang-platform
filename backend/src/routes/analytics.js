const express = require('express');
const router = express.Router();
const analyticsController = require('../controllers/analyticsController.js');
const authenticate = require('../middleware/authMiddleware');


router.get('/chat', authenticate, analyticsController.chatAnalytics);
router.get('/practice', authenticate, analyticsController.practiceStats);

module.exports = router;
