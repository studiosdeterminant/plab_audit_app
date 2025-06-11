class Store {
  String name, address, sid, location, storeCode, area, pincode;
  double latitude, longitude;
  bool isSubmitted;

  Store.fromJson(Map json)
      : name = json["storeTitle"] ?? "",
        address = json['storeAddress'] ?? "",
        isSubmitted = json['audited'],
        latitude = (json['storeCoordinates'].containsKey('latitude'))
            ? json['storeCoordinates']['latitude']
            : 0,
        longitude = (json['storeCoordinates'].containsKey('longitude'))
            ? json['storeCoordinates']['longitude']
            : 0,
        location = json['storeLocation'] ?? "",
        area = json['storeArea'] ?? "",
        pincode = json['storePincode']?.toString() ?? "",
        storeCode = json['storeCode'] ?? "",
        sid = json["storeId"];
}
