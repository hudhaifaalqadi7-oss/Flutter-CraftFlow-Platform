import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/entities/workshop.dart';
import 'order_sheet.dart';
import 'workshop_media.dart';

class InteractivePortfolioPage extends StatefulWidget {
  const InteractivePortfolioPage({required this.workshop, super.key});

  final Workshop workshop;

  @override
  State<InteractivePortfolioPage> createState() => _InteractivePortfolioPageState();
}

class _InteractivePortfolioPageState extends State<InteractivePortfolioPage> {
  final searchController = TextEditingController();
  final favoriteIds = <int>{};
  String selectedFilter = 'الكل';
  bool favoritesOnly = false;

  List<_PortfolioEntry> get entries {
    switch (widget.workshop.id) {
      case 'carpentry':
        return const [
          _PortfolioEntry('باب مدخل خشبي أبيض', 'أبواب', 'خشب مع دهان مقاوم للعوامل', '8 أيام', 'من 850 ر.س', 'assets/images/1.PNG'),
          _PortfolioEntry('تشكيلة أبواب داخلية', 'أبواب', 'خشب طبيعي بتصاميم متعددة', '12 يوم', 'من 1,200 ر.س', 'assets/images/2.PNG'),
          _PortfolioEntry('أبواب خشبية كلاسيكية', 'أبواب', 'خشب مصمت مع زخارف', '10 أيام', 'من 1,100 ر.س', 'assets/images/4.PNG'),
          _PortfolioEntry('أبواب مداخل خارجية', 'أبواب', 'خشب مع طبقة حماية خارجية', '14 يوم', 'من 2,200 ر.س', 'assets/images/7.PNG'),
          _PortfolioEntry('خزانة ملابس مدمجة', 'غرف نوم', 'خشب MDF وقشرة طبيعية', '14 يوم', 'من 1,500 ر.س', 'assets/images/12.PNG'),
          _PortfolioEntry('خزانة غرفة نوم عصرية', 'غرف نوم', 'خشب مطلي وأبواب سحاب', '15 يوم', 'من 1,650 ر.س', 'assets/images/13.PNG'),
          _PortfolioEntry('مطبخ تفصيل عصري', 'مطابخ', 'ألواح MDF وواجهات مطفية', '20 يوم', 'من 3,800 ر.س', 'assets/images/14.PNG'),
          _PortfolioEntry('مطبخ خشبي كلاسيكي', 'مطابخ', 'خشب طبيعي وتشطيب لامع', '22 يوم', 'من 4,200 ر.س', 'assets/images/15.PNG'),
        ];
      case 'blacksmith':
        return const [
          _PortfolioEntry('بوابة حديدية للمداخل', 'بوابات', 'حديد مجلفن مطلي', '12 يوم', 'من 4,800 ر.س', 'assets/images/5.PNG'),
          _PortfolioEntry('باب حديدي بزخارف يدوية', 'أبواب', 'حديد مشغول مع حماية ضد الصدأ', '14 يوم', 'من 3,600 ر.س', 'assets/images/8.PNG'),
          _PortfolioEntry('باب حديدي بنقوش زخرفية', 'أبواب', 'حديد مشغول ودهان مقاوم للصدأ', '14 يوم', 'من 3,900 ر.س', 'assets/images/11.PNG'),
          _PortfolioEntry('مظلة معدنية بنقوش ليزر', 'مظلات', 'فولاذ مطلي مقاوم للعوامل', '16 يوم', 'من 4,200 ر.س', 'assets/images/16.PNG'),
          _PortfolioEntry('حاجز شرفة من الحديد المشغول', 'حمايات', 'حديد مطلي بالبودرة', '10 أيام', 'من 2,400 ر.س', 'assets/images/17.PNG'),
        ];
      default:
        return const [
          _PortfolioEntry('نافذة ألمنيوم بإضاءة واسعة', 'نوافذ', 'قطاع ألمنيوم وزجاج عازل', '9 أيام', 'من 680 ر.س/متر', 'assets/images/3.PNG'),
          _PortfolioEntry('خزانة ألمنيوم منزلقة', 'فواصل', 'إطار ألمنيوم وزجاج شفاف', '12 يوم', 'من 1,250 ر.س/متر', 'assets/images/6.PNG'),
          _PortfolioEntry('نافذة بانورامية للمنزل', 'نوافذ', 'ألمنيوم حراري وزجاج مزدوج', '9 أيام', 'من 750 ر.س/متر', 'assets/images/9.PNG'),
          _PortfolioEntry('تشكيلة نوافذ وأبواب ألمنيوم', 'واجهات', 'ألمنيوم وزجاج بتصاميم متعددة', '16 يوم', 'من 1,050 ر.س/متر', 'assets/images/10.PNG'),
        ];
    }
  }

  List<_PortfolioEntry> get filteredEntries => entries.where((entry) {
        final query = searchController.text.trim();
        final matchesText = query.isEmpty || '${entry.title} ${entry.category} ${entry.material}'.contains(query);
        final matchesCategory = selectedFilter == 'الكل' || entry.category == selectedFilter;
        final matchesFavorite = !favoritesOnly || favoriteIds.contains(entries.indexOf(entry));
        return matchesText && matchesCategory && matchesFavorite;
      }).toList();

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categories = ['الكل', ...entries.map((entry) => entry.category).toSet()];
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      children: [
        Row(
          children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('معرض أعمال موثق', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: primary)), Text('${entries.length} تصاميم مختارة لـ ${widget.workshop.name}', style: const TextStyle(color: textMuted, fontSize: 12))])),
            IconButton.filledTonal(onPressed: () => setState(() => favoritesOnly = !favoritesOnly), icon: Icon(favoritesOnly ? Icons.favorite : Icons.favorite_border), tooltip: 'المفضلة'),
          ],
        ),
        const SizedBox(height: 14),
        TextField(
          controller: searchController,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(hintText: 'ابحث بالتصميم أو الخامة...', prefixIcon: const Icon(Icons.search), suffixIcon: searchController.text.isEmpty ? null : IconButton(onPressed: () { searchController.clear(); setState(() {}); }, icon: const Icon(Icons.close)), filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none)),
        ),
        const SizedBox(height: 12),
        SizedBox(height: 38, child: ListView.separated(scrollDirection: Axis.horizontal, itemCount: categories.length, separatorBuilder: (_, __) => const SizedBox(width: 8), itemBuilder: (_, index) => ChoiceChip(label: Text(categories[index]), selected: selectedFilter == categories[index], onSelected: (_) => setState(() => selectedFilter = categories[index]), selectedColor: widget.workshop.color, labelStyle: TextStyle(color: selectedFilter == categories[index] ? Colors.white : textMuted, fontSize: 12, fontWeight: FontWeight.bold)))),
        const SizedBox(height: 18),
        if (filteredEntries.isEmpty)
          const Padding(padding: EdgeInsets.all(30), child: Center(child: Text('لا توجد تصاميم مطابقة', style: TextStyle(color: textMuted))))
        else
          GridView.builder(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), itemCount: filteredEntries.length, gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: .66), itemBuilder: (context, index) => _card(context, filteredEntries[index])),
      ],
    );
  }

  Widget _card(BuildContext context, _PortfolioEntry entry) {
    final originalIndex = entries.indexOf(entry);
    final isFavorite = favoriteIds.contains(originalIndex);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _showDetails(context, entry),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(child: Stack(children: [CraftImage(url: entry.image, width: double.infinity, fit: BoxFit.cover, fallbackColor: widget.workshop.color.withValues(alpha: .2)), Positioned(top: 8, right: 8, child: IconButton(onPressed: () => setState(() => isFavorite ? favoriteIds.remove(originalIndex) : favoriteIds.add(originalIndex)), style: IconButton.styleFrom(backgroundColor: Colors.white.withValues(alpha: .9)), icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border, color: isFavorite ? dangerColor : primary, size: 18))), Positioned(bottom: 8, left: 8, child: Container(padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4), decoration: BoxDecoration(color: primary, borderRadius: BorderRadius.circular(6)), child: Text(entry.category, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold))))])),
          Padding(padding: const EdgeInsets.fromLTRB(9, 9, 9, 3), child: Text(entry.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: primary))),
          Padding(padding: const EdgeInsets.fromLTRB(9, 0, 9, 9), child: Row(children: [Expanded(child: Text(entry.price, style: const TextStyle(color: accent, fontSize: 10, fontWeight: FontWeight.bold))), const Icon(Icons.chevron_left, size: 17, color: textMuted)])),
        ]),
      ),
    );
  }

  void _showDetails(BuildContext context, _PortfolioEntry entry) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CraftImage(url: entry.image, height: 160, borderRadius: BorderRadius.circular(16), fallbackColor: widget.workshop.color.withValues(alpha: .2)),
            const SizedBox(height: 12),
            Text(entry.title, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900, color: primary)),
            const SizedBox(height: 5),
            Text('${entry.material}  -  التنفيذ: ${entry.duration}', style: const TextStyle(color: textMuted)),
            const SizedBox(height: 5),
            Text(entry.price, style: const TextStyle(color: accent, fontWeight: FontWeight.w900)),
            const SizedBox(height: 15),
            FilledButton.icon(
              onPressed: () {
                Navigator.pop(sheetContext);
                showOrderSheet(context, widget.workshop);
              },
              icon: const Icon(Icons.request_quote_outlined),
              label: const Text('اطلب تصميماً مشابهاً'),
            ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PortfolioEntry {
  const _PortfolioEntry(this.title, this.category, this.material, this.duration, this.price, this.image);
  final String title;
  final String category;
  final String material;
  final String duration;
  final String price;
  final String image;
}
