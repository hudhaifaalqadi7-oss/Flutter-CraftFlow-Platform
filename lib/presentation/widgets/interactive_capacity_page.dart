import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/entities/workshop.dart';
import '../state/app_store.dart';
import 'workshop_media.dart';

class InteractiveCapacityPage extends StatefulWidget {
  const InteractiveCapacityPage({required this.workshop, super.key});

  final Workshop workshop;

  @override
  State<InteractiveCapacityPage> createState() => _InteractiveCapacityPageState();
}

class _InteractiveCapacityPageState extends State<InteractiveCapacityPage> {
  int selectedIndex = 0;
  bool availableOnly = false;

  List<_CapacityNode> get nodes {
    switch (widget.workshop.id) {
      case 'carpentry':
        return const [_CapacityNode('ورشة الأرز للنجارة المتطورة', '2.4 كم', .25, 'جاهزة للبدء', 'تسليم أسرع'), _CapacityNode('مصنع الأثاث الراقي الحديث', '4.1 كم', .65, 'ضغط متوسط', 'موعد اعتيادي'), _CapacityNode('ورشة سنديان للحرف اليدوية', '1.8 كم', .90, 'ضغط مرتفع', 'قد يتأخر التسليم')];
      case 'blacksmith':
        return const [_CapacityNode('مصنع الفولاذ الفني لقص الليزر', '3.2 كم', .15, 'ماكينتان متاحتان', 'جاهز للبرمجة'), _CapacityNode('المصنع الهندسي للحديد المشغول', '5.6 كم', .85, 'صيانة جزئية', 'تأخير محتمل'), _CapacityNode('ورشة الدقة للبوابات', '7.4 كم', .48, 'متاح للحجز', 'موعد اعتيادي')];
      default:
        return const [_CapacityNode('ورشة التيسير الآلية للألمنيوم', '2.1 كم', .33, 'كبس زاوية آلي', 'جاهز للعزل'), _CapacityNode('مصنع الواجهات الزجاجية', '4.8 كم', .58, 'خط تجميع متاح', 'موعد اعتيادي'), _CapacityNode('ورشة قطاعات الروشان', '6.3 كم', .88, 'ضغط مرتفع', 'موعد متأخر')];
    }
  }

  List<_CapacityNode> get visibleNodes => nodes.where((node) => !availableOnly || node.load < .7).toList();

  @override
  Widget build(BuildContext context) {
    final visible = visibleNodes;
    final selected = visible.isEmpty ? null : visible.firstWhere((node) => node == nodes[selectedIndex.clamp(0, nodes.length - 1)], orElse: () => visible.first);
    return ListView(padding: const EdgeInsets.fromLTRB(20, 16, 20, 28), children: [
      _hero(),
      const SizedBox(height: 16),
      Row(children: [Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('اختيار الورشة الأنسب', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900, color: primary)), const Text('قارن السعة والمسافة قبل توجيه الطلب', style: TextStyle(color: textMuted, fontSize: 12))])), FilterChip(label: const Text('المتاح فقط'), selected: availableOnly, onSelected: (_) => setState(() => availableOnly = !availableOnly))]),
      const SizedBox(height: 14),
      if (visible.isEmpty) const Padding(padding: EdgeInsets.all(28), child: Center(child: Text('لا توجد ورش متاحة حالياً', style: TextStyle(color: textMuted)))) else ...[
        ...visible.asMap().entries.map((entry) => _nodeCard(entry.value, entry.value == selected, () => setState(() => selectedIndex = nodes.indexOf(entry.value)))),
        const SizedBox(height: 8),
        FilledButton.icon(onPressed: selected == null ? null : () => _confirm(context, selected), icon: const Icon(Icons.alt_route), label: Text('توجيه الطلب إلى ${selected?.title ?? 'الورشة المختارة'}')),
      ],
    ]);
  }

  Widget _hero() => SizedBox(height: 135, child: ClipRRect(borderRadius: BorderRadius.circular(20), child: Stack(fit: StackFit.expand, children: [CraftImage(url: WorkshopMedia.heroFor(widget.workshop), fit: BoxFit.cover, fallbackColor: widget.workshop.color), DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, Colors.black.withValues(alpha: .8)]))), const Positioned(right: 16, bottom: 14, child: Text('توزيع ذكي للأحمال', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900)))])));

  Widget _nodeCard(_CapacityNode node, bool selected, VoidCallback onTap) {
    final color = node.load < .5 ? successColor : (node.load < .75 ? warningColor : dangerColor);
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            children: [
              Row(
                children: [
                  Radio<bool>(value: true, groupValue: selected, onChanged: (_) => onTap(), activeColor: widget.workshop.color),
                  Expanded(child: Text(node.title, style: const TextStyle(fontWeight: FontWeight.w900, color: primary))),
                  Text(node.distance, style: const TextStyle(color: textMuted, fontSize: 11)),
                ],
              ),
              Row(
                children: [
                  Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(8), child: LinearProgressIndicator(value: node.load, minHeight: 8, color: color, backgroundColor: color.withValues(alpha: .12)))),
                  const SizedBox(width: 10),
                  Text('${(node.load * 100).round()}%', style: TextStyle(color: color, fontWeight: FontWeight.w900)),
                ],
              ),
              const SizedBox(height: 8),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(node.status, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)), Text(node.note, style: const TextStyle(color: textMuted, fontSize: 10))]),
            ],
          ),
        ),
      ),
    );
  }

  void _confirm(BuildContext context, _CapacityNode node) => showDialog<void>(context: context, builder: (dialogContext) => AlertDialog(title: const Text('تأكيد التوجيه'), content: Text('سيتم تجهيز الطلب مبدئياً لدى ${node.title} بسبب توفر ${(node.load * 100).round()}% من الطاقة.'), actions: [TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('إلغاء')), FilledButton(onPressed: () async { Navigator.pop(dialogContext); final saved = await StoreScope.of(context).recordEvent(type: 'capacity_routing', workshopId: widget.workshop.id, payload: node.title); if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(saved ? 'تم حفظ توجيه الطلب إلى ${node.title}' : 'تعذر حفظ التوجيه'))); }, child: const Text('تأكيد'))]));
}

class _CapacityNode {
  const _CapacityNode(this.title, this.distance, this.load, this.status, this.note);
  final String title;
  final String distance;
  final double load;
  final String status;
  final String note;
}
