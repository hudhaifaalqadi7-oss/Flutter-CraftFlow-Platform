import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  const ApiService();

  Future<Map<String, dynamic>> getWorkshopSummary(String workshop) async {
    try {
      final response = await http.get(Uri.parse('https://api.craftflow.example/workshops/$workshop'));
      if (response.statusCode == 200) return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {}
    return {'openOrders': 12, 'completion': 78, 'stock': 64};
  }
}
