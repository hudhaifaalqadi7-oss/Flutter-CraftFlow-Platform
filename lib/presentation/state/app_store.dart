import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import '../../data/repositories/local_app_repository.dart';
import '../../domain/entities/app_models.dart';
import '../../domain/entities/workshop.dart';

class AppStore extends ChangeNotifier {
  AppStore({LocalAppRepository? repository}) : repository = repository ?? const LocalAppRepository();

  final LocalAppRepository repository;
  Workshop? workshop;
  List<CraftOrder> orders = [];
  List<InventoryItem> inventory = [];
  bool loading = false;
  Object? error;

  Future<void> load(Workshop selectedWorkshop) async {
    workshop = selectedWorkshop;
    loading = true;
    error = null;
    notifyListeners();
    try {
      orders = await repository.loadOrders(selectedWorkshop.id);
      inventory = await repository.loadInventory(selectedWorkshop.id);
    } catch (exception) {
      error = exception;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> addOrder(CraftOrder order) async {
    await repository.saveOrder(order);
    orders = [...orders, order];
    notifyListeners();
  }

  Future<void> updateOrderStatus(CraftOrder order, String status) async {
    order.status = status;
    await repository.updateOrder(order);
    notifyListeners();
  }

  Future<void> adjustInventory(InventoryItem item, double amount) async {
    item.quantity = (item.quantity + amount).clamp(0, 999999).toDouble();
    if (workshop != null) await repository.saveInventory(workshop!.id, inventory);
    notifyListeners();
  }
}

class StoreScope extends InheritedNotifier<AppStore> {
  const StoreScope({required super.notifier, required super.child, super.key});

  static AppStore of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<StoreScope>();
    if (scope?.notifier == null) throw StateError('StoreScope is missing above this widget');
    return scope!.notifier!;
  }
}
