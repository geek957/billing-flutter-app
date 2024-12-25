import 'Storage.dart';

// config.dart
class Config {
  static final Config _instance = Config._internal();
  factory Config() => _instance;
  Config._internal();

  static String apiUrl = "https://4.240.103.173:5000";
  static String merchantId = "test";
  static String authString = "Chitragupta-ai_d3ce3de3-4570-4ff1-a632-a489beaf3dfd";

  static Future<void> initialize() async {
    apiUrl = await loadApiUrl() ?? apiUrl;
    merchantId = await loadMerchantId() ?? merchantId;
  }

  static Future<void> updateApiUrl(String newUrl) async {
    apiUrl = newUrl;
    await Storage.storeVariable("apiUrl", newUrl);
  }

  static Future<String?> loadApiUrl() async {
    String? url = await Storage.loadVariable("apiUrl");
    return url ?? "https://4.240.103.173:5000";
  }

  static Future<void> updateMerchantId(String newId) async {
    merchantId = newId;
    await Storage.storeVariable("merchantId", newId);
  }

  static Future<String?> loadMerchantId() async {
    String? id = await Storage.loadVariable("merchantId");
    return id ?? "test";
  }
}