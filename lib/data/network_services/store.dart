import 'dart:async';
import 'package:dio/dio.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:surveyapp/helpers/strings.dart';

import 'network_client/dio_client.dart';

class StoreNetworkService {
  final String baseUrl = BASE_URL;

  Future<List<dynamic>> getStoreList(int pgno) async {
    try {
      var response = await (await DioClient.dio)
          .get("/store/stores", queryParameters: {'pageno': pgno, 'limit': 100});

      return response.data as List<dynamic>;
    } catch (e) {
      return [];
    }
  }

  void cannotAudit(Map<String, String> data) async {
    try {
      Dio dio = await DioClient.dio;
      await dio.post('/audit/cannot', data: data);
      Fluttertoast.showToast(msg: "Reason Submitted");

    } catch (e) {
      Fluttertoast.showToast(msg: "Error while Uploading Reason");
    }
  }

  Future<Map> submitImage(String image) async {
    try {
      var response = await (await DioClient.dio)
          .get('/audit/cannot/image', queryParameters: {'filename': image});

      Map data = response.data;
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

  // Get all clients
  Future<List<Map<String, dynamic>>> getClients() async {
    try {
      final response = await (await DioClient.dio).get("/cycle/clients");
      final data = response.data;

      if (data is List) {
        return List<Map<String, dynamic>>.from(data);
      } else {
        return [];
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Failed to fetch clients");
      return [];
    }
  }

  // Get cycles based on selected clientId
  Future<List<Map<String, dynamic>>> getCycles(String clientId) async {
    try {
      final response = await (await DioClient.dio).get(
        "/cycle/cycles",
        queryParameters: {
          "clientId": clientId,
          "pageno": 0,
          "limit": 100,
        },
      );
      final data = response.data;

      if (data is Map && data.containsKey('cycles')) {
        return List<Map<String, dynamic>>.from(data['cycles']);
      } else {
        return [];
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Failed to fetch cycles");
      return [];
    }
  }

  // Add a new store
  Future<bool> addStore(Map<String, dynamic> payload) async {
    try {
      await (await DioClient.dio).post("/store/add", data: payload);
      return true;
    } catch (e) {
      Fluttertoast.showToast(msg: "Failed to add store");
      return false;
    }
  }
}
