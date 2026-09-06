import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/entities/workshop.dart';
import '../../domain/entities/app_models.dart';
import '../../domain/entities/workshop_order_options.dart';
import '../../data/services/api_service.dart';
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
  final lengthController = TextEditingController(text: '120');
  final widthController = TextEditingController(text: '80');
  final depthController = TextEditingController(text: '45');
  late String material;
  late String blacksmithTreatment;
  late String aluminumGlazing;
  String? filePath;

  @override
  void initState() {
    super.initState();
    material = materialOptions.first;
    blacksmithTreatment = WorkshopOrderOptions.blacksmithTreatments.first;
    aluminumGlazing = WorkshopOrderOptions.aluminumGlazing.first;
    nameController.addListener(_refreshPreview);
    descriptionController.addListener(_refreshPreview);
    lengthController.addListener(_refreshPreview);
    widthController.addListener(_refreshPreview);
    depthController.addListener(_refreshPreview);
  }

  void _refreshPreview() => setState(() {});

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    lengthController.dispose();
    widthController.dispose();
    depthController.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    if (!formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى إكمال الحقول الإلزامية')),
      );
      return;
    }

    final store = StoreScope.of(context);
    final order = CraftOrder(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      workshopId: widget.workshop.id,
      name: nameController.text.trim().isEmpty ? 'طلب ${widget.workshop.name} جديد' : nameController.text.trim(),
      description: _orderDescription,
      material: material,
      length: double.tryParse(lengthController.text) ?? 100.0,
      width: double.tryParse(widthController.text) ?? 100.0,
      depth: double.tryParse(depthController.text) ?? 0.0,
      filePath: filePath,
    );

    final success = await store.addOrder(order);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('تم حفظ طلب ${order.name} وتوجيهه بنجاح')),
        );
        Navigator.maybePop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(ApiService.lastError ?? 'تعذر إرسال الطلب إلى السيرفر')),
        );
      }
    }
  }

  Future<void> pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['dwg', 'png', 'jpg', 'jpeg', 'pdf'],
    );
    if (result != null && mounted) {
      final selected = result.files.single;
      final uploadedPath = selected.bytes == null ? null : await StoreScope.of(context).apiService.uploadFile(name: selected.name, bytes: selected.bytes!);
      setState(() {
        filePath = uploadedPath;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(uploadedPath == null ? 'تعذر رفع ملف التصميم' : 'تم رفع ملف التصميم إلى الخادم')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final store = StoreScope.of(context);
    final length = double.tryParse(lengthController.text) ?? 0;
    final width = double.tryParse(widthController.text) ?? 0;
    final depth = double.tryParse(depthController.text) ?? 0;
    final area = length * width / 10000;
    final estimate = _estimatePrice(area, depth);
    final completion = _completion;

    return Form(
      key: formKey,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'صمّم طلبك خطوة بخطوة',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: primary),
                ),
              ),
              Text('$completion%', style: const TextStyle(color: accent, fontWeight: FontWeight.w900)),
            ],
          ),
          const SizedBox(height: 7),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(value: completion / 100, minHeight: 7, color: accent, backgroundColor: primary.withValues(alpha: .1)),
          ),
          const SizedBox(height: 12),
          Text(
            widget.workshop.id == 'carpentry'
                ? 'طلب تفصيل نجارة مخصص رفيع المستوى'
                : (widget.workshop.id == 'blacksmith'
                    ? 'تحديد مواصفات الحديد التخصصية مليمتر'
                    : 'تخصيص قطاع الألمنيوم والزجاج العازل للصوت'),
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: primary),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: nameController,
            decoration: InputDecoration(
              labelText: 'اسم العمل أو المشروع',
              hintText: 'مثال: تفصيل مخصص للفيلا',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            validator: (value) => value == null || value.trim().isEmpty ? 'أدخل اسم الطلب' : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: descriptionController,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: 'وصف العمل والتفاصيل المطلوبة',
              hintText: 'اكتب التفاصيل أو الملاحظات المهمة للتنفيذ',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            validator: (value) => value == null || value.trim().isEmpty ? 'أدخل وصف العمل' : null,
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: material,
            decoration: InputDecoration(
              labelText: widget.workshop.id == 'carpentry'
                  ? 'نوع الخشب المطلوب اعتماده'
                  : (widget.workshop.id == 'blacksmith' ? 'سماكة صاج الحديد المطلوبة' : 'اسم قطاع الألمنيوم المعتمد هيكلياً'),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            items: materialOptions.map((v) => DropdownMenuItem(value: v, child: Text(v, style: const TextStyle(fontSize: 13)))).toList(),
            onChanged: (v) => setState(() => material = v ?? material),
          ),
          const SizedBox(height: 12),
          if (widget.workshop.id == 'blacksmith') ...[
            DropdownButtonFormField<String>(
              value: 'طلاء إيبوكسي ناري عازل للرطوبة',
              decoration: InputDecoration(
                labelText: 'نوع الطلاء ومعالجة الأسطح ومقاومة الصدأ',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              items: WorkshopOrderOptions.blacksmithTreatments.map((value) => DropdownMenuItem(value: value, child: Text(value, style: const TextStyle(fontSize: 13)))).toList(),
              onChanged: (value) => setState(() => blacksmithTreatment = value ?? blacksmithTreatment),
            ),
            const SizedBox(height: 12),
          ],
          if (widget.workshop.id == 'aluminum') ...[
            DropdownButtonFormField<String>(
              value: aluminumGlazing,
              decoration: InputDecoration(
                labelText: 'نوع وسماكة وطبقات الزجاج المركب',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              items: WorkshopOrderOptions.aluminumGlazing.map((value) => DropdownMenuItem(value: value, child: Text(value, style: const TextStyle(fontSize: 13)))).toList(),
              onChanged: (value) => setState(() => aluminumGlazing = value ?? aluminumGlazing),
            ),
            const SizedBox(height: 12),
          ],
          const Text('المقاسات الهندسية المطلوبة (بالسنتيمتر)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: primary)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: lengthController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'الطول', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                  validator: _dimensionValidator,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextFormField(
                  controller: widthController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'العرض', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                  validator: _dimensionValidator,
                ),
              ),
              if (widget.workshop.id == 'carpentry') ...[
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    controller: depthController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: 'العمق', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                    validator: _dimensionValidator,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),
          _livePreview(area, estimate, depth),
          const SizedBox(height: 16),
          InkWell(
            onTap: pickFile,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: primary.withOpacity(0.02),
                border: Border.all(color: primary.withOpacity(0.15)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const Icon(Icons.file_upload_outlined, color: accent, size: 32),
                  const SizedBox(height: 8),
                  Text(
                    filePath ?? 'اضغط هنا لإرفاق ملف الأوتوكاد (.dwg) أو لقطة التصميم المطلوبة',
                    style: const TextStyle(fontSize: 12, color: textMuted),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: store.isActionLoading ? null : submit,
            style: FilledButton.styleFrom(
              backgroundColor: primary,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            icon: store.isActionLoading
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.bolt),
            label: Text(
              store.isActionLoading ? 'جاري الإرسال...' : 'تأكيد المواصفات وتشغيل خوارزمية التوزيع',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  int get _completion {
    var result = 25;
    if (nameController.text.trim().isNotEmpty) result += 15;
    if (descriptionController.text.trim().isNotEmpty) result += 15;
    if ((double.tryParse(lengthController.text) ?? 0) > 0 && (double.tryParse(widthController.text) ?? 0) > 0) result += 25;
    if (filePath != null) result += 20;
    return result.clamp(0, 100);
  }

  String? _dimensionValidator(String? value) {
    final number = double.tryParse(value ?? '');
    return number == null || number <= 0 ? 'أدخل رقمًا صحيحًا' : null;
  }

  double _estimatePrice(double area, double depth) {
    final multiplier = widget.workshop.id == 'blacksmith' ? 1250 : (widget.workshop.id == 'aluminum' ? 980 : 760);
    final depthFactor = widget.workshop.id == 'carpentry' ? 1 + (depth.clamp(0, 150) / 1000) : 1;
    return (area * multiplier * depthFactor).clamp(0, 999999);
  }

  Widget _livePreview(double area, double estimate, double depth) => AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: widget.workshop.color.withValues(alpha: .08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: widget.workshop.color.withValues(alpha: .28)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [Icon(Icons.auto_awesome, color: widget.workshop.color, size: 19), const SizedBox(width: 7), const Text('معاينة المواصفات الحية', style: TextStyle(fontWeight: FontWeight.w900, color: primary))]),
            const SizedBox(height: 12),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('المساحة التقديرية', style: TextStyle(color: textMuted, fontSize: 12)), Text('${area.toStringAsFixed(2)} م²', style: const TextStyle(fontWeight: FontWeight.w900, color: primary))]),
            const SizedBox(height: 7),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('التكلفة الأولية', style: TextStyle(color: textMuted, fontSize: 12)), Text('${estimate.toStringAsFixed(0)} ر.س', style: const TextStyle(fontWeight: FontWeight.w900, color: accent))]),
            if (widget.workshop.id == 'carpentry') ...[
              const SizedBox(height: 7),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('العمق', style: TextStyle(color: textMuted, fontSize: 12)), Text('${depth.toStringAsFixed(0)} سم', style: const TextStyle(fontWeight: FontWeight.w700, color: primary))]),
            ],
            const SizedBox(height: 10),
            const Text('التقدير مبدئي ويتغير بعد مراجعة التصميم والمقاسات من الورشة.', style: TextStyle(color: textMuted, fontSize: 10)),
          ],
        ),
      );

  String get _orderDescription {
    final base = descriptionController.text.trim();
    if (widget.workshop.id == 'blacksmith') return '$base | معالجة الأسطح: $blacksmithTreatment';
    if (widget.workshop.id == 'aluminum') return '$base | نوع الزجاج: $aluminumGlazing';
    return base;
  }

  List<String> get materialOptions => widget.workshop.id == 'carpentry'
      ? WorkshopOrderOptions.carpentryMaterials
      : widget.workshop.id == 'blacksmith'
          ? WorkshopOrderOptions.blacksmithThicknesses
          : WorkshopOrderOptions.aluminumProfiles;
}
