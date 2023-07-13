import 'dart:convert';
import 'dart:developer';

import 'package:hive/hive.dart';
import 'package:migii_sat/model/exam/exam_history_result_object.dart';
import 'package:migii_sat/viewmodel/extensions/string_ext.dart';

import '../../model/exam/exam_json_object.dart';
import '../../model/exam/exam_state_object.dart';
import '../../model/home/training_section_json_object.dart';
import '../../model/practice/practice_history_result_object.dart';
import 'global_helper.dart';

class HiveHelper {
  static Future<void> putData(dynamic key, dynamic value) async {
    await Hive.box(GlobalHelper.dataBox).put(key, value);
  }

  static dynamic getData(dynamic key) {
    return Hive.box(GlobalHelper.dataBox).get(key);
  }

  static dynamic deleteData(dynamic key) {
    return Hive.box(GlobalHelper.dataBox).delete(key);
  }

  // danh sách lịch sử luyện tập
  static addHistoryPractice(PracticeHistoryResultObject newItem) {
    final practiceHistoryList = getHistoryPracticeList() ?? [];
    practiceHistoryList.insert(0, newItem);

    while (practiceHistoryList.length > 30) {
      practiceHistoryList.removeLast();
    }

    putData(GlobalHelper.keyHistoryPractice, jsonEncode(practiceHistoryList));
  }

  static List<PracticeHistoryResultObject>? getHistoryPracticeList() {
    String dataJson = getData(GlobalHelper.keyHistoryPractice) ?? "";
    if (dataJson.isNullOrEmpty) return null;

    try {
      List<dynamic> objects = jsonDecode(dataJson);
      var historyList = List<PracticeHistoryResultObject>.from(
          objects.map((e) => PracticeHistoryResultObject.fromJson(e)));
      return historyList;
    } on FormatException {
      return null;
    }
  }

  // danh sách lịch sử luyện thi
  static addHistoryExam(ExamHistoryResultObject newItem) {
    final examHistoryList = getHistoryExamList() ?? [];
    examHistoryList.insert(0, newItem);

    while (examHistoryList.length > 20) {
      examHistoryList.removeLast();
    }

    putData(GlobalHelper.keyHistoryExam, jsonEncode(examHistoryList));
  }

  static List<ExamHistoryResultObject>? getHistoryExamList() {
    String dataJson = getData(GlobalHelper.keyHistoryExam) ?? "";
    if (dataJson.isNullOrEmpty) return null;

    try {
      List<dynamic> objects = jsonDecode(dataJson);
      var historyList = List<ExamHistoryResultObject>.from(
          objects.map((e) => ExamHistoryResultObject.fromJson(e)));
      return historyList;
    } on FormatException {
      return null;
    }
  }

  static Future<void> saveStateExam(
      int idExam, ExamStateObject examStateObject) async {
    await putData(
        "${GlobalHelper.keyExamState}$idExam", jsonEncode(examStateObject));
  }

  static ExamStateObject? getStateExam(int idExam) {
    String dataJson = getData("${GlobalHelper.keyExamState}$idExam") ?? "";
    if (dataJson.isNullOrEmpty) return null;

    try {
      Map object = jsonDecode(dataJson);
      var stateObject = ExamStateObject.fromJson(object.cast());
      return stateObject;
    } on FormatException {
      return null;
    }
  }

  static Future<void> saveExam(
      int idExam, ExamJSONObject examJSONObject) async {
    await putData("${GlobalHelper.keyExam}$idExam", jsonEncode(examJSONObject));
  }

  static ExamJSONObject? getExam(int idExam) {
    String dataJson = getData("${GlobalHelper.keyExam}$idExam") ?? "";
    if (dataJson.isNullOrEmpty) return null;

    try {
      Map object = jsonDecode(dataJson);
      var examObject = ExamJSONObject.fromJson(object.cast());
      return examObject;
    } on FormatException {
      return null;
    }
  }

  static List<String> getListByTheme({List<TrainingSectionTheme>? themes}) {
    List<String> data = [];
    try {
      themes?.map((e) => e.idKindList?.map((e) {
            log(e);
            data.add(e);
          }));
      return data;
    } catch (e) {
      throw Exception(e);
    }
  }
}
