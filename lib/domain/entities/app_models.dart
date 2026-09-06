import 'order_statuses.dart';

class CraftOrder {
  CraftOrder({
    required this.id,
    required this.workshopId,
    required this.name,
    required this.description,
    required this.material,
    required this.length,
    required this.width,
    this.depth = 0.0,
    this.status = 'جديد',
    this.filePath,
    this.customerId,
  });

  final String id;
  final String workshopId;
  final String name;
  final String description;
  final String material;
  final double length;
  final double width;
  final double depth;
  final String status;
  final String? filePath;
  final int? customerId;

  CraftOrder copyWith({
    String? id,
    String? workshopId,
    String? name,
    String? description,
    String? material,
    double? length,
    double? width,
    double? depth,
    String? status,
    String? filePath,
    int? customerId,
  }) {
    return CraftOrder(
      id: id ?? this.id,
      workshopId: workshopId ?? this.workshopId,
      name: name ?? this.name,
      description: description ?? this.description,
      material: material ?? this.material,
      length: length ?? this.length,
      width: width ?? this.width,
      depth: depth ?? this.depth,
      status: status ?? this.status,
      filePath: filePath ?? this.filePath,
      customerId: customerId ?? this.customerId,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'workshopId': workshopId,
        'name': name,
        'description': description,
        'material': material,
        'length': length,
        'width': width,
        'depth': depth,
        'status': status,
        'filePath': filePath,
        'customerId': customerId,
      };

  factory CraftOrder.fromJson(Map<String, dynamic> json) {
    return CraftOrder(
      id: (json['id'] ?? json['Id'] ?? '').toString(),
      workshopId: (json['workshopId'] ?? json['WorkshopId'] ?? '').toString(),
      name: (json['name'] ?? json['Name'] ?? '').toString(),
      description: (json['description'] ?? json['Description'] ?? '').toString(),
      material: (json['material'] ?? json['Material'] ?? '').toString(),
      length: ((json['length'] ?? json['Length'] ?? 0) as num).toDouble(),
      width: ((json['width'] ?? json['Width'] ?? 0) as num).toDouble(),
      depth: ((json['depth'] ?? json['Depth'] ?? 0) as num).toDouble(),
      status: _normalizeStatus((json['status'] ?? json['Status'] ?? OrderStatuses.newOrder).toString()),
      filePath: json['filePath'] as String? ?? json['FilePath'] as String?,
      customerId: _asInt(json['customerId'] ?? json['CustomerId']),
    );
  }

  static int? _asInt(dynamic value) => value is num ? value.toInt() : int.tryParse(value?.toString() ?? '');

  static String _normalizeStatus(String status) {
    switch (status) {
      case 'Pending':
      case 'New':
        return OrderStatuses.newOrder;
      case 'InProgress':
        return OrderStatuses.inProgress;
      case 'QualityCheck':
        return OrderStatuses.qualityCheck;
      case 'ReadyForDelivery':
        return OrderStatuses.readyForDelivery;
      case 'Completed':
        return OrderStatuses.completed;
      case 'Cancelled':
      case 'Canceled':
        return OrderStatuses.cancelled;
      default:
        return status;
    }
  }
}

class InventoryItem {
  InventoryItem({
    this.id = '',
    required this.name,
    required this.unit,
    required this.quantity,
    required this.minimum,
  });

  final String id;
  final String name;
  final String unit;
  final double quantity;
  final double minimum;

  bool get lowStock => quantity <= minimum;

  InventoryItem copyWith({
    String? id,
    String? name,
    String? unit,
    double? quantity,
    double? minimum,
  }) {
    return InventoryItem(
      id: id ?? this.id,
      name: name ?? this.name,
      unit: unit ?? this.unit,
      quantity: quantity ?? this.quantity,
      minimum: minimum ?? this.minimum,
    );
  }

  Map<String, dynamic> toJson() => {
      'id': id,
        'name': name,
        'unit': unit,
        'quantity': quantity,
        'minimum': minimum,
      };

  factory InventoryItem.fromJson(Map<String, dynamic> json) {
    return InventoryItem(
      id: (json['id'] ?? json['Id'] ?? '').toString(),
      name: (json['name'] ?? json['Name'] ?? '').toString(),
      unit: (json['unit'] ?? json['Unit'] ?? 'وحدة').toString(),
      quantity: ((json['quantity'] ?? json['Quantity'] ?? 0) as num).toDouble(),
      minimum: ((json['minimum'] ?? json['Minimum'] ?? 0) as num).toDouble(),
    );
  }
}

class WorkshopSummary {
  final int totalOrders;
  final int activeOrders;
  final int completedOrders;
  final double efficiencyRate;

  WorkshopSummary({
    this.totalOrders = 0,
    this.activeOrders = 0,
    this.completedOrders = 0,
    this.efficiencyRate = 0.0,
  });

  factory WorkshopSummary.fromJson(Map<String, dynamic> json) {
    return WorkshopSummary(
        totalOrders: _asInt(json['totalOrders'] ?? json['TotalOrders']) ?? 0,
        activeOrders: _asInt(json['activeOrders'] ?? json['ActiveOrders']) ?? 0,
        completedOrders: _asInt(json['completedOrders'] ?? json['CompletedOrders']) ?? 0,
      efficiencyRate:
          ((json['efficiencyRate'] ?? json['EfficiencyRate'] ?? 0) as num)
              .toDouble(),
    );
  }

  static int? _asInt(dynamic value) => value is num ? value.toInt() : int.tryParse(value?.toString() ?? '');
}

class Customer {
  const Customer({required this.id, required this.name, required this.phone, this.email, this.address});
  final int id;
  final String name;
  final String phone;
  final String? email;
  final String? address;

  factory Customer.fromJson(Map<String, dynamic> json) => Customer(
        id: json['id'] is num ? (json['id'] as num).toInt() : int.tryParse((json['id'] ?? json['Id'] ?? '0').toString()) ?? 0,
        name: (json['name'] ?? json['Name'] ?? '').toString(),
        phone: (json['phone'] ?? json['Phone'] ?? '').toString(),
        email: json['email'] as String? ?? json['Email'] as String?,
        address: json['address'] as String? ?? json['Address'] as String?,
      );
}