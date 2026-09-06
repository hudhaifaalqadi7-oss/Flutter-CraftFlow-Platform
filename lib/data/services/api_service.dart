import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/app_models.dart';

class ApiService {
  const ApiService();

  static String? _token;
  static int? _customerId;
  static String? lastError;

  static String get _configuredBaseUrl => const String.fromEnvironment(
        'CRAFTFLOW_API_URL',
        defaultValue: '',
      );

  Future<void> restoreToken() async {
    final preferences = await SharedPreferences.getInstance();
    _token = preferences.getString('auth_token');
    _customerId = preferences.getInt('customer_id');
  }

  static String get baseUrl {
    if (_configuredBaseUrl.isNotEmpty) {
      return _configuredBaseUrl.replaceFirst(RegExp(r'\/$'), '');
    }
    if (kIsWeb) {
      return "http://localhost:5079/api";
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      return "http://10.0.2.2:5079/api";
    } else {
      return "http://localhost:5079/api";
    }
  }

  static Map<String, String> get _headers => {
        "Accept": "application/json",
        "Content-Type": "application/json",
        if (_token != null) "Authorization": "Bearer $_token",
      };

  Future<bool> register({required String name, required String phone, required String password, required String role, String? workshopId}) async {
    try {
      final response = await http.post(Uri.parse('$baseUrl/auth/register'), headers: _headers, body: json.encode({'name': name, 'phone': phone, 'password': password, 'role': role, 'workshopId': workshopId})).timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) return _saveToken(response.body);
    } catch (e) { lastError = 'تعذر الاتصال بالخادم'; debugPrint('API Error (register): $e'); }
    return false;
  }

  Future<bool> login({required String phone, required String password}) async {
    try {
      final response = await http.post(Uri.parse('$baseUrl/auth/login'), headers: _headers, body: json.encode({'phone': phone, 'password': password})).timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) return _saveToken(response.body);
    } catch (e) { lastError = 'تعذر الاتصال بالخادم'; debugPrint('API Error (login): $e'); }
    return false;
  }

  Future<bool> _saveToken(String body) async {
    final decoded = json.decode(body) as Map<String, dynamic>;
    final token = decoded['token'] as String?;
    if (token == null || token.isEmpty) return false;
    _token = token;
    final user = decoded['user'] as Map<String, dynamic>?;
    _customerId = (user?['customerId'] as num?)?.toInt();
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString('auth_token', token);
    if (_customerId != null) await preferences.setInt('customer_id', _customerId!);
    return true;
  }

  Future<Map<String, dynamic>> getWorkshopSummary(String workshopId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/dashboard/analytics/$workshopId'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        lastError = null;
        return json.decode(response.body) as Map<String, dynamic>;
      }
      lastError = _responseMessage(response.body);
    } catch (e) {
      debugPrint("API Error (getWorkshopSummary): $e");
    }

    return {
      "totalOrders": 0,
      "activeOrders": 0,
      "completedOrders": 0,
      "efficiencyRate": 0.0,
    };
  }

  Future<List<Map<String, dynamic>>> fetchOrders(String workshopId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/orders?workshopId=$workshopId'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        lastError = null;
        final List<dynamic> data = json.decode(response.body);
        return data.cast<Map<String, dynamic>>();
      }
    } catch (e) {
      debugPrint("API Error (fetchOrders): $e");
    }
    return [];
  }

  Future<bool> createOrder(Map<String, dynamic> data) async {
    try {
      final payload = {...data, if (_customerId != null) 'customerId': _customerId};
      final response = await http.post(
        Uri.parse('$baseUrl/orders'),
        headers: _headers,
        body: json.encode(payload),
      ).timeout(const Duration(seconds: 10));
      if (response.statusCode != 200 && response.statusCode != 201) {
        lastError = _responseMessage(response.body);
        debugPrint('API Error (createOrder ${response.statusCode}): ${response.body}');
      }
      if (response.statusCode == 200 || response.statusCode == 201) lastError = null;
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      lastError = 'تعذر الاتصال بالخادم';
      debugPrint("API Error (createOrder): $e");
      return false;
    }
  }

  String _responseMessage(String body) {
    try {
      final decoded = json.decode(body) as Map<String, dynamic>;
      return (decoded['message'] ?? decoded['error'] ?? 'فشل إنشاء الطلب').toString();
    } catch (_) {
      return 'فشل إنشاء الطلب';
    }
  }

  Future<bool> updateOrder(String orderId, Map<String, dynamic> data) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/orders/$orderId'),
        headers: _headers,
        body: json.encode(data),
      );
      if (response.statusCode != 200) lastError = _responseMessage(response.body);
      return response.statusCode == 200;
    } catch (e) {
      debugPrint("API Error (updateOrder): $e");
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> fetchInventory(String workshopId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/inventory?workshopId=$workshopId'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        lastError = null;
        final List<dynamic> data = json.decode(response.body);
        return data.cast<Map<String, dynamic>>();
      }
    } catch (e) {
      debugPrint("API Error (fetchInventory): $e");
    }
    return [];
  }

  Future<bool> updateInventory(String itemId, double quantity) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/inventory/$itemId'),
        headers: _headers,
        body: json.encode({'quantity': quantity}),
      );
      if (response.statusCode != 200) lastError = _responseMessage(response.body);
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('API Error (updateInventory): $e');
      return false;
    }
  }

  Future<bool> deleteInventory(String itemId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/inventory/$itemId'),
        headers: _headers,
      );
      if (response.statusCode != 204) lastError = _responseMessage(response.body);
      return response.statusCode == 204;
    } catch (e) {
      debugPrint('API Error (deleteInventory): $e');
      return false;
    }
  }

  Future<bool> deleteOrder(String orderId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/orders/$orderId'),
        headers: _headers,
      );
      if (response.statusCode != 204) lastError = _responseMessage(response.body);
      return response.statusCode == 204;
    } catch (e) {
      debugPrint('API Error (deleteOrder): $e');
      return false;
    }
  }

  Future<Customer?> createCustomer({required String name, required String phone}) async {
    try {
      final response = await http.post(Uri.parse('$baseUrl/customers'), headers: _headers, body: json.encode({'name': name, 'phone': phone}));
      if (response.statusCode == 201 || response.statusCode == 200) {
        return Customer.fromJson(json.decode(response.body) as Map<String, dynamic>);
      }
    } catch (e) {
      debugPrint('API Error (createCustomer): $e');
    }
    return null;
  }

  Future<String?> uploadFile({required String name, required List<int> bytes}) async {
    try {
      final request = http.MultipartRequest('POST', Uri.parse('$baseUrl/files/upload?folder=designs'));
      request.headers['Accept'] = 'application/json';
      if (_token != null) request.headers['Authorization'] = 'Bearer $_token';
      request.files.add(http.MultipartFile.fromBytes('file', bytes, filename: name));
      final response = await request.send();
      if (response.statusCode == 200) {
        lastError = null;
        final body = await response.stream.bytesToString();
        return (json.decode(body) as Map<String, dynamic>)['filePath'] as String?;
      }
      lastError = _responseMessage(await response.stream.bytesToString());
    } catch (e) {
      debugPrint('API Error (uploadFile): $e');
    }
    return null;
  }

  Future<bool> createWorkflowEvent({required String type, required String workshopId, String? orderId, String payload = ''}) async {
    try {
      final response = await http.post(Uri.parse('$baseUrl/workflowevents'), headers: _headers, body: json.encode({
        'type': type, 'workshopId': workshopId, 'orderId': int.tryParse(orderId ?? ''), 'payload': payload,
      }));
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('API Error (createWorkflowEvent): $e');
      return false;
    }
  }
}