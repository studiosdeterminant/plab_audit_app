enum UploadStatus { UPLOADING, UPLOADED, QUEUED, ERROR }

abstract class Question {
  String questionType = "";
  Map<String, dynamic>? imageData;
}

class SingleChoiceQuestion extends Question {
  String question, qid;
  int answer = -1;
  bool isRequired;
  List<String> options;

  SingleChoiceQuestion.fromJson(Map json)
      : options =
            json['answerOptions'].map<String>((e) => e.toString()).toList(),
        qid = json['questionId'],
        isRequired = json['isRequired'],
        answer = json.containsKey('questionAnswer')
            ? int.parse(json['questionAnswer'])
            : -1,
        question = json['questionTitle'] {
    questionType = json['questionType'] ?? "";
    imageData = json['imageData'];
  }

  static Map<String, dynamic> toJson(SingleChoiceQuestion question) {
    return {
      "questionTitle": question.question,
      "questionId": question.qid,
      "questionAnswer": question.answer.toString(),
      "answerOptions": question.options,
      "isRequired": question.isRequired,
      "answerType": "select",
      "questionType": question.questionType,
      "imageData": question.imageData,
    };
  }
}

class NumericChoiceQuestion extends Question {
  String question, qid;
  int? answer;
  bool isRequired;

  NumericChoiceQuestion.fromJson(Map json)
      : question = json['questionTitle'],
        qid = json['questionId'],
        answer = json.containsKey('questionAnswer')
            ? int.tryParse(json['questionAnswer'])
            : null,
        isRequired = json['isRequired'] {
    questionType = json['questionType'] ?? "";
    imageData = json['imageData'];
  }

  static Map<String, dynamic> toJson(NumericChoiceQuestion question) {
    return {
      "questionTitle": question.question,
      "questionId": question.qid,
      "questionAnswer": question.answer?.toString(),
      "isRequired": question.isRequired,
      "answerType": "numeric",
      "questionType": question.questionType,
      "imageData": question.imageData,
    };
  }
}

class OneLinerQuestion extends Question {
  String question;
  String qid;
  String answer = "";
  bool isRequired;

  OneLinerQuestion.fromJson(Map json)
      : question = json['questionTitle'],
        qid = json['questionId'],
        isRequired = json['isRequired'] {
    answer = json.containsKey('questionAnswer') ? json['questionAnswer'] : "";
    questionType = json['questionType'] ?? "";
    imageData = json['imageData'];
  }

  static Map<String, dynamic> toJson(OneLinerQuestion question) {
    return {
      "questionTitle": question.question,
      "questionId": question.qid,
      "questionAnswer": question.answer.toString(),
      "questionType": question.questionType,
      "isRequired": question.isRequired,
      "answerType": "text",
      "imageData": question.imageData,
    };
  }
}

class ImageQuestion extends Question {
  String question;
  String qid;
  List<FileData> imageList = [];
  String? reason;
  bool isRequired;

  ImageQuestion.fromJson(Map json)
      : question = json['questionTitle'],
        qid = json['questionId'],
        reason = json['questionReason'],
        isRequired = json['isRequired'] {
    imageList = json.containsKey('imageList')
        ? json['imageList']
            .map<FileData>((e) => FileData(address: e['address'], id: e['id']))
            .toList()
        : [];
    questionType = json['questionType'] ?? "";
    imageData = json['imageData'];
  }

  static Map<String, dynamic> toJson(ImageQuestion question) {
    return {
      'questionId': question.qid,
      'questionAnswer': question.imageList.map((e) => e.id).toList(),
      'imageList': question.imageList
          .map((e) => {'id': e.id, 'address': e.address})
          .toList(),
      'answerType': "image",
      'questionReason': question.reason,
      "questionTitle": question.question,
      "isRequired": question.isRequired,
      "questionType": question.questionType,
      "imageData": question.imageData,
    };
  }
}

class VideoQuestion extends Question {
  String question;
  String qid;
  String? reason;
  List<FileData> videoList = [];
  bool isRequired;

  VideoQuestion.fromJson(Map json)
      : question = json['questionTitle'],
        qid = json['questionId'],
        reason = json['questionReason'],
        isRequired = json['isRequired'] {
    if (json.containsKey('videoList') && json['videoList'] is List) {
      videoList = (json['videoList'] as List)
          .map<FileData>((e) => FileData(
                address: e['address'] ?? '',
                id: e['id'],
              ))
          .toList();
    } else if (json.containsKey('questionAnswer') &&
        json['questionAnswer'] is List) {
      videoList = (json['questionAnswer'] as List)
          .map<FileData>((e) => FileData(
                address: e['address'] ?? '',
                id: e['id'],
              ))
          .toList();
    } else {
      videoList = [];
    }
    questionType = json['questionType'] ?? "";
    imageData = json['imageData'];
  }

  static Map<String, dynamic> toJson(VideoQuestion question) {
    return {
      'questionId': question.qid,
      "questionTitle": question.question,
      'questionAnswer': question.videoList.map<String?>((e) => e.id).toList(),
      "questionReason": question.reason,
      'videoList': question.videoList
          .map((e) => {'id': e.id, 'address': e.address})
          .toList(),
      'answerType': "video",
      "isRequired": question.isRequired,
      "questionType": question.questionType,
      "imageData": question.imageData,
    };
  }
}

class FileData {
  String? id;
  String address;
  UploadStatus uploadStatus = UploadStatus.UPLOADING;
  double progress = 0;

  FileData({required this.address, this.id});
}
