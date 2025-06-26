// routes/ai.js
const express = require('express');
const router = express.Router();
const practiceController = require('../controllers/practiceController.js');
const authenticate = require('../middleware/authMiddleware');


router.get('/getDailyPractice', authenticate, practiceController.getDailyPractice);
router.post('/save-final', authenticate, practiceController.saveResultAndArchive);
router.post('/save-answer', authenticate, practiceController.savePracticeAnswer);
router.post('/clear-practice', authenticate, practiceController.clearPractice);

module.exports = router;