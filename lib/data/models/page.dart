import 'package:surveyapp/data/models/question.dart';

class PageData {
  String pid;
  String title;
  List<Question> questions;

  PageData.fromJson(Map json)
      : title = json['pageTitle'] ?? "",
        pid = json['pageId'] ?? "",
        questions = (json['questions'] as List<dynamic>)
            .map<Question>((e) => getQuestion(e))
            .toList();

  static Question getQuestion(Map<String, dynamic> e) {
    final answerType = e['answerType'];

    switch (answerType) {
      case 'select':
        return SingleChoiceQuestion.fromJson(e);
      case 'numeric':
        return NumericChoiceQuestion.fromJson(e);
      case 'image':
        return ImageQuestion.fromJson(e);
      case 'video':
        return VideoQuestion.fromJson(e);
      case 'text':
      default:
        return OneLinerQuestion.fromJson(e);
    }
  }

  static Map<String, dynamic> getQuestionJson(Question e) {
    if (e is SingleChoiceQuestion) return SingleChoiceQuestion.toJson(e);
    if (e is NumericChoiceQuestion) return NumericChoiceQuestion.toJson(e);
    if (e is ImageQuestion) return ImageQuestion.toJson(e);
    if (e is VideoQuestion) return VideoQuestion.toJson(e);
    if (e is OneLinerQuestion) return OneLinerQuestion.toJson(e);

    return {};
  }

  static Map<String, dynamic> toJson(PageData page) {
    return {
      "pageId": page.pid,
      "pageTitle": page.title,
      "questions": page.questions.map((e) => getQuestionJson(e)).toList(),
    };
  }
}
