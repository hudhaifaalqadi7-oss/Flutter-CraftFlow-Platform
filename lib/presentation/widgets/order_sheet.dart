import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/entities/workshop.dart';

Future<void> showOrderSheet(BuildContext context, Workshop workshop) => showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: surface,
      builder: (context) => Padding(
        padding: EdgeInsets.fromLTRB(20, 8, 20, MediaQuery.viewInsetsOf(context).bottom + 20),
        child: SingleChildScrollView(
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Text('طلب تفصيل ${workshop.name}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: primary)),
            const SizedBox(height: 16),
            TextField(decoration: InputDecoration(labelText: 'اسم الطلب', prefixIcon: const Icon(Icons.title), hintText: 'مثال: ${workshop.name} مخصص')),
            const SizedBox(height: 12),
            const TextField(maxLines: 3, decoration: InputDecoration(labelText: 'وصف وتفاصيل العمل', prefixIcon: Icon(Icons.notes))),
            const SizedBox(height: 12),
            const Row(children: [Expanded(child: TextField(keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'الطول (سم)'))), SizedBox(width: 8), Expanded(child: TextField(keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'العرض (سم)')))]),
            const SizedBox(height: 16),
            OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.attach_file), label: const Text('إرفاق مخطط أو صورة')),
            const SizedBox(height: 12),
            FilledButton.icon(onPressed: () { Navigator.pop(context); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم حفظ الطلب وتشغيل التوزيع الذكي'))); }, icon: const Icon(Icons.bolt), label: const Text('تأكيد وتشغيل التوزيع')),
          ]),
        ),
      ),
    );
