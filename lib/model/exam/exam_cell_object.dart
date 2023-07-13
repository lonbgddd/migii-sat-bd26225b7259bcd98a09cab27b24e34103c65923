import '../practice/practice_json_object.dart';

class ExamCellObject {
  String? title;
  int? partNumber;
  int? posQuestion;
  PracticeQuestion? question;

  ExamCellObject(this.title, this.partNumber, this.posQuestion, this.question);
}
