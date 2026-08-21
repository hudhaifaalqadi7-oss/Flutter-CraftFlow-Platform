import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/app_models.dart';

class LocalAppRepository {
  const LocalAppRepository();

  Future<List<CraftOrder>> loadOrders(String workshopId) async {
    final preferences = await SharedPreferences.getInstance();
    final raw = preferences.getStringList('orders_$workshopId') ?? <String>[];
    return raw.map((value) => CraftOrder.fromJson(jsonDecode(value) as Map<String, dynamic>)).toList();
  }

  Future<void> saveOrder(CraftOrder order) async {
    final preferences = await SharedPreferences.getInstance();
    final orders = await loadOrders(order.workshopId);
    orders.add(order);
    await preferences.setStringList('orders_${order.workshopId}', orders.map((item) => jsonEncode(item.toJson())).toList());
  }

  Future<void> updateOrder(CraftOrder order) async {
    final preferences = await SharedPreferences.getInstance();
    final orders = await loadOrders(order.workshopId);
    final index = orders.indexWhere((item) => item.id == order.id);
    if (index >= 0) orders[index] = order;
    await preferences.setStringList('orders_${order.workshopId}', orders.map((item) => jsonEncode(item.toJson())).toList());
  }

  Future<List<InventoryItem>> loadInventory(String workshopId) async {
    final preferences = await SharedPreferences.getInstance();
    final raw = preferences.getStringList('inventory_$workshopId');
    if (raw != null) return raw.map((value) => InventoryItem.fromJson(jsonDecode(value) as Map<String, dynamic>)).toList();
    return [InventoryItem(name: workshopId == 'aluminum' ? 'قطاعات حرارية' : 'خامات أساسية', unit: 'وحدة', quantity: 42, minimum: 10), InventoryItem(name: 'مواد تثبيت وتشطيب', unit: 'وحدة', quantity: 18, minimum: 8)];
  }

  Future<void> saveInventory(String workshopId, List<InventoryItem> inventory) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setStringList('inventory_$workshopId', inventory.map((item) => jsonEncode(item.toJson())).toList());
  }
}
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/app_models.dart';

class LocalAppRepository {
  const LocalAppRepository();

  Future<List<CraftOrder>> loadOrders() async {
    final preferences = await SharedPreferences.getInstance();
    final raw = preferences.getStringList('craftflow_orders') ?? [];
    return raw.map((item) => CraftOrder.fromJson(jsonDecode(item) as Map<String, dynamic>)).toList();
  }

  Future<void> saveOrder(CraftOrder order) async {
    final preferences = await SharedPreferences.getInstance();
    final orders = await loadOrders();
    orders.removeWhere((item) => item.id == order.id);
    orders.add(order);
    await preferences.setStringList('craftflow_orders', orders.map((item) => jsonEncode(item.toJson())).toList());
  }

  Future<List<InventoryItem>> loadInventory(String workshopId) async {
    final preferences = await SharedPreferences.getInstance();
    final raw = preferences.getStringList('craftflow_inventory_$workshopId');
    if (raw != null) return raw.map((item) => InventoryItem.fromJson(jsonDecode(item) as Map<String, dynamic>)).toList();
    return [InventoryItem(name: workshopId == 'aluminum' ? 'قطاعات حرارية' : 'مواد خام أساسية', unit: 'وحدة', quantity: 42, minimum: 10), InventoryItem(name: 'مواد تثبيت وتشطيب', unit: 'وحدة', quantity: 18, minimum: 8)];
  }

  Future<void> saveInventory(String workshopId, List<InventoryItem> items) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setStringList('craftflow_inventory_$workshopId', items.map((item) => jsonEncode(item.toJson())).toList());
  }
}
