import 'dart:async';
import 'package:dio/dio.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path/path.dart';
import 'package:surveyapp/data/models/store.dart';
import 'package:surveyapp/data/network_services/store.dart';

class StoreRepository {
  final StoreNetworkService networkService;

  StoreRepository({
    required this.networkService,
  });

  Future<List<Store>> getStoreList() async {
    List<Store> stores = [];
    int pageno = 0;

    while (true) {
      final data = await networkService.getStoreList(pageno++);

      if (data.length == 0) {
        break;
      }

      final cleanedData = data.where((element) => element['audited'] == false);
      final storeList = cleanedData.map((e) => Store.fromJson(e)).toList();
      stores.addAll(storeList);
    }

    return stores;
  }

  void cannotAudit(String sid, String reason, String image) async {

    if (image.isNotEmpty) {

      var data = await networkService.submitImage(basename(image));

      if (data['success']) {
        Map<String, dynamic> payload = data['fields'];
        payload['file'] =
            await MultipartFile.fromFile(image, filename: basename(image));

        FormData formData = FormData.fromMap(payload);
        var result = await _uploadFile(formData: formData, url: data['url']);

        if (result) {
          image = data['id'];
          networkService.cannotAudit({"storeId": sid, "reason": reason, "image": image});
        } else {
          Fluttertoast.showToast(msg: "Error Occurred While Submitting Reason");
        }
      } else {
        Fluttertoast.showToast(msg: "Error Occurred While Submitting Reason");
      }
    } else {
      networkService.cannotAudit({"storeId": sid, "reason": reason});
    }
  }

  Future<bool> _uploadFile(
      {required FormData formData, required String url}) async {
    try {
      await Dio().post(url, data: formData);
      return true;
    } catch (e) {
      return false;
    }
  }

  // Fetch all clients
  Future<List<Map<String, dynamic>>> getClients() async {
    return await networkService.getClients();
  }

  // Fetch cycles for selected client
  Future<List<Map<String, dynamic>>> getCycles(String clientId) async {
    return await networkService.getCycles(clientId);
  }

  // Add new store
  Future<bool> addStore(Map<String, dynamic> payload) async {
    return await networkService.addStore(payload);
  }
}
