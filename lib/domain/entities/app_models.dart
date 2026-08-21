class CraftOrder {
  CraftOrder({required this.id, required this.workshopId, required this.name, required this.description, required this.material, required this.length, required this.width, this.status = 'جديد', this.attachmentAdded = false});

  final String id;
  final String workshopId;
  final String name;
  final String description;
  final String material;
  final double length;
  final double width;
  String status;
  bool attachmentAdded;

  Map<String, dynamic> toJson() => {'id': id, 'workshopId': workshopId, 'name': name, 'description': description, 'material': material, 'length': length, 'width': width, 'status': status, 'attachmentAdded': attachmentAdded};

  factory CraftOrder.fromJson(Map<String, dynamic> json) => CraftOrder(id: json['id'] as String, workshopId: json['workshopId'] as String, name: json['name'] as String, description: json['description'] as String, material: json['material'] as String, length: (json['length'] as num).toDouble(), width: (json['width'] as num).toDouble(), status: json['status'] as String? ?? 'جديد', attachmentAdded: json['attachmentAdded'] as bool? ?? false);
}

class InventoryItem {
  InventoryItem({required this.name, required this.unit, required this.quantity, required this.minimum});

  final String name;
  final String unit;
  double quantity;
  final double minimum;

  bool get lowStock => quantity <= minimum;
  Map<String, dynamic> toJson() => {'name': name, 'unit': unit, 'quantity': quantity, 'minimum': minimum};
  factory InventoryItem.fromJson(Map<String, dynamic> json) => InventoryItem(name: json['name'] as String, unit: json['unit'] as String, quantity: (json['quantity'] as num).toDouble(), minimum: (json['minimum'] as num).toDouble());
}
