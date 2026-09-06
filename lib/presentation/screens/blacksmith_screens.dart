import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/entities/workshop.dart';
import '../../domain/entities/app_models.dart';
import '../../domain/entities/order_statuses.dart';
import '../state/app_store.dart';
import '../widgets/order_form.dart';
import '../widgets/order_sheet.dart';

// 1. رئيسية الحدادة (Hub)
class BlacksmithHubScreen extends StatefulWidget {
  const BlacksmithHubScreen(
      {required this.workshop, required this.onNewOrder, super.key});
  final Workshop workshop;
  final VoidCallback onNewOrder;

  @override
  State<BlacksmithHubScreen> createState() => _BlacksmithHubScreenState();
}

class BlacksmithOrderScreen extends StatelessWidget {
  const BlacksmithOrderScreen({required this.workshop, super.key});
  final Workshop workshop;

  @override
  Widget build(BuildContext context) => OrderFormPage(workshop: workshop);
}

class _BlacksmithHubScreenState extends State<BlacksmithHubScreen> {
  String selectedFilter = 'كل تصاميم الحديد';
  String searchQuery = '';

  List<Map<String, dynamic>> get filteredCards {
    final query = searchQuery.trim().toLowerCase();
    final items = [
      {'title': 'أبواب حديد وحمايات', 'sub': 'حديد مشغول وقص ليزر متطور', 'tag': 'قص ليزر', 'image': 'assets/images/8.PNG', 'icon': Icons.door_sliding, 'action': () => showOrderSheet(context, widget.workshop)},
      {'title': 'حمايات نوافذ آمنة', 'sub': 'سماكات مليمترية عالية للمقاومة', 'tag': 'حمايات', 'image': 'assets/images/17.PNG', 'icon': Icons.grid_view, 'action': () => showOrderSheet(context, widget.workshop)},
      {'title': 'مظلات وسواتر معلقة', 'sub': 'هياكل معالجة لمقاومة الصدأ', 'tag': 'مظلات', 'image': 'assets/images/16.PNG', 'icon': Icons.wb_sunny, 'action': () => showOrderSheet(context, widget.workshop)},
      {'title': 'تفصيل حديد مخصص', 'sub': 'تحديد المليمتر ونوع المعجون', 'tag': 'حديد', 'image': null, 'icon': Icons.architecture, 'action': widget.onNewOrder},
    ];

    return items.where((item) {
      final title = (item['title'] as String).toLowerCase();
      final sub = (item['sub'] as String).toLowerCase();
      final tag = (item['tag'] as String).toLowerCase();
      final matchesText = query.isEmpty || title.contains(query) || sub.contains(query) || tag.contains(query);
      final matchesFilter = selectedFilter == 'كل تصاميم الحديد' || tag.contains(selectedFilter.toLowerCase()) || title.contains(selectedFilter.toLowerCase());
      return matchesText && matchesFilter;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final store = StoreScope.of(context);
    final summary = store.summary;
    final cards = filteredCards;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        TextField(
          onChanged: (value) => setState(() => searchQuery = value.trim()),
          textDirection: TextDirection.rtl,
          decoration: InputDecoration(
            hintText: 'ابحث عن أبواب حديد، حمايات نوافذ، مظلات...',
            prefixIcon: const Icon(Icons.search, color: textMuted),
            fillColor: Colors.white,
            filled: true,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0x11114B5F))),
          ),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _chip('كل تصاميم الحديد'),
              _chip('قص ليزر'),
              _chip('حمايات'),
              _chip('مظلات'),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const Text('أقسام ومصنفات تشكيل الحديد',
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.w700, color: primary)),
        const SizedBox(height: 12),
        if (cards.isEmpty)
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0x11114B5F))),
            child: const Center(child: Text('لا توجد تصاميم مطابقة للبحث', style: TextStyle(color: textMuted, fontWeight: FontWeight.w700))),
          )
        else
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            children: cards.map((item) => _catCard(item['title'], item['sub'], item['icon'], item['image'], item['action'])).toList(),
          ),
        const SizedBox(height: 20),
        const Text('الأتمتة الصناعية والقدرات',
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.w700, color: primary)),
        const SizedBox(height: 10),
        _utilityCard(
            'مستعرض السعة الاستيعابية للحدادة',
            'فلترة الورش بناءً على توفر مكائن الليزر (${summary.activeOrders} نشط)',
            Icons.precision_manufacturing),
        _utilityCard(
            'الخط الزمني لتشكيل وتصنيع الحديد',
            'رصد مراحل قص الليزر، اللحام، والمعجون الحراري',
            Icons.account_tree),
      ],
    );
  }

  Widget _chip(String label) {
    final active = selectedFilter == label;
    return InkWell(
      onTap: () => setState(() => selectedFilter = label),
      child: Container(
        margin: const EdgeInsets.only(left: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: active ? primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0x11114B5F)),
        ),
        child: Text(label, style: TextStyle(fontSize: 12, color: active ? Colors.white : textMuted, fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _catCard(String title, String sub, IconData icon, String? img,
          VoidCallback onTap,
          {bool isAccent = false}) =>
      InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border:
                Border.all(color: isAccent ? accent : const Color(0x11114B5F)),
            image: img != null
                ? DecorationImage(
                    image: NetworkImage(img),
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(
                        Colors.black.withOpacity(0.55), BlendMode.darken),
                  )
                : null,
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Icon(icon,
                  color: isAccent
                      ? accent
                      : (img != null ? Colors.white : primary),
                  size: 28),
              const SizedBox(height: 6),
              Text(title,
                  style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: img != null ? Colors.white : textMain)),
              Text(sub,
                  style: TextStyle(
                      fontSize: 10,
                      color: img != null ? Colors.white70 : textMuted),
                  maxLines: 1),
            ],
          ),
        ),
      );

  Widget _utilityCard(String title, String sub, IconData icon) => Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0x11114B5F))),
        child: Row(
          children: [
            Icon(icon, color: accent, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 13.5)),
                  Text(sub,
                      style: const TextStyle(fontSize: 11, color: textMuted)),
                ],
              ),
            ),
          ],
        ),
      );
}

// 2. معرض أعمال الحديد (Portfolio)

// 5. الخط الزمني للتشكيل واللحام (Timeline)
class BlacksmithTimelineScreen extends StatelessWidget {
  const BlacksmithTimelineScreen({required this.workshop, super.key});
  final Workshop workshop;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text('مراحل تشكيل الحديد الناري للطلب #8211',
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.w700, color: primary)),
        const SizedBox(height: 16),
        _step('قص الحديد والصفائح بالكمبيوتر والليزر',
            'اكتمل تفريغ الزخارف الهندسية على صفائح 6 ملم بدقة.', true, false),
        _step('اللحام الهيكلي وتجميع الإطارات الزاوية',
            'تم لحام دعامات التقوية وتأمين المفصلات الضخمة.', true, false),
        _step('الصنفرة، معجون الحديد والتنعيم السطحي',
            'جاري الآن إخفاء آثار اللحام بالمعجون الحراري.', false, true),
        _step('الطلاء الحراري الناري والأساس المقاوم',
            'تثبيت اللون واللمعة وبخ الإيبوكسي العازل النهائي.', false, false),
      ],
    );
  }

  Widget _step(String title, String desc, bool done, bool active) => Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border:
                Border.all(color: active ? accent : const Color(0x11114B5F))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(title,
                  style: const TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 13)),
              Icon(
                  done
                      ? Icons.check_circle
                      : (active ? Icons.sync : Icons.schedule),
                  color: done ? successColor : (active ? accent : textMuted),
                  size: 16)
            ]),
            const SizedBox(height: 4),
            Text(desc,
                style: const TextStyle(fontSize: 11.5, color: textMuted)),
          ],
        ),
      );
}

// 6. لوحة أكشن فرن الحداد (Craftsman UI - Dark Mode)
class BlacksmithCraftsmanScreen extends StatelessWidget {
  const BlacksmithCraftsmanScreen({required this.workshop, super.key});
  final Workshop workshop;

  @override
  Widget build(BuildContext context) {
    final store = StoreScope.of(context);
    final activeOrder = store.orders.isNotEmpty ? store.orders.first : null;

    return Container(
      color: const Color(0xFF121A1E),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Text(
              'لوحة تحكم الحداد الفورية (أزرار صناعية ضخمة لمقاومة الغبار)',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 20),
          _bigBtn(
              context,
              store,
              activeOrder,
              'بدء اللحام الهيكلي الآن 🔥',
              dangerColor,
              Icons.local_fire_department,
              OrderStatuses.inProgress),
          _bigBtn(context, store, activeOrder, 'جاهز ومعجون للطلاء الحراري 🎨',
              successColor, Icons.palette, OrderStatuses.qualityCheck),
          _bigBtn(
              context,
              store,
              activeOrder,
              'جاهز تماماً للتحميل والتركيب 🏗️',
              accent,
              Icons.local_shipping,
              OrderStatuses.readyForDelivery),
        ],
      ),
    );
  }

  Widget _bigBtn(BuildContext context, AppStore store, CraftOrder? order,
          String text, Color col, IconData icon, String stage) =>
      Container(
        margin: const EdgeInsets.only(bottom: 16),
        width: double.infinity,
        height: 84,
        child: ElevatedButton.icon(
          onPressed: () async {
            var success = false;
            if (order != null) {
              success = await store.updateOrderStatus(order, stage);
            }
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(success ? 'تم تحديث حالة الطلب في السيرفر: $stage' : 'تعذر تحديث حالة الطلب')));
          },
          style: ElevatedButton.styleFrom(
              backgroundColor: col,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16))),
          icon: Icon(icon, size: 28),
          label: Text(text,
              style:
                  const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
        ),
      );
}

// 7. جرد مستودع الحديد مع أزرار الإضافة التفاعلية
class BlacksmithInventoryScreen extends StatelessWidget {
  const BlacksmithInventoryScreen({required this.workshop, super.key});
  final Workshop workshop;

  @override
  Widget build(BuildContext context) {
    final store = StoreScope.of(context);
    final inv = store.inventory;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text('إدارة كميات حديد التسليح والأقراص المتاحة بالمخزن',
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.w700, color: primary)),
        const SizedBox(height: 16),
        ...inv.map(
          (item) => Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0x11114B5F))),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.name,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 13.5)),
                    Text('${item.quantity.toInt()} ${item.unit}',
                        style: TextStyle(
                            fontSize: 12,
                            color: item.lowStock ? dangerColor : textMuted,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: () => store.adjustInventory(item, -1)),
                    IconButton(
                        icon: const Icon(Icons.add_circle_outline,
                            color: primary),
                        onPressed: () => store.adjustInventory(item, 1)),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        FilledButton(
            onPressed: () async { final saved = await store.recordEvent(type: 'supply_request', workshopId: workshop.id, payload: 'urgent'); if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(saved ? 'تم حفظ طلب الإمداد' : 'تعذر حفظ طلب الإمداد'))); },
          style: FilledButton.styleFrom(
              backgroundColor: primary,
              padding: const EdgeInsets.symmetric(vertical: 14)),
          child: const Text('طلب إمداد فوري للمستودع الصناعي',
              style: TextStyle(fontWeight: FontWeight.w700)),
        ),
      ],
    );
  }
}

// 8. تنسيق التسليم والتركيب (Delivery UI)
class BlacksmithDeliveryScreen extends StatefulWidget {
  const BlacksmithDeliveryScreen({required this.workshop, super.key});
  final Workshop workshop;

  @override
  State<BlacksmithDeliveryScreen> createState() =>
      _BlacksmithDeliveryScreenState();
}

class _BlacksmithDeliveryScreenState extends State<BlacksmithDeliveryScreen> {
  final locationController = TextEditingController();
  final scheduleController = TextEditingController();
  String? selectedTeam;

  @override
  void dispose() {
    locationController.dispose();
    scheduleController.dispose();
    super.dispose();
  }

  bool get canSubmit =>
      locationController.text.trim().isNotEmpty &&
      _validSchedule &&
      selectedTeam != null;

  bool get _validSchedule {
    final schedule = DateTime.tryParse(scheduleController.text.trim());
    return schedule != null && schedule.isAfter(DateTime.now());
  }

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('تنسيق مواعيد النقل ورفع حمايات الحديد للموقع',
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w700, color: primary)),
          const SizedBox(height: 16),
          Container(
            height: 140,
            decoration: BoxDecoration(
                color: const Color(0xFFE5E9F0),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0x11114B5F))),
            child: Center(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                  const Icon(Icons.location_on, color: dangerColor, size: 36),
                  const SizedBox(height: 4),
                  Flexible(
                      child: Text(
                          locationController.text.trim().isEmpty
                              ? 'أدخل موقع تركيب الطلب'
                              : locationController.text.trim(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 12))),
                ])),
          ),
          const SizedBox(height: 16),
          TextField(
              controller: locationController,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                  labelText: 'موقع التركيب الكامل',
                  hintText: 'المدينة، الحي، الشارع ورقم المبنى',
                  prefixIcon: const Icon(Icons.location_on_outlined),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)))),
          const SizedBox(height: 12),
          TextField(
              controller: scheduleController,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                  labelText: 'موعد شاحنة النقل والرافعة الهيدروليكية',
                  hintText: '2026-08-25 10:00',
                  prefixIcon: const Icon(Icons.event_outlined),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)))),
          if (scheduleController.text.trim().isNotEmpty && !_validSchedule)
            const Padding(
                padding: EdgeInsets.only(top: 6),
                child: Text('أدخل موعدًا مستقبليًا بصيغة 2026-08-25 10:00',
                    style: TextStyle(color: dangerColor, fontSize: 11))),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
              value: selectedTeam,
              decoration: InputDecoration(
                  labelText: 'العمالة الفنية المطلوبة لعمليات اللحام',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12))),
              items: const [
                DropdownMenuItem(
                    value: 'فريق متخصص لضبط موازين الأبواب الكبرى',
                    child: Text('فريق متخصص لضبط موازين الأبواب الكبرى')),
                DropdownMenuItem(
                    value: 'فريق تركيبات اعتيادي لحمايات النوافذ',
                    child: Text('فريق تركيبات اعتيادي لحمايات النوافذ')),
              ],
              onChanged: (team) => setState(() => selectedTeam = team)),
          const SizedBox(height: 20),
          FilledButton(
              onPressed: canSubmit
                ? () async { final saved = await StoreScope.of(context).recordEvent(type: 'delivery_booking', workshopId: widget.workshop.id, payload: 'address=${locationController.text};schedule=${scheduleController.text};team=$selectedTeam'); if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(saved ? 'تم حفظ موعد النقل والتركيب' : 'تعذر حفظ الموعد'))); }
                  : null,
              style: FilledButton.styleFrom(
                  backgroundColor: accent,
                  foregroundColor: primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12))),
              child: const Text('اعتماد وحجز جدول النقل والتركيب',
                  style: TextStyle(fontWeight: FontWeight.w700))),
        ],
      );
}
