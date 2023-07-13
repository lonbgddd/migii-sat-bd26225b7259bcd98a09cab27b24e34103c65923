class NumberAnswerObject {
  int? questionNumber;
  int? questionNumberChild;
  int? answerChoose;
  int? answerCorrect;
  int? numberAnswer;

  NumberAnswerObject(this.questionNumber, this.questionNumberChild,
      this.answerChoose, this.answerCorrect, this.numberAnswer);
}

class NumberAnswerGridInsObject {
  int? questionNumber;
  int? questionNumberChild;
  String? yourAnswer;
  List<String>? correctAnswer;
  bool? isCorrect;

  NumberAnswerGridInsObject(this.questionNumber, this.questionNumberChild,
      this.yourAnswer, this.correctAnswer, this.isCorrect);
}

class ExamNumberAnswerObject {
  int? questionNumber;
  int? questionNumberChild;
  String? yourAnswer;
  List<String>? correctAnswer;
  bool? isCorrect;

  ExamNumberAnswerObject(this.questionNumber, this.questionNumberChild,
      this.yourAnswer, this.correctAnswer, this.isCorrect);
}
