import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/entities/workshop.dart';
import '../../domain/entities/app_models.dart';
import '../state/app_store.dart';
import '../../domain/entities/order_statuses.dart';
import '../widgets/order_form.dart';
import '../widgets/order_sheet.dart';

// 1. رئيسية النجارة (تمت إزالة الشريط المكرر وتفعيل الفلترة والبطاقات)
class CarpentryHubScreen extends StatefulWidget {
  const CarpentryHubScreen({required this.workshop, required this.onNewOrder, super.key});
  final Workshop workshop;
  final VoidCallback onNewOrder;

  @override
  State<CarpentryHubScreen> createState() => _CarpentryHubScreenState();
}

class _CarpentryHubScreenState extends State<CarpentryHubScreen> {
  String selectedFilter = 'كل أنواع الأخشاب';
  String searchQuery = '';

  List<Map<String, dynamic>> get filteredCards {
    final query = searchQuery.trim().toLowerCase();
    final items = [
      {'title': 'غرف النوم الكاملة', 'sub': 'تصاميم كلاسيك ومودرن', 'tag': 'خشب زان', 'image': 'assets/images/12.PNG', 'icon': Icons.bed, 'action': () => showOrderSheet(context, widget.workshop)},
      {'title': 'أبواب رئيسية وفخمة', 'sub': 'خشب زان وصاج مقاوم', 'tag': 'خشب زان', 'image': 'assets/images/7.PNG', 'icon': Icons.door_front_door, 'action': () => showOrderSheet(context, widget.workshop)},
      {'title': 'مطابخ خشبية مدمجة', 'sub': 'تفصيل واستغلال مساحات', 'tag': 'خشب صاج', 'image': 'assets/images/14.PNG', 'icon': Icons.kitchen, 'action': () => showOrderSheet(context, widget.workshop)},
      {'title': 'طلب تفصيل مخصص', 'sub': 'ارفع مقاساتك وأوتوكاد', 'tag': 'خشب ميرندي', 'image': null, 'icon': Icons.tune, 'action': widget.onNewOrder},
    ];

    return items.where((item) {
      final title = (item['title'] as String).toLowerCase();
      final sub = (item['sub'] as String).toLowerCase();
      final tag = (item['tag'] as String).toLowerCase();
      final matchesText = query.isEmpty || title.contains(query) || sub.contains(query) || tag.contains(query);
      final matchesFilter = selectedFilter == 'كل أنواع الأخشاب' || tag.contains(selectedFilter.toLowerCase()) || title.contains(selectedFilter.toLowerCase());
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
            hintText: 'ابحث عن تصاميم، غرف نوم، طاولات...',
            prefixIcon: const Icon(Icons.search, color: textMuted),
            fillColor: Colors.white,
            filled: true,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0x11114B5F))),
          ),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _chip('كل أنواع الأخشاب'),
              _chip('خشب صاج'),
              _chip('خشب زان'),
              _chip('خشب ميرندي'),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const Text('تصنيفات الأثاث والمنجور', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: primary)),
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
        const Text('الأدوات السريعة وخوارزميات الإنتاج', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: primary)),
        const SizedBox(height: 10),
        _utilityCard('مستعرض خوارزمية التوزيع الذكي', 'تحليل فوري لقرب الورش وحجم السعة (${summary.activeOrders} طلب نشط)', Icons.alt_route),
        _utilityCard('تتبع الخط الزمني لإنتاج الخشب', 'مراقبة لحظية لمراحل التقصيب والطلاء', Icons.timeline),
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
        decoration: BoxDecoration(color: active ? primary : Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0x11114B5F))),
        child: Text(label, style: TextStyle(fontSize: 12, color: active ? Colors.white : textMuted, fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _catCard(String title, String sub, IconData icon, String? img, VoidCallback onTap, {bool isAccent = false}) => InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isAccent ? accent : const Color(0x11114B5F)),
            image: img != null
                ? DecorationImage(
                    image: NetworkImage(img),
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.55), BlendMode.darken),
                  )
                : null,
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Icon(icon, color: isAccent ? accent : (img != null ? Colors.white : primary), size: 28),
              const SizedBox(height: 6),
              Text(title, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: img != null ? Colors.white : textMain)),
              Text(sub, style: TextStyle(fontSize: 10, color: img != null ? Colors.white70 : textMuted), maxLines: 1),
            ],
          ),
        ),
      );

  Widget _utilityCard(String title, String sub, IconData icon) => Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0x11114B5F))),
        child: Row(
          children: [
            Icon(icon, color: primary, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5)),
                  Text(sub, style: const TextStyle(fontSize: 11, color: textMuted)),
                ],
              ),
            ),
          ],
        ),
      );
}

// 2. معرض أعمال النجارة
class CarpentryPortfolioScreen extends StatelessWidget {
  const CarpentryPortfolioScreen({required this.workshop, super.key});
  final Workshop workshop;

  @override
  Widget build(BuildContext context) {
    final items = [
      ('خزانة ملابس زان كلاسيك', '1,200 د.أ/متر', '14 يوم تنفيذي', 'assets/images/12.PNG'),
      ('باب صاج رئيسي معشق', '850 د.أ/باب', '8 أيام عمل', 'assets/images/7.PNG'),
      ('مطبخ ميرندي ريفي متكامل', '1,500 د.أ/متر', '20 يوم عمل', 'assets/images/15.PNG'),
      ('تجهيز خشبي متكامل', '450 د.أ', '5 أيام عمل', 'assets/images/13.PNG'),
    ];

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text('معرض أعمال النجارة الموثق رقمياً', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: primary)),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 0.72),
          itemCount: items.length,
          itemBuilder: (context, idx) {
            final it = items[idx];
            return Container(
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0x11114B5F))),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Stack(
                      children: [
                        ClipRRect(borderRadius: const BorderRadius.vertical(top: Radius.circular(16)), child: Image.network(it.$4, width: double.infinity, fit: BoxFit.cover)),
                        Positioned(bottom: 8, left: 8, child: Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: primary, borderRadius: BorderRadius.circular(6)), child: Text(it.$2, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700)))),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(it.$1, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12), maxLines: 1),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(it.$3, style: const TextStyle(fontSize: 9.5, color: textMuted)),
                            const Icon(Icons.verified, color: successColor, size: 14),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

// 3. طلب تفصيل مخصص
class CarpentryOrderScreen extends StatelessWidget {
  const CarpentryOrderScreen({required this.workshop, super.key});
  final Workshop workshop;

  @override
  Widget build(BuildContext context) => OrderFormPage(workshop: workshop);
}

// 4. موازنة الأحمال
class CarpentryBalancerScreen extends StatelessWidget {
  const CarpentryBalancerScreen({required this.workshop, super.key});
  final Workshop workshop;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text('خوارزمية موازنة الأحمال للنجارة', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: primary)),
        const Text('الورش المقترحة الأقرب لك والأقل ضغطاً لتفادي تكدس الطلبات', style: TextStyle(fontSize: 12, color: textMuted)),
        const SizedBox(height: 16),
        _balancerNode('ورشة الأرز للنجارة المتطورة', '2.4 كم', 0.25, '25% سعة ممتلئة', successColor, 'ضغط منخفض ومثالي للإنتاج السريع'),
        _balancerNode('مصنع الأثاث الراقي الحديث', '4.1 كم', 0.65, '65% سعة ممتلئة', warningColor, 'ضغط متوسط - أوقات تسليم اعتيادية'),
        _balancerNode('ورشة سنديان للحرف اليدوية', '1.8 كم', 0.90, '90% سعة ممتلئة', dangerColor, 'ضغط عالي جداً - لا ننصح بالاعتماد حالياً'),
      ],
    );
  }

  Widget _balancerNode(String title, String dist, double val, String cap, Color col, String desc) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border(right: BorderSide(color: col, width: 4))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5)), Text(dist, style: const TextStyle(fontSize: 11, color: textMuted))]),
            const SizedBox(height: 8),
            LinearProgressIndicator(value: val, color: col, backgroundColor: col.withOpacity(0.1)),
            const SizedBox(height: 6),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(desc, style: TextStyle(fontSize: 10.5, color: col, fontWeight: FontWeight.w600)), Text(cap, style: const TextStyle(fontSize: 10.5, color: textMain))]),
          ],
        ),
      );
}

// 5. تتبع إنتاج الخشب مع تحديث المراحل
class CarpentryTimelineScreen extends StatelessWidget {
  const CarpentryTimelineScreen({required this.workshop, super.key});
  final Workshop workshop;

  @override
  Widget build(BuildContext context) {
    final store = StoreScope.of(context);
    final order = store.orders.isNotEmpty ? store.orders.first : null;
    final currentStatus = order?.status ?? 'جديد';

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          order != null ? 'تتبع إنتاج الطلب: ${order.name}' : 'خط تتبع إنتاج الخشب',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: primary),
        ),
        const SizedBox(height: 16),
        _timelineStep(context, store, order, OrderStatuses.newOrder, 'تم استلام وتوثيق الطلب بنجاح', currentStatus),
        _timelineStep(context, store, order, OrderStatuses.inProgress, 'جاري قص الأخشاب والتجهيز الهيكلي', currentStatus),
        _timelineStep(context, store, order, OrderStatuses.qualityCheck, 'مرحلة الصنفرة، البخ، والتجميع', currentStatus),
        _timelineStep(context, store, order, OrderStatuses.readyForDelivery, 'تم التغليف وجاهز للنقل والتركيب', currentStatus),
        _timelineStep(context, store, order, OrderStatuses.completed, 'تم تسليم الطلب وإغلاقه', currentStatus),
        _timelineStep(context, store, order, OrderStatuses.cancelled, 'تم إلغاء الطلب', currentStatus),
      ],
    );
  }

  Widget _timelineStep(BuildContext context, AppStore store, CraftOrder? order, String stepName, String desc, String currentStatus) {
    final isDone = _isStepCompleted(currentStatus, stepName);
    final isActive = currentStatus == stepName;

    return InkWell(
      onTap: () async {
        if (order != null) {
          final success = await store.updateOrderStatus(order, stepName);
          if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(success ? 'تم تحديث حالة الطلب إلى: $stepName' : 'تعذر تحديث حالة الطلب')));
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isActive ? accent : const Color(0x11114B5F), width: isActive ? 2 : 1),
        ),
        child: Row(
          children: [
            Icon(isDone ? Icons.check_circle : (isActive ? Icons.sync : Icons.radio_button_unchecked), color: isDone ? successColor : (isActive ? accent : textMuted)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(stepName, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: isActive ? primary : textMain)),
                  Text(desc, style: const TextStyle(fontSize: 11, color: textMuted)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _isStepCompleted(String current, String target) {
    const orderList = OrderStatuses.all;
    final curIdx = orderList.indexOf(current);
    final targetIdx = orderList.indexOf(target);
    return curIdx >= targetIdx && curIdx != -1;
  }
}

// 6. لوحة المعلم الحرفي (تحديث الحالة بضغطة واحدة إلى السيرفر)
class CarpentryCraftsmanScreen extends StatelessWidget {
  const CarpentryCraftsmanScreen({required this.workshop, super.key});
  final Workshop workshop;

  @override
  Widget build(BuildContext context) {
    final store = StoreScope.of(context);
    final order = store.orders.isNotEmpty ? store.orders.first : null;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text('لوحة نجارة المعلم الحرفي', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: primary)),
        const SizedBox(height: 12),
        if (order != null) ...[
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0x11114B5F))),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(order.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: primary)),
                    const Icon(Icons.handyman, color: accent),
                  ],
                ),
                const SizedBox(height: 4),
                Text('الخامة: ${order.material} | المقاس: ${order.length.toInt()} × ${order.width.toInt()} سم', style: const TextStyle(fontSize: 11.5, color: textMuted)),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: accent.withOpacity(0.12), borderRadius: BorderRadius.circular(8)),
                  child: Text('الحالة الحالية: ${order.status}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: primary)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text('تحديث الحالة بضغطة واحدة', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: primary)),
          const SizedBox(height: 12),
          _statusBtn(context, store, order, 'قيد التنفيذ', Icons.play_arrow, accent),
          _statusBtn(context, store, order, 'الفحص والجودة', Icons.verified_outlined, const Color(0xFF8D5B4C)),
          _statusBtn(context, store, order, 'جاهز للتسليم', Icons.local_shipping, successColor),
        ] else ...[
          const Center(child: Text('لا توجد طلبات نشطة حالياً لإدارتها', style: TextStyle(color: textMuted))),
        ],
      ],
    );
  }

  Widget _statusBtn(BuildContext context, AppStore store, CraftOrder order, String status, IconData icon, Color bg) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        width: double.infinity,
        height: 54,
        child: FilledButton.icon(
          onPressed: () async {
            final success = await store.updateOrderStatus(order, status);
            if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(success ? 'تم تحديث الطلب في السيرفر: $status' : 'تعذر تحديث الطلب')));
          },
          style: FilledButton.styleFrom(backgroundColor: bg, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
          icon: Icon(icon),
          label: Text(status, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        ),
      );
}

// 7. إدارة المخزون
class CarpentryInventoryScreen extends StatelessWidget {
  const CarpentryInventoryScreen({required this.workshop, super.key});
  final Workshop workshop;

  @override
  Widget build(BuildContext context) {
    final store = StoreScope.of(context);
    final inv = store.inventory;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text('مراقبة مستودع الأخشاب والكتل الخام', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: primary)),
        const SizedBox(height: 16),
        ...inv.map(
          (item) => Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0x11114B5F))),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5)),
                    Text('${item.quantity.toInt()} ${item.unit}', style: TextStyle(fontSize: 12, color: item.lowStock ? dangerColor : textMuted, fontWeight: FontWeight.bold)),
                  ],
                ),
                Row(
                  children: [
                    IconButton(icon: const Icon(Icons.remove_circle_outline), onPressed: () => store.adjustInventory(item, -1)),
                    IconButton(icon: const Icon(Icons.add_circle_outline, color: primary), onPressed: () => store.adjustInventory(item, 1)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// 8. مراجعة وتقييم جودة الأثاث (تفاعلية 100% مع النجوم والمربعات والملاحظات)
class CarpentryReviewScreen extends StatefulWidget {
  const CarpentryReviewScreen({required this.workshop, super.key});
  final Workshop workshop;

  @override
  State<CarpentryReviewScreen> createState() => _CarpentryReviewScreenState();
}

class _CarpentryReviewScreenState extends State<CarpentryReviewScreen> {
  bool c1 = true, c2 = true, c3 = true, c4 = true;
  int rating = 4;
  final noteController = TextEditingController();

  @override
  void dispose() {
    noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0x11114B5F))),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('قائمة الفحص الإلزامية', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: primary)),
              const SizedBox(height: 8),
              _checkRow('مطابقة المقاسات مع ملف التصميم', c1, (v) => setState(() => c1 = v!)),
              _checkRow('سلامة الخشب وجودة التشطيب', c2, (v) => setState(() => c2 = v!)),
              _checkRow('ثبات المفصلات والإكسسوارات', c3, (v) => setState(() => c3 = v!)),
              _checkRow('نظافة التغليف قبل التسليم', c4, (v) => setState(() => c4 = v!)),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0x11114B5F))),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('تقييم الجودة العام', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: primary)),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('$rating / 5', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: accent)),
                  Row(
                    children: List.generate(
                      5,
                      (i) => InkWell(
                        onTap: () => setState(() => rating = i + 1),
                        child: Icon(Icons.star, size: 30, color: i < rating ? warningColor : Colors.black12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0x11114B5F))),
          child: TextField(
            controller: noteController,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'ملاحظة الاعتماد الفني أو أية تعديلات مطلوبة...',
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(12),
            ),
          ),
        ),
        const SizedBox(height: 20),
        FilledButton.icon(
          onPressed: () async {
            final saved = await StoreScope.of(context).recordEvent(type: 'quality_review', workshopId: widget.workshop.id, payload: 'rating=$rating;checks=${[c1, c2, c3, c4]};note=${noteController.text}');
            if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(saved ? 'تم حفظ التقييم بنجاح' : 'تعذر حفظ التقييم')));
          },
          style: FilledButton.styleFrom(backgroundColor: primary, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          icon: const Icon(Icons.check_circle),
          label: const Text('تم اعتماد النتيجة', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  Widget _checkRow(String title, bool val, ValueChanged<bool?> onVal) => InkWell(
        onTap: () => onVal(!val),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontSize: 12.5, color: textMain)),
              Checkbox(value: val, onChanged: onVal, activeColor: successColor),
            ],
          ),
        ),
      );
}