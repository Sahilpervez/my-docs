import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageRepository{
  void setToken(String token) async{
    SharedPreferences preference =await SharedPreferences.getInstance() ;
    preference.setString("x-auth-token", token);
  }

  Future<String?> getToken() async {
    SharedPreferences preference = await SharedPreferences.getInstance();
    String? token = preference.getString("x-auth-token");
    
    return token;
  }

  void clearToken()async{
    SharedPreferences preference = await SharedPreferences.getInstance();
    preference.remove('x-auth-token');
  }
}