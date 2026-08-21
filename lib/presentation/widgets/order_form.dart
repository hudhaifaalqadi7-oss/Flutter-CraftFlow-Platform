import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/entities/workshop.dart';
import '../../domain/entities/app_models.dart';
import '../state/app_store.dart';

class OrderFormPage extends StatefulWidget {
  const OrderFormPage({required this.workshop, super.key});
  final Workshop workshop;

  @override
  State<OrderFormPage> createState() => _OrderFormPageState();
}

class _OrderFormPageState extends State<OrderFormPage> {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final lengthController = TextEditingController();
  final widthController = TextEditingController();
  String material = 'اختيار النوع';
  bool attachmentAdded = false;

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    lengthController.dispose();
    widthController.dispose();
    super.dispose();
  }

  void submit() {
    if (!formKey.currentState!.validate() || material == 'اختيار النوع') {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('أكمل اسم الطلب والنوع والأبعاد أولاً')));
      return;
    }
    final store = StoreScope.of(context);
    final order = CraftOrder(id: DateTime.now().microsecondsSinceEpoch.toString(), workshopId: widget.workshop.id, name: nameController.text.trim(), description: descriptionController.text.trim(), material: material, length: double.parse(lengthController.text), width: double.parse(widthController.text), attachmentAdded: attachmentAdded);
    store.addOrder(order);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('تم حفظ طلب ${nameController.text} وتشغيل التوزيع الذكي')));
    formKey.currentState!.reset();
    nameController.clear();
    descriptionController.clear();
    lengthController.clear();
    widthController.clear();
    setState(() { material = 'اختيار النوع'; attachmentAdded = false; });
  }

  @override
  Widget build(BuildContext context) => Form(
        key: formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text('طلب تفصيل ${widget.workshop.name}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: primary)),
            const SizedBox(height: 8),
            const Text('أدخل المواصفات ليتم توزيع الطلب على الورشة الأنسب.', style: TextStyle(color: muted)),
            const SizedBox(height: 18),
            TextFormField(controller: nameController, validator: (value) => value == null || value.trim().isEmpty ? 'أدخل اسم الطلب' : null, decoration: const InputDecoration(labelText: 'اسم الطلب', prefixIcon: Icon(Icons.title))),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(initialValue: material, decoration: const InputDecoration(labelText: 'النوع أو الخامة', prefixIcon: Icon(Icons.category)), items: ['اختيار النوع', 'اقتصادي', 'قياسي', 'فاخر'].map((value) => DropdownMenuItem(value: value, child: Text(value))).toList(), onChanged: (value) => setState(() => material = value ?? material)),
            const SizedBox(height: 12),
            TextFormField(controller: descriptionController, maxLines: 3, validator: (value) => value == null || value.trim().isEmpty ? 'أدخل وصف العمل' : null, decoration: const InputDecoration(labelText: 'الوصف والتفاصيل', prefixIcon: Icon(Icons.notes))),
            const SizedBox(height: 12),
            Row(children: [Expanded(child: TextFormField(controller: lengthController, keyboardType: TextInputType.number, validator: dimensionValidator, decoration: const InputDecoration(labelText: 'الطول (سم)'))), const SizedBox(width: 8), Expanded(child: TextFormField(controller: widthController, keyboardType: TextInputType.number, validator: dimensionValidator, decoration: const InputDecoration(labelText: 'العرض (سم)')))]),
            const SizedBox(height: 16),
            OutlinedButton.icon(onPressed: () => setState(() => attachmentAdded = !attachmentAdded), icon: Icon(attachmentAdded ? Icons.check_circle : Icons.attach_file), label: Text(attachmentAdded ? 'تم إرفاق المخطط' : 'إرفاق مخطط أو صورة')),
            const SizedBox(height: 18),
            FilledButton.icon(onPressed: submit, icon: const Icon(Icons.bolt), label: const Text('تأكيد وتشغيل التوزيع')),
          ],
        ),
      );

  String? dimensionValidator(String? value) => value == null || double.tryParse(value) == null || double.parse(value) <= 0 ? 'أدخل رقمًا صحيحًا' : null;
}
