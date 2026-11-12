
const express = require("express");
const router = express.Router();

const {
  createExam,
  getExams,
  getExamQuestions
} = require("../controllers/examController");

router.post("/", createExam);
router.get("/", getExams);
router.get("/:id/questions", getExamQuestions);

module.exports = router;
