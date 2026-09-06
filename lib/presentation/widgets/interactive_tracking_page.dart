import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/entities/workshop.dart';
import '../../domain/entities/app_models.dart';
import '../../domain/entities/order_statuses.dart';
import '../state/app_store.dart';

class InteractiveTrackingPage extends StatelessWidget {
  const InteractiveTrackingPage({required this.workshop, this.readOnly = false, super.key});
  final Workshop workshop;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    final store = StoreScope.of(context);
    final orders = store.orders.where((o) => o.workshopId == workshop.id).toList();

    if (orders.isEmpty) {
      return const Center(child: Text('لا توجد طلبات جارية لتتبعها.', style: TextStyle(color: textMuted)));
    }

    final order = orders.first;
    final currentStatus = order.status;
    final progress = _calculateProgress(currentStatus);

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0x11114B5F))),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(order.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: primary)),
                  Text('${(progress * 100).toInt()}%', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: accent)),
                ],
              ),
              const SizedBox(height: 4),
              Text('الخامة: ${order.material} | ${order.length.toInt()} × ${order.width.toInt()} سم', style: const TextStyle(fontSize: 11.5, color: textMuted)),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(value: progress, minHeight: 8, color: accent, backgroundColor: primary.withOpacity(0.08)),
              ),
              const SizedBox(height: 8),
              Center(child: Text('الحالة الحالية: $currentStatus', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: primary))),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text(readOnly ? 'مراحل تنفيذ طلبك' : 'مراحل الطلب (اضغط للتحديث المباشر)', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: primary)),
        const SizedBox(height: 12),
        _buildStepTile(context, store, order, OrderStatuses.newOrder, 'تم استلام وتوثيق الطلب في النظام', currentStatus),
        _buildStepTile(context, store, order, OrderStatuses.inProgress, 'جاري التقصيب، القص، والتشكيل الهيكلي', currentStatus),
        _buildStepTile(context, store, order, OrderStatuses.qualityCheck, 'مرحلة الصنفرة، الطلاء، والتركيبات', currentStatus),
        _buildStepTile(context, store, order, OrderStatuses.readyForDelivery, 'اكتمل الإنتاج وتم التغليف للشحن', currentStatus),
        _buildStepTile(context, store, order, OrderStatuses.completed, 'تم التسليم وإغلاق الطلب', currentStatus),
        _buildStepTile(context, store, order, OrderStatuses.cancelled, 'تم إلغاء الطلب', currentStatus),
      ],
    );
  }

  Widget _buildStepTile(BuildContext context, AppStore store, CraftOrder order, String stepName, String desc, String currentStatus) {
    final isDone = _isCompleted(currentStatus, stepName);
    final isCurrent = currentStatus == stepName;

    final tile = Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: isCurrent ? accent : const Color(0x11114B5F), width: isCurrent ? 2 : 1),
        ),
        child: Row(
          children: [
            Icon(isDone ? Icons.check_circle : (isCurrent ? Icons.sync : Icons.radio_button_unchecked), color: isDone ? successColor : (isCurrent ? accent : textMuted)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(stepName, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: isCurrent ? primary : textMain)),
                  Text(desc, style: const TextStyle(fontSize: 11, color: textMuted)),
                ],
              ),
            ),
            if (!readOnly) Icon(Icons.edit, size: 16, color: isCurrent ? accent : textMuted.withOpacity(0.5)),
          ],
        ),
      );

    if (readOnly) {
      return tile;
    }
    return InkWell(
      onTap: () async {
        await store.updateOrderStatus(order, stepName);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('تم نقل الطلب إلى مرحلة: $stepName')));
        }
      },
      child: tile,
    );
  }

  double _calculateProgress(String status) {
    return OrderStatuses.progress(status) / 100;
  }

  bool _isCompleted(String current, String target) {
    const list = OrderStatuses.all;
    final cIdx = list.indexOf(current);
    final tIdx = list.indexOf(target);
    return cIdx >= tIdx && cIdx != -1;
  }
}