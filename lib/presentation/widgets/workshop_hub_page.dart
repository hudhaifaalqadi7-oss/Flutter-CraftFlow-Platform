import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/entities/workshop.dart';
import 'workshop_media.dart';
import '../state/app_store.dart';

class WorkshopHubPage extends StatefulWidget {
  const WorkshopHubPage({required this.workshop, required this.onNewOrder, super.key});
  final Workshop workshop;
  final VoidCallback onNewOrder;

  @override
  State<WorkshopHubPage> createState() => _WorkshopHubPageState();
}

class _WorkshopHubPageState extends State<WorkshopHubPage> {
  String selectedFilter = 'الكل';
  String searchQuery = '';

  List<Map<String, dynamic>> get filteredCategories {
    final query = searchQuery.trim().toLowerCase();

    return hubCategories.where((cat) {
      final title = (cat['title'] as String).toLowerCase();
      final sub = (cat['sub'] as String).toLowerCase();
      final tag = (cat['tag'] as String).toLowerCase();
      final matchesText = query.isEmpty || title.contains(query) || sub.contains(query) || tag.contains(query);
      final matchesFilter = selectedFilter == 'الكل' || tag.contains(selectedFilter.toLowerCase()) || title.contains(selectedFilter.toLowerCase()) || sub.contains(selectedFilter.toLowerCase());
      return matchesText && matchesFilter;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final store = StoreScope.of(context);
    final summary = store.summary;
    final categories = filteredCategories;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        TextField(
          onChanged: (val) => setState(() => searchQuery = val.trim()),
          textDirection: TextDirection.rtl,
          decoration: InputDecoration(
            hintText: 'ابحث عن تصاميم، منتجات، أو خامات...',
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
            children: filterChips.map((chip) => _buildChip(chip)).toList(),
          ),
        ),
        const SizedBox(height: 20),
        const Text('اختيارات مناسبة لمشروعك', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: primary)),
        const SizedBox(height: 12),
        if (categories.isEmpty)
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0x11114B5F)),
            ),
            child: const Center(
              child: Text(
                'لا توجد تصاميم مطابقة للبحث',
                style: TextStyle(color: textMuted, fontWeight: FontWeight.w700),
              ),
            ),
          )
        else
          ...categories.map((cat) => _buildCategoryCard(cat)),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0x11114B5F))),
          child: Row(
            children: [
              const Icon(Icons.analytics_outlined, color: primary, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('مؤشرات إنتاج الورشة', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
                    Text('الطلبات النشطة: ${summary.activeOrders} | المكتملة: ${summary.completedOrders}', style: const TextStyle(fontSize: 11, color: textMuted)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildChip(String label) {
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

  Widget _buildCategoryCard(Map<String, dynamic> cat) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x11114B5F)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: CraftImage(url: cat['image'], width: 70, height: 70, fit: BoxFit.cover, fallbackColor: accent.withOpacity(0.2)),
        ),
        title: Text(cat['title'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: textMain)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(cat['sub'], style: const TextStyle(fontSize: 11.5, color: textMuted)),
            const SizedBox(height: 4),
            const Row(
              children: [
                Icon(Icons.verified, size: 13, color: successColor),
                SizedBox(width: 4),
                Text('تنفيذ موثق', style: TextStyle(fontSize: 10, color: successColor, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
        trailing: const Icon(Icons.chevron_left, color: textMuted),
        onTap: widget.onNewOrder,
      ),
    );
  }

  List<String> get filterChips => widget.workshop.id == 'carpentry'
      ? ['الكل', 'خشب صاج', 'خشب زان', 'خشب ميرندي']
      : (widget.workshop.id == 'blacksmith' ? ['الكل', 'قص ليزر', 'حديد مشغول', 'حمايات'] : ['الكل', 'سرايا', 'الروشان', 'دبل جلاس']);

  List<Map<String, dynamic>> get hubCategories => widget.workshop.id == 'carpentry'
      ? [
          {'title': 'غرف نوم وخزائن', 'sub': 'خشب زان وصاج طبيعي', 'image': 'assets/images/12.PNG', 'tag': 'خشب زان'},
          {'title': 'مطابخ خشبية مدمجة', 'sub': 'تفصيل واستغلال ذكي للمساحة', 'image': 'assets/images/14.PNG', 'tag': 'خشب صاج'},
          {'title': 'أبواب ومداخل رئيسية', 'sub': 'تصاميم كلاسيكية ومودرن', 'image': 'assets/images/7.PNG', 'tag': 'خشب ميرندي'},
        ]
      : (widget.workshop.id == 'blacksmith'
          ? [
              {'title': 'بوابات قص ليزر', 'sub': 'صفائح فولاذية 6 ملم مصفحة', 'image': 'assets/images/5.PNG', 'tag': 'قص ليزر'},
              {'title': 'حمايات نوافذ ودرابزين', 'sub': 'تشكيل مشغول ومقاوم للصدأ', 'image': 'assets/images/17.PNG', 'tag': 'حمايات'},
            ]
          : [
              {'title': 'نوافذ قطاع سرايا عازل', 'sub': 'زجاج دبل جلاس 24 ملم ومطاط محكم', 'image': 'assets/images/3.PNG', 'tag': 'سرايا'},
              {'title': 'واجهات وأبواب ألمنيوم', 'sub': 'إطارات ألمنيوم وزجاج واسع', 'image': 'assets/images/9.PNG', 'tag': 'الروشان'},
            ]);
}