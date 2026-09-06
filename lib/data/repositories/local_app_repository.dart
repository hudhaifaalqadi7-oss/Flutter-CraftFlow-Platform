import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/app_models.dart';
import '../services/api_service.dart';

class LocalAppRepository {
  final ApiService _apiService;

  const LocalAppRepository({ApiService? apiService})
      : _apiService = apiService ?? const _DefaultApiService();

  Future<List<CraftOrder>> loadOrders(String workshopId) async {
    final preferences = await SharedPreferences.getInstance();
    
    // 1. محاولة جلب البيانات من الـ API
    final remoteData = await _apiService.fetchOrders(workshopId);
    if (remoteData.isNotEmpty) {
      final orders = remoteData.map((e) => CraftOrder.fromJson(e)).toList();
      
      // حفظ البيانات محلياً كـ Cache
      await preferences.setStringList(
        'orders_$workshopId',
        orders.map((item) => jsonEncode(item.toJson())).toList(),
      );
      return orders;
    }

    // 2. الرجوع إلى التخزين المحلي في حال فشل الاتصال أو عدم وجود شبكة
    final raw = preferences.getStringList('orders_$workshopId') ?? <String>[];
    return raw
        .map((value) =>
            CraftOrder.fromJson(jsonDecode(value) as Map<String, dynamic>))
        .toList();
  }

  Future<bool> saveOrder(CraftOrder order) async {
    final preferences = await SharedPreferences.getInstance();
    
    // إرسال للـ API
    final success = await _apiService.createOrder(order.toJson());

    if (success) {
      final orders = await _apiService.fetchOrders(order.workshopId);
      await preferences.setStringList(
        'orders_${order.workshopId}',
        orders.map((item) => jsonEncode(CraftOrder.fromJson(item).toJson())).toList(),
      );
    }

    return success;
  }

  Future<bool> updateOrder(CraftOrder order) async {
    final preferences = await SharedPreferences.getInstance();
    
    // إرسال التحديث للـ API
    final success = await _apiService.updateOrder(order.id, order.toJson());

    if (success) {
      final orders = await loadOrders(order.workshopId);
      final index = orders.indexWhere((item) => item.id == order.id);
      if (index >= 0) orders[index] = order;
      await preferences.setStringList(
        'orders_${order.workshopId}',
        orders.map((item) => jsonEncode(item.toJson())).toList(),
      );
    }

    return success;
  }

  Future<List<InventoryItem>> loadInventory(String workshopId) async {
    final preferences = await SharedPreferences.getInstance();
    
    final remoteData = await _apiService.fetchInventory(workshopId);
    if (remoteData.isNotEmpty) {
      final inventory = remoteData.map((e) => InventoryItem.fromJson(e)).toList();
      await saveInventory(workshopId, inventory);
      return inventory;
    }

    final raw = preferences.getStringList('inventory_$workshopId');
    if (raw != null) {
      return raw
          .map((value) =>
              InventoryItem.fromJson(jsonDecode(value) as Map<String, dynamic>))
          .toList();
    }
    
    return [];
  }

  Future<void> saveInventory(
      String workshopId, List<InventoryItem> inventory) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setStringList(
      'inventory_$workshopId',
      inventory.map((item) => jsonEncode(item.toJson())).toList(),
    );
  }

  Future<bool> updateInventory(InventoryItem item, String workshopId) async {
    final success = await _apiService.updateInventory(item.id, item.quantity);
    if (success) {
      final inventory = await loadInventory(workshopId);
      final updated = inventory.map((entry) => entry.id == item.id ? item : entry).toList();
      await saveInventory(workshopId, updated);
    }
    return success;
  }

  Future<bool> deleteInventory(InventoryItem item, String workshopId) async {
    final success = await _apiService.deleteInventory(item.id);
    if (success) {
      final inventory = await loadInventory(workshopId);
      await saveInventory(workshopId, inventory.where((entry) => entry.id != item.id).toList());
    }
    return success;
  }

  Future<bool> deleteOrder(String orderId) async {
    return _apiService.deleteOrder(orderId);
  }
}

class _DefaultApiService extends ApiService {
  const _DefaultApiService();
}