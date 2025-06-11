import 'package:dio/dio.dart';
import 'package:surveyapp/data/network_services/network_client/dio_client.dart';
import 'package:surveyapp/helpers/strings.dart';

class UserNetworkService {
  final baseUrl = BASE_URL;

  Future<Map> loginUser(Map<String, String> creds) async {
    try {
      final response =
          await (await DioClient.dio).post("/auth/login", data: creds);
      final Map data = response.data;
      data['success'] = true;
      return data;
    } on DioException catch (e) {
      if(e.response != null)
        if(e.response!.data is Map && e.response!.data.containsKey('msg')){
          final Map data = {
            'success': false,
            'error': e.response!.data['msg'] ?? "Something went wrong",
          };
          return data;
        }

      return {'success': false, 'error': 'Something went wrong'};

    } catch (e) {
      return {'success': false, 'error': 'Something went wrong'};
    }
  }

  Future<Map> logoutUser() async {
    try {
      final response = await (await DioClient.dio).post("/auth/logout");
      final Map data = response.data;
      data['success'] = true;
      return data;
    } on DioError catch (e) {
      if(e.response != null)
        if(e.response!.data is Map && e.response!.data.containsKey('msg')){
          final Map data = {
            'success': false,
            'error': e.response!.data['msg'] ?? "Something went wrong",
          };
          return data;
        }

      return {'success': false, 'error': 'Something went wrong'};

    } catch (e) {
      return {'success': false, 'error': 'Something went wrong'};
    }
  }

  Future<Map> getUserDetails() async {
    try {
      final response = await (await DioClient.dio).get("/agent");
      final Map data = response.data;
      data['success'] = true;
      return data;
    }  on DioError catch (e) {
      if(e.response != null)
        if(e.response!.data is Map && e.response!.data.containsKey('msg')){
          final Map data = {
            'success': false,
            'error': e.response!.data['msg'] ?? "Something went wrong",
          };
          return data;
        }

      return {'success': false, 'error': 'Something went wrong'};

    } catch (e) {
      return {'success': false, 'error': 'Something went wrong'};
    }
  }
}
