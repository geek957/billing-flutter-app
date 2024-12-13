// config.dart
class Config {
  static final Config _instance = Config._internal();
  factory Config() => _instance;
  Config._internal();

  static String apiUrl = "https://4.240.103.173:5000";

  static void updateApiUrl(String newUrl) {
    apiUrl = newUrl;
  }

  // static String getApiUrl() {
  //   return apiUrl;
  // }
}