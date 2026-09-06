import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/entities/app_models.dart';
import '../../domain/entities/workshop.dart';
import '../state/app_store.dart';
import 'workshop_media.dart';

class InteractiveInventoryPage extends StatefulWidget {
  const InteractiveInventoryPage({required this.workshop, super.key});

  final Workshop workshop;

  @override
  State<InteractiveInventoryPage> createState() => _InteractiveInventoryPageState();
}

class _InteractiveInventoryPageState extends State<InteractiveInventoryPage> {
  final searchController = TextEditingController();
  bool lowStockOnly = false;

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = StoreScope.of(context);
    final items = store.inventory.where((item) {
      final query = searchController.text.trim();
      return (query.isEmpty || item.name.contains(query)) && (!lowStockOnly || item.lowStock);
    }).toList();
    final lowCount = store.inventory.where((item) => item.lowStock).length;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      children: [
        _hero(),
        const SizedBox(height: 16),
        Row(children: [Expanded(child: Text('مخزون ${widget.workshop.name}', style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w900, color: primary))), IconButton.filledTonal(onPressed: () => setState(() => lowStockOnly = !lowStockOnly), icon: Icon(lowStockOnly ? Icons.warning : Icons.warning_amber_outlined), tooltip: 'المواد الناقصة')]),
        const SizedBox(height: 4),
        Text('$lowCount مواد تحتاج إلى متابعة', style: TextStyle(color: lowCount > 0 ? dangerColor : successColor, fontSize: 12, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        TextField(controller: searchController, onChanged: (_) => setState(() {}), decoration: InputDecoration(hintText: 'ابحث عن مادة أو خامة...', prefixIcon: const Icon(Icons.search), suffixIcon: searchController.text.isEmpty ? null : IconButton(onPressed: () { searchController.clear(); setState(() {}); }, icon: const Icon(Icons.close)), filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none))),
        const SizedBox(height: 16),
        if (items.isEmpty)
          _emptyState(store.inventory.isEmpty)
        else
          ...items.map((item) => _stockCard(context, store, item)),
      ],
    );
  }

  Widget _hero() => SizedBox(height: 135, child: ClipRRect(borderRadius: BorderRadius.circular(20), child: Stack(fit: StackFit.expand, children: [CraftImage(url: WorkshopMedia.heroFor(widget.workshop), fit: BoxFit.cover, fallbackColor: widget.workshop.color), DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, Colors.black.withValues(alpha: .78)]))), const Positioned(right: 16, bottom: 14, child: Text('كل خامة تحت السيطرة', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900)))])));

  Widget _stockCard(BuildContext context, AppStore store, InventoryItem item) {
    final ratio = item.minimum <= 0 ? 1.0 : (item.quantity / (item.minimum * 3)).clamp(0.0, 1.0);
    final color = item.lowStock ? dangerColor : (ratio < .55 ? warningColor : successColor);
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(padding: const EdgeInsets.all(14), child: Column(children: [
        Row(children: [Expanded(child: Text(item.name, style: const TextStyle(fontWeight: FontWeight.w900, color: primary))), Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: color.withValues(alpha: .12), borderRadius: BorderRadius.circular(8)), child: Text(item.lowStock ? 'نقص' : 'متوفر', style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)))]),
        const SizedBox(height: 10),
        Row(children: [Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(8), child: LinearProgressIndicator(value: ratio, minHeight: 8, color: color, backgroundColor: color.withValues(alpha: .12)))), const SizedBox(width: 12), Text('${item.quantity.toStringAsFixed(0)} ${item.unit}', style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 12))]),
        const SizedBox(height: 9),
        Row(children: [Text('الحد الأدنى: ${item.minimum.toStringAsFixed(0)} ${item.unit}', style: const TextStyle(color: textMuted, fontSize: 10)), const Spacer(), _adjustButton(Icons.remove, () => store.adjustInventory(item, -1)), const SizedBox(width: 6), _adjustButton(Icons.add, () => store.adjustInventory(item, 1)), const SizedBox(width: 4), _adjustButton(Icons.delete_outline, () => store.deleteInventory(item))]),
      ])),
    );
  }

  Widget _adjustButton(IconData icon, VoidCallback onTap) => IconButton(onPressed: onTap, visualDensity: VisualDensity.compact, style: IconButton.styleFrom(backgroundColor: widget.workshop.color.withValues(alpha: .1), foregroundColor: widget.workshop.color), icon: Icon(icon, size: 18));

  Widget _emptyState(bool noInventory) => Padding(padding: const EdgeInsets.all(28), child: Column(children: [Icon(noInventory ? Icons.inventory_2_outlined : Icons.search_off, size: 46, color: widget.workshop.color), const SizedBox(height: 9), Text(noInventory ? 'لا توجد مواد مسجلة حالياً' : 'لا توجد خامات مطابقة للبحث', style: const TextStyle(color: textMuted, fontWeight: FontWeight.w700))]));
}
