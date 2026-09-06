import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/entities/workshop.dart';
import '../state/app_store.dart';

class InteractiveQualityPage extends StatefulWidget {
  const InteractiveQualityPage({required this.workshop, super.key});
  final Workshop workshop;

  @override
  State<InteractiveQualityPage> createState() => _InteractiveQualityPageState();
}

class _InteractiveQualityPageState extends State<InteractiveQualityPage> {
  bool check1 = true;
  bool check2 = true;
  bool check3 = true;
  bool check4 = true;
  int rating = 5;
  final TextEditingController noteController = TextEditingController();

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
              const SizedBox(height: 10),
              _buildCheckRow('مطابقة المقاسات مع ملف التصميم', check1, (v) => setState(() => check1 = v!)),
              _buildCheckRow('سلامة الخشب وجودة التشطيب', check2, (v) => setState(() => check2 = v!)),
              _buildCheckRow('ثبات المفصلات والإكسسوارات', check3, (v) => setState(() => check3 = v!)),
              _buildCheckRow('نظافة التغليف قبل التسليم', check4, (v) => setState(() => check4 = v!)),
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
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('$rating / 5', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: accent)),
                  Row(
                    children: List.generate(
                      5,
                      (index) => InkWell(
                        onTap: () => setState(() => rating = index + 1),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2),
                          child: Icon(
                            Icons.star,
                            size: 32,
                            color: index < rating ? warningColor : Colors.black12,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: noteController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'أدخل ملاحظة الاعتماد أو أية تعديلات مطلوبة من الحرفي...',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0x11114B5F))),
          ),
        ),
        const SizedBox(height: 20),
        FilledButton.icon(
          onPressed: () async {
            final saved = await StoreScope.of(context).recordEvent(type: 'quality_approval', workshopId: widget.workshop.id, payload: 'rating=$rating;checks=${[check1, check2, check3, check4]};note=${noteController.text}');
            if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(saved ? 'تم حفظ نتيجة الفحص بنجاح' : 'تعذر حفظ نتيجة الفحص')));
          },
          style: FilledButton.styleFrom(backgroundColor: primary, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
          icon: const Icon(Icons.check_circle),
          label: const Text('تم اعتماد النتيجة', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  Widget _buildCheckRow(String title, bool value, ValueChanged<bool?> onChanged) {
    return InkWell(
      onTap: () => onChanged(!value),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(fontSize: 13, color: textMain)),
            Checkbox(value: value, onChanged: onChanged, activeColor: successColor),
          ],
        ),
      ),
    );
  }
}