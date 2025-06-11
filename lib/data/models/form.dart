import 'page.dart';

class SurveyForm {
  String? sid;
  String cycle;
  Map storeCoordinates = {'latitude': null, 'longitude': null};
  List<PageData> pages;

  SurveyForm.fromJson(Map json)
      : pages =
            json['pages'].map<PageData>((e) => PageData.fromJson(e)).toList(),
        sid = json.containsKey('storeId') ? json['storeId'] : null,
        storeCoordinates = json.containsKey('storeCoordinates') ? json['storeCoordinates'] :  {'latitude': null, 'longitude': null},
        cycle = json['cycleId'];

  static Map<String, dynamic> toJson(SurveyForm form) {
    return {
      "storeId": form.sid ?? "",
      "pages": form.pages.map((page) => PageData.toJson(page)).toList(),
      "storeCoordinates": {
        'latitude': form.storeCoordinates['latitude'],
        'longitude': form.storeCoordinates['longitude']
      },
      "cycleId": form.cycle,
    };
  }
}
