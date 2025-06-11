import 'package:shared_preferences/shared_preferences.dart';
import 'package:surveyapp/helpers/strings.dart';
import 'package:surveyapp/data/models/user.dart';
import 'package:surveyapp/data/network_services/user.dart';

class UserRepository {
  final UserNetworkService userNetworkService;

  UserRepository({required this.userNetworkService});

  Future<bool> isLoggedIn() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final bool loggedIn = prefs.getBool(LOGGED_IN) ?? false;
    return loggedIn;
  }

  void setLoggedIn(bool loggedIn) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if(loggedIn)
      prefs.setBool(LOGGED_IN, loggedIn);
    else
      await prefs.clear();

  }

  void setRefreshToken(String refreshToken) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(REFRESH_TOKEN, refreshToken);
  }

  Future<Map> loginUser(String username, String password) async {
    Map<String, String> creds = {
      "agentCode": username,
      "agentPassword": password
    };

    var data = await userNetworkService.loginUser(creds);

    if(data['success'])
      setRefreshToken(data['refreshToken']);
    return data;
  }

  Future<Map> logoutUser() async {
    var data = await userNetworkService.logoutUser();
    return data;
  }

  Future<dynamic> getUserData() async {
    var data = await userNetworkService.getUserDetails();
    if (data['success'])
      return User.fromJson(data);
    else
      return data;
  }
}
