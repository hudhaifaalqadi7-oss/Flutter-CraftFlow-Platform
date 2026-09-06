import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/entities/workshop.dart';
import '../../domain/entities/app_models.dart';
import '../../domain/entities/order_statuses.dart';
import '../state/app_store.dart';

class InteractiveOperationsPage extends StatefulWidget {
  const InteractiveOperationsPage({required this.workshop, super.key});
  final Workshop workshop;

  @override
  State<InteractiveOperationsPage> createState() => _InteractiveOperationsPageState();
}

class _InteractiveOperationsPageState extends State<InteractiveOperationsPage> {
  String? selectedOrderId;

  @override
  Widget build(BuildContext context) {
    final store = StoreScope.of(context);
    final orders = store.orders.where((o) => o.workshopId == widget.workshop.id).toList();

    if (orders.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text('لا توجد أوامر عمل مسجلة لهذه الورشة حالياً.\nقم بإنشاء طلب جديد لاختبار التحكم المباشر.', textAlign: TextAlign.center, style: TextStyle(color: textMuted, height: 1.6)),
        ),
      );
    }

    final currentOrder = orders.firstWhere((o) => o.id == selectedOrderId, orElse: () => orders.first);

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('اختر أمر العمل', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: textMuted)),
            DropdownButton<String>(
              value: currentOrder.id,
              underline: const SizedBox(),
              items: orders.map((o) => DropdownMenuItem(value: o.id, child: Text(o.name, style: const TextStyle(fontWeight: FontWeight.bold, color: primary)))).toList(),
              onChanged: (id) => setState(() => selectedOrderId = id),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0x11114B5F))),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(currentOrder.name, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: primary)),
                  const Icon(Icons.construction, color: accent),
                ],
              ),
              const SizedBox(height: 6),
              Text('الخامة: ${currentOrder.material}', style: const TextStyle(fontSize: 12.5, color: textMuted)),
              Text('المقاسات: ${currentOrder.length.toInt()} × ${currentOrder.width.toInt()} سم', style: const TextStyle(fontSize: 12, color: textMuted)),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                decoration: BoxDecoration(color: accent.withOpacity(0.12), borderRadius: BorderRadius.circular(8)),
                child: Text('الحالة الحالية: ${currentOrder.status}', textAlign: TextAlign.center, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: primary)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const Text('تحديث الحالة بضغطة واحدة', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: primary)),
        const SizedBox(height: 12),
        _buildActionBtn(OrderStatuses.inProgress, Icons.play_arrow, accent, () => _updateStatus(context, store, currentOrder, OrderStatuses.inProgress)),
        _buildActionBtn(OrderStatuses.qualityCheck, Icons.verified_outlined, const Color(0xFF8D5B4C), () => _updateStatus(context, store, currentOrder, OrderStatuses.qualityCheck)),
        _buildActionBtn(OrderStatuses.readyForDelivery, Icons.local_shipping, successColor, () => _updateStatus(context, store, currentOrder, OrderStatuses.readyForDelivery)),
        _buildActionBtn(OrderStatuses.completed, Icons.task_alt, Colors.green, () => _updateStatus(context, store, currentOrder, OrderStatuses.completed)),
        _buildActionBtn(OrderStatuses.cancelled, Icons.cancel_outlined, Colors.red, () => _updateStatus(context, store, currentOrder, OrderStatuses.cancelled)),
        const SizedBox(height: 14),
        OutlinedButton.icon(
          onPressed: () async {
            final saved = await store.recordEvent(type: 'production_snapshot', workshopId: widget.workshop.id, orderId: currentOrder.id);
            if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(saved ? 'تم حفظ لقطة الإنتاج وبثها للعميل' : 'تعذر حفظ لقطة الإنتاج')));
          },
          style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          icon: const Icon(Icons.camera_alt),
          label: const Text('التقاط صورة العمل الحالية وبثها'),
        ),
      ],
    );
  }

  Widget _buildActionBtn(String title, IconData icon, Color bg, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      width: double.infinity,
      height: 54,
      child: FilledButton.icon(
        onPressed: onTap,
        style: FilledButton.styleFrom(backgroundColor: bg, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
        icon: Icon(icon, size: 22),
        label: Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Future<void> _updateStatus(BuildContext context, AppStore store, CraftOrder order, String newStatus) async {
    final success = await store.updateOrderStatus(order, newStatus);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(success ? 'تم تحديث حالة الطلب إلى: $newStatus بنجاح' : 'تم تحديث الحالة محلياً وجاري المزامنة')),
      );
    }
  }
}
