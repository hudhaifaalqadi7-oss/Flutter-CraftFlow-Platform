import 'package:flutter/widgets.dart';
import '../../data/repositories/local_app_repository.dart';
import '../../data/services/api_service.dart';
import '../../domain/entities/app_models.dart';
import '../../domain/entities/workshop.dart';

class AppStore extends ChangeNotifier {
  AppStore({
    LocalAppRepository? repository,
    ApiService? apiService,
  })  : repository = repository ?? const LocalAppRepository(),
        apiService = apiService ?? const ApiService();

  final LocalAppRepository repository;
  final ApiService apiService;

  Future<void> restoreSession() => apiService.restoreToken();

  Workshop? workshop;
  List<CraftOrder> orders = [];
  List<InventoryItem> inventory = [];
  WorkshopSummary summary = WorkshopSummary();

  bool loading = false;
  bool isActionLoading = false;
  Object? error;

  Future<bool> registerAccount({required String name, required String phone, required String password, required bool craftsman, required String workshopId}) {
    return apiService.register(name: name, phone: phone, password: password, role: craftsman ? 'craftsman' : 'customer', workshopId: workshopId);
  }

  Future<bool> loginAccount({required String phone, required String password}) {
    return apiService.login(phone: phone, password: password);
  }

  Future<bool> recordEvent({required String type, required String workshopId, String? orderId, String payload = ''}) {
    return apiService.createWorkflowEvent(type: type, workshopId: workshopId, orderId: orderId, payload: payload);
  }

  Future<void> load(Workshop selectedWorkshop) async {
    workshop = selectedWorkshop;
    loading = true;
    error = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        repository.loadOrders(selectedWorkshop.id),
        repository.loadInventory(selectedWorkshop.id),
        apiService.getWorkshopSummary(selectedWorkshop.id),
      ]);

      orders = results[0] as List<CraftOrder>;
      inventory = results[1] as List<InventoryItem>;
      summary = WorkshopSummary.fromJson(results[2] as Map<String, dynamic>);
    } catch (exception) {
      error = exception;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    if (workshop == null) return;
    try {
      final results = await Future.wait([
        repository.loadOrders(workshop!.id),
        repository.loadInventory(workshop!.id),
        apiService.getWorkshopSummary(workshop!.id),
      ]);

      orders = results[0] as List<CraftOrder>;
      inventory = results[1] as List<InventoryItem>;
      summary = WorkshopSummary.fromJson(results[2] as Map<String, dynamic>);
      error = null;
    } catch (exception) {
      error = exception;
    } finally {
      notifyListeners();
    }
  }

  Future<bool> addOrder(CraftOrder order) async {
    isActionLoading = true;
    error = null;
    notifyListeners();

    try {
      final success = await repository.saveOrder(order);
      if (success) {
        orders = await repository.loadOrders(order.workshopId);
      }
      return success;
    } catch (exception) {
      error = exception;
      return false;
    } finally {
      isActionLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateOrderStatus(CraftOrder order, String newStatus) async {
    isActionLoading = true;
    error = null;
    notifyListeners();

    final updatedOrder = order.copyWith(status: newStatus);

    try {
      final success = await repository.updateOrder(updatedOrder);
      if (success) {
        orders = orders.map((o) => o.id == order.id ? updatedOrder : o).toList();
      }
      return success;
    } catch (exception) {
      error = exception;
      return false;
    } finally {
      isActionLoading = false;
      notifyListeners();
    }
  }

  Future<void> adjustInventory(InventoryItem item, double amount) async {
    final newQuantity = (item.quantity + amount).clamp(0, 999999).toDouble();
    final updatedItem = item.copyWith(quantity: newQuantity);

    if (workshop == null || !await repository.updateInventory(updatedItem, workshop!.id)) return;
    inventory = inventory
        .map((element) => element.id == item.id ? updatedItem : element)
        .toList();
    notifyListeners();
  }

  Future<bool> deleteInventory(InventoryItem item) async {
    if (workshop == null) return false;
    final success = await repository.deleteInventory(item, workshop!.id);
    if (success) inventory = inventory.where((element) => element.id != item.id).toList();
    notifyListeners();
    return success;
  }

  Future<bool> deleteOrder(CraftOrder order) async {
    final success = await repository.deleteOrder(order.id);
    if (success) orders = orders.where((item) => item.id != order.id).toList();
    notifyListeners();
    return success;
  }
}

class StoreScope extends InheritedNotifier<AppStore> {
  const StoreScope({
    required super.notifier,
    required super.child,
    super.key,
  });

  static AppStore of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<StoreScope>();
    if (scope?.notifier == null) {
      throw StateError('StoreScope is missing above this widget');
    }
    return scope!.notifier!;
  }
}
