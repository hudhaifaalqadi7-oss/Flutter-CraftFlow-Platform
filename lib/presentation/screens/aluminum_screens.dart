import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/entities/workshop.dart';
import '../../domain/entities/app_models.dart';
import '../state/app_store.dart';
import '../widgets/order_form.dart';
import '../widgets/order_sheet.dart';
import '../widgets/workshop_media.dart';

// 1. رئيسية الألمنيوم (Hub)
class AluminumHubScreen extends StatefulWidget {
  const AluminumHubScreen({required this.workshop, required this.onNewOrder, super.key});
  final Workshop workshop;
  final VoidCallback onNewOrder;

  @override
  State<AluminumHubScreen> createState() => _AluminumHubScreenState();
}

class _AluminumHubScreenState extends State<AluminumHubScreen> {
  String selectedFilter = 'الكل';
  String searchQuery = '';

  List<Map<String, dynamic>> get filteredCards {
    final query = searchQuery.trim().toLowerCase();
    final items = [
      {'title': 'نوافذ ألمنيوم دبل جلاس', 'sub': 'عزل صوتي وحراري كامل معتمد', 'tag': 'سرايا', 'image': 'assets/images/3.PNG', 'icon': Icons.window, 'action': () => showOrderSheet(context, widget.workshop)},
      {'title': 'واجهات ألمنيوم وزجاج', 'sub': 'إطارات عازلة بتصاميم عصرية', 'tag': 'الروشان', 'image': 'assets/images/9.PNG', 'icon': Icons.apartment, 'action': () => showOrderSheet(context, widget.workshop)},
      {'title': 'أبواب ألمنيوم منزلقة', 'sub': 'تشغيل عملي وزجاج واسع', 'tag': 'زجاج', 'image': 'assets/images/10.PNG', 'icon': Icons.door_sliding, 'action': () => showOrderSheet(context, widget.workshop)},
      {'title': 'تحديد مواصفات الألمنيوم', 'sub': 'اختر نوع القطاع وسماكة الزجاج', 'tag': 'دبل جلاس', 'image': null, 'icon': Icons.tune, 'action': widget.onNewOrder},
    ];

    return items.where((item) {
      final title = (item['title'] as String).toLowerCase();
      final sub = (item['sub'] as String).toLowerCase();
      final tag = (item['tag'] as String).toLowerCase();
      final matchesText = query.isEmpty || title.contains(query) || sub.contains(query) || tag.contains(query);
      final matchesFilter = selectedFilter == 'الكل' || tag.contains(selectedFilter.toLowerCase()) || title.contains(selectedFilter.toLowerCase());
      return matchesText && matchesFilter;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final cards = filteredCards;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        TextField(
          onChanged: (value) => setState(() => searchQuery = value.trim()),
          textDirection: TextDirection.rtl,
          decoration: InputDecoration(
            hintText: 'ابحث عن نوافذ دبل جلاس، مطابخ ألمنيوم، كلادينج...',
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
            children: ['الكل', 'سرايا', 'الروشان', 'دبل جلاس']
                .map((chip) => _chip(chip))
                .toList(),
          ),
        ),
        const SizedBox(height: 20),
        const Text('مجموعات أعمال القطاعات والألومنيوم', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: primary)),
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
        const Text('الأجهزة الهندسية والمطابقة والعزل', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: primary)),
        const SizedBox(height: 10),
        _utilityCard('مستعرض التوزيع الجغرافي للألمنيوم', 'البحث عن أجهزة كبس الزاوية الآلية لضمان العزل', Icons.compass_calibration),
        _utilityCard('الخط الزمني لتجميع وضغط القطاعات', 'مراقبة تفصيل القطاع، تركيب الزجاج، وفحص العزل', Icons.view_in_ar),
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

// 2. معرض أعمال الألمنيوم (Portfolio)
class AluminumPortfolioScreen extends StatelessWidget {
  const AluminumPortfolioScreen({required this.workshop, super.key});
  final Workshop workshop;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text('معرض قطاعات الألمنيوم الهندسية المعتمدة العزل', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: primary)),
        const SizedBox(height: 12),
        _card('نوافذ ألمنيوم بإضاءة واسعة', 'قطاع ألمنيوم مع زجاج عازل وتصميم عملي للمساحات السكنية.', 'assets/images/3.PNG'),
        _card('واجهة ألمنيوم وزجاج عصرية', 'إطارات ألمنيوم خفيفة مع فتحات واسعة وإطلالة واضحة.', 'assets/images/9.PNG'),
      ],
    );
  }

  Widget _card(String title, String desc, String img) => Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0x11114B5F))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CraftImage(
                url: img,
                height: 140,
                width: double.infinity,
                fit: BoxFit.cover,
                fallbackColor: const Color(0x11114B5F),
              ),
            ),
            const SizedBox(height: 10),
            Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: primary)),
            const SizedBox(height: 2),
            Text(desc, style: const TextStyle(fontSize: 11.5, color: textMuted)),
          ],
        ),
      );
}

// 3. تخصيص قطاع الألمنيوم (Specs Sheet)
class AluminumOrderScreen extends StatelessWidget {
  const AluminumOrderScreen({required this.workshop, super.key});
  final Workshop workshop;

  @override
  Widget build(BuildContext context) => OrderFormPage(workshop: workshop);
}

// 4. كبس الزوايا الآلي (Load Balancer)
class AluminumBalancerScreen extends StatelessWidget {
  const AluminumBalancerScreen({required this.workshop, super.key});
  final Workshop workshop;

  @override
  Widget build(BuildContext context) {
    final store = StoreScope.of(context);
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text('خوارزمية رصد أجهزة كبس الزاوية والضغط الهيدروليكي الآلي', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: primary)),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: const Border(right: BorderSide(color: successColor, width: 4))),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('ورشة التيسير الآلية للألومنيوم المطور', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5)), Text('يمتلك كبس زاوية آلي', style: TextStyle(fontSize: 11, color: successColor, fontWeight: FontWeight.bold))]),
              SizedBox(height: 8),
              LinearProgressIndicator(value: 0.33, color: successColor, backgroundColor: Color(0x222A9D8F)),
              SizedBox(height: 6),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('نسبة الخطأ والتهريب صفر % مضمون وضمان رقمي', style: TextStyle(fontSize: 10.5, color: successColor)), Text('33% أحمال متوفرة', style: TextStyle(fontSize: 10.5))]),
            ],
          ),
        ),
        const SizedBox(height: 20),
        FilledButton(
          onPressed: () async { final saved = await store.recordEvent(type: 'aluminum_routing', workshopId: workshop.id, payload: 'ورشة التيسير الآلية'); if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(saved ? 'تم حفظ توجيه قطاعات الألمنيوم' : 'تعذر حفظ التوجيه'))); },
          style: FilledButton.styleFrom(backgroundColor: primary, padding: const EdgeInsets.symmetric(vertical: 14)),
          child: const Text('تأكيد توجيه قطاعات الألمنيوم لورشة التيسير المعتمدة الآلية', style: TextStyle(fontWeight: FontWeight.w700)),
        ),
      ],
    );
  }
}

// 5. خط تجميع النوافذ والعزل (Timeline)
class AluminumTimelineScreen extends StatelessWidget {
  const AluminumTimelineScreen({required this.workshop, super.key});
  final Workshop workshop;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text('خط تجميع واختبار عزل النوافذ الألمنيوم للطلب #1192', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: primary)),
        const SizedBox(height: 16),
        _step('تقطيع وتفصيل قطاعات الألومنيوم سرايا', 'تم قص زوايا الألمنيوم بزاوية 45 درجة حادة بدقة ليزرية متناهية المقاس.', true, false),
        _step('كبس الزوايا وتثبيت لفة المطاط العازل المحكم', 'تم ضغط الزاوية هيدروليكياً لمنع تسريب جزئيات المطر أو ذرات الهواء والغبار.', true, false),
        _step('تركيب الزجاج الدبل والإكسسوارات الفولاذية', 'يتم الآن حقن غاز الأرجون العازل بين طبقات الزجاج لمنع انتقال الحرارة الخارجية للداخل.', false, true),
        _step('الفحص الفني النهائي وتفعيل الضمان الرقمي', 'مرحلة مجدولة أخيرة للتأكد من الجودة والمطابقة الفنية قبل النقل والشحن.', false, false),
      ],
    );
  }

  Widget _step(String title, String desc, bool done, bool active) => Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: active ? accent : const Color(0x11114B5F))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)), Icon(done ? Icons.check_circle : (active ? Icons.sync : Icons.schedule), color: done ? successColor : (active ? accent : textMuted), size: 16)]),
            const SizedBox(height: 4),
            Text(desc, style: const TextStyle(fontSize: 11.5, color: textMuted)),
          ],
        ),
      );
}

// 6. ماسح الباركود السريع (Tech UI)
class AluminumTechScreen extends StatelessWidget {
  const AluminumTechScreen({required this.workshop, super.key});
  final Workshop workshop;

  @override
  Widget build(BuildContext context) {
    final store = StoreScope.of(context);
    return Container(
      color: Colors.black,
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Text('ماسح باركود أمر الشغل السريع للفني داخل ورشة الألمنيوم', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          const Text('وجه الكاميرا نحو الكود الملصق على قطاع الألمنيوم لتحديث الحالة فوراً تلقائياً بدون نصوص وكتابة', style: TextStyle(color: Colors.white60, fontSize: 11.5)),
          const SizedBox(height: 24),
          Container(
            height: 240,
            decoration: BoxDecoration(border: Border.all(color: accent, width: 2), borderRadius: BorderRadius.circular(16)),
            child: const Center(child: Icon(Icons.qr_code_scanner, color: accent, size: 80)),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () async { final saved = await store.recordEvent(type: 'barcode_scan', workshopId: workshop.id, payload: '#AL-9982'); if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(saved ? 'تم حفظ مسح الباركود' : 'تعذر حفظ مسح الباركود'))); },
            style: FilledButton.styleFrom(backgroundColor: accent, foregroundColor: primary),
            icon: const Icon(Icons.bolt),
            label: const Text('محاكاة التقاط الباركود البصري السريع'),
          ),
        ],
      ),
    );
  }
}

// 7. مستودع قطاعات الألمنيوم التفاعلي
class AluminumInventoryScreen extends StatelessWidget {
  const AluminumInventoryScreen({required this.workshop, super.key});
  final Workshop workshop;

  @override
  Widget build(BuildContext context) {
    final store = StoreScope.of(context);
    final inv = store.inventory;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text('مراقبة وتعديل مستودع قطاعات ألمنيوم سرايا', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: primary)),
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

// 8. الضمان الرقمي المعتمد (QA & Warranty)
class AluminumWarrantyScreen extends StatelessWidget {
  const AluminumWarrantyScreen({required this.workshop, super.key});
  final Workshop workshop;

  @override
  Widget build(BuildContext context) {
    final store = StoreScope.of(context);
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text('مركز الفحص الفني وتفعيل كرت الضمان الرقمي المعتمد للشبكة', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: primary)),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [primary, Color(0xFF1A3D47)]),
            border: Border.all(color: accent, width: 2),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Column(
            children: [
              Chip(label: Text('وثيقة حماية رقمية مشفرة', style: TextStyle(fontSize: 11, color: accent, fontWeight: FontWeight.bold))),
              SizedBox(height: 8),
              Text('شهادة ضمان قطاعات الألمنيوم سرايا وعزل الزجاج', textAlign: TextAlign.center, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: accent)),
              SizedBox(height: 8),
              Text('تضمن هذه الوثيقة خلو النوافذ المركبة من عيوب كبس الزوايا أو تسريب مياه الأمطار وذرات الأتربة والغبار وعزل الصوت الخارجي لـ 10 سنوات كاملة من تاريخ التفعيل المعتمد.', textAlign: TextAlign.center, style: TextStyle(color: Colors.white70, fontSize: 11.5, height: 1.6)),
              Divider(color: Colors.white24, height: 24),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('كود التحقق: #WARR-9982-2026', style: TextStyle(color: Colors.white, fontSize: 11)), Text('نشط ومحمي', style: TextStyle(color: successColor, fontWeight: FontWeight.bold, fontSize: 11))]),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0x11114B5F))),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('نتائج اختبار العزل الصوتي والمائي الآلي', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: primary)),
              SizedBox(height: 4),
              Text('تم فحص كبس الزاوية عبر جهاز القياس الهيدروليكي وسجل ضغط 98.4% وهي نسبة ممتازة ومطابقة للمواصفات والأكواد الهندسية المعتمدة بالمنصة.', style: TextStyle(fontSize: 11.5, color: textMuted)),
            ],
          ),
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: () async { final saved = await store.recordEvent(type: 'warranty_download', workshopId: workshop.id, payload: '#WARR-9982-2026'); if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(saved ? 'تم حفظ طلب شهادة الضمان' : 'تعذر حفظ طلب الشهادة'))); },
          style: FilledButton.styleFrom(backgroundColor: primary, padding: const EdgeInsets.symmetric(vertical: 14)),
          icon: const Icon(Icons.download),
          label: const Text('تحميل وحفظ كرت الضمان الرقمي المعتمد'),
        ),
      ],
    );
  }
}