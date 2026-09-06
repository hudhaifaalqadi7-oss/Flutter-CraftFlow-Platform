import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/entities/workshop.dart';
import '../widgets/workshop_media.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({required this.onContinue, super.key});
  final VoidCallback onContinue;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _progressController;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
    )
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed && mounted) {
          widget.onContinue();
        }
      })
      ..forward();
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: const Color(0xFF0B252E),
        body: SafeArea(
          child: InkWell(
            onTap: widget.onContinue,
            child: LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: 420,
                      minHeight: constraints.maxHeight - 64,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 320,
                          height: 124,
                          padding: const EdgeInsets.symmetric(horizontal: 22),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: accent.withOpacity(0.24),
                                blurRadius: 24,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 72,
                                height: 72,
                                decoration: BoxDecoration(
                                  color: primary,
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: const Icon(
                                  Icons.construction_rounded,
                                  color: accent,
                                  size: 38,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Flexible(
                                child: Directionality(
                                  textDirection: TextDirection.ltr,
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text.rich(
                                      TextSpan(
                                        text: 'Craft',
                                        style: TextStyle(
                                          color: primary,
                                          fontSize: 28,
                                          fontWeight: FontWeight.w300,
                                        ),
                                        children: [
                                          TextSpan(
                                            text: 'Flow',
                                            style: TextStyle(
                                              color: accent,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 22),
                        const Text(
                          'النظام الذكي لإدارة وموازنة أحمال الورش',
                          style: TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                        const SizedBox(height: 36),
                        SizedBox(
                          width: 140,
                          height: 4,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(2),
                            child: AnimatedBuilder(
                              animation: _progressController,
                              builder: (context, child) =>
                                  LinearProgressIndicator(
                                value: _progressController.value,
                                color: accent,
                                backgroundColor: Colors.white12,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({required this.onContinue, super.key});
  final VoidCallback onContinue;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int step = 0;
  static const steps = [
    (
      'assets/images/blacksmith_hero.jpg',
      'توزيع الأحمال الخوارزمي',
      'يقوم النظام تلقائياً بتحليل السعة الاستيعابية الحالية للورش وتوجيه طلبك للورشة الأسرع والأقل ضغطاً لضمان أوقات تسليم قياسية.'
    ),
    (
      'assets/images/carpentry_hero.jpg',
      'تتبع لحظي دقيق للإنتاج والتشكيل',
      'راقب مراحل تصنيع أثاثك أو حديدك خطوة بخطوة من التقصيب واللحام وحتى الطلاء والتركيب عبر تحديثات حية وصور مباشرة من قلب الورشة.'
    ),
    (
      'assets/images/aluminum_hero.jpg',
      'معارض أعمال موثقة رقمياً بالكامل',
      'استعرض المنتجات الحقيقية المنفذة سابقاً بالمنصة مع تفاصيل دقيقة تشمل وزن المواد، سماكتها بالمليمتر، كلفة المتر التقريبية ومراجعات دقة القياس.'
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final item = steps[step];
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 520),
                        child: AspectRatio(
                          aspectRatio: 16 / 9,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: CraftImage(
                              url: item.$1,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        item.$2,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: primary),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        item.$3,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 13.5, color: textMuted, height: 1.6),
                      ),
                    ],
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  steps.length,
                  (index) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: index == step ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: index == step ? accent : primary.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: step == steps.length - 1
                      ? widget.onContinue
                      : () => setState(() => step++),
                  style: FilledButton.styleFrom(
                    backgroundColor: accent,
                    foregroundColor: primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    step == steps.length - 1 ? 'ابدأ الآن' : 'التالي',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AuthGateScreen extends StatefulWidget {
  const AuthGateScreen({required this.onSubmit, super.key});
  final Future<void> Function(Workshop workshop, bool craftsman, String name, String phone, String password, bool isLoginMode) onSubmit;

  @override
  State<AuthGateScreen> createState() => _AuthGateScreenState();
}

class _AuthGateScreenState extends State<AuthGateScreen> {
  final nameController = TextEditingController(text: 'عبدالله الشمري');
  final phoneController = TextEditingController(text: '+966 50 000 0000');
  final passwordController = TextEditingController(text: 'craftflow123');
  bool craftsman = false;
  bool submitting = false;
  bool isLoginMode = false;
  int selectedPlan = 0;
  Workshop selectedWorkshop = workshops.first;

  @override
  Widget build(BuildContext context) {
    final title = isLoginMode ? 'تسجيل الدخول' : 'إنشاء حساب جديد';
    final subtitle = isLoginMode ? 'سجل الدخول إلى حسابك لاستمرار العمل' : 'انضم إلى أكبر شبكة إنتاجية ذكية مؤتمتة';

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(title,
                style: const TextStyle(
                    fontSize: 22, fontWeight: FontWeight.w700, color: primary)),
            Text(subtitle,
                style: const TextStyle(fontSize: 13, color: textMuted)),
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                  color: primary.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(16)),
              padding: const EdgeInsets.all(4),
              child: Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => setState(() {
                        craftsman = false;
                        selectedPlan = 0;
                      }),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: !craftsman ? Colors.white : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: !craftsman
                              ? [
                                  BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 4)
                                ]
                              : [],
                        ),
                        alignment: Alignment.center,
                        child: Text('عميل المنصة',
                            style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: !craftsman ? primary : textMuted)),
                      ),
                    ),
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: () => setState(() {
                        craftsman = true;
                        selectedPlan = 0;
                      }),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: craftsman ? Colors.white : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: craftsman
                              ? [
                                  BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 4)
                                ]
                              : [],
                        ),
                        alignment: Alignment.center,
                        child: Text('صاحب الورشة',
                            style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: craftsman ? primary : textMuted)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: primary.withOpacity(0.06),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => setState(() => isLoginMode = false),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: !isLoginMode ? Colors.white : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        alignment: Alignment.center,
                        child: Text('حساب جديد', style: TextStyle(fontWeight: FontWeight.w700, color: !isLoginMode ? primary : textMuted)),
                      ),
                    ),
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: () => setState(() => isLoginMode = true),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: isLoginMode ? Colors.white : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        alignment: Alignment.center,
                        child: Text('تسجيل دخول', style: TextStyle(fontWeight: FontWeight.w700, color: isLoginMode ? primary : textMuted)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (!isLoginMode) ...[
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'الاسم الكامل',
                  prefixIcon: const Icon(Icons.person, color: textMuted),
                  border:
                      OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
            ],
            TextFormField(
              controller: phoneController,
              decoration: InputDecoration(
                labelText: 'رقم الجوال',
                prefixIcon: const Icon(Icons.phone, color: textMuted),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'كلمة المرور',
                prefixIcon: const Icon(Icons.lock, color: textMuted),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 20),
            if (!isLoginMode) ...[
              const Text('اختر باقة الاشتراك المخصصة لربح وتأمين المعاملات',
                  style: TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w700, color: primary)),
              const SizedBox(height: 10),
              ...currentPlans.map((p) {
              final isSelected = selectedPlan == p.id;
              return InkWell(
                onTap: () => setState(() => selectedPlan = p.id),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isSelected ? accent.withOpacity(0.05) : Colors.white,
                    border: Border.all(
                        color: isSelected ? accent : const Color(0x11114B5F),
                        width: isSelected ? 2 : 1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(p.title,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                    color: primary)),
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(p.price,
                                textAlign: TextAlign.end,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 15,
                                    color: accent)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ...p.features.map(
                        (f) => Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Row(
                            children: [
                              const Icon(Icons.check,
                                  size: 14, color: successColor),
                              const SizedBox(width: 6),
                              Expanded(
                                  child: Text(f,
                                      style: const TextStyle(
                                          fontSize: 11.5, color: textMuted))),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
              const SizedBox(height: 10),
              DropdownButtonFormField<Workshop>(
                value: selectedWorkshop,
                decoration: InputDecoration(
                  labelText: 'اختر مجال الورشة الافتراضي',
                  border:
                      OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                items: workshops
                    .map((w) => DropdownMenuItem(value: w, child: Text(w.name)))
                    .toList(),
                onChanged: (val) =>
                    setState(() => selectedWorkshop = val ?? selectedWorkshop),
              ),
              const SizedBox(height: 20),
            ],
            FilledButton(
              onPressed: submitting ? null : () async {
                if (isLoginMode) {
                  final phone = phoneController.text.trim();
                  final password = passwordController.text.trim();
                  if (phone.isEmpty || password.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('أدخل رقم الجوال وكلمة المرور')));
                    return;
                  }
                } else if (nameController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('أدخل الاسم الكامل')));
                  return;
                }

                setState(() => submitting = true);
                await widget.onSubmit(
                  selectedWorkshop,
                  craftsman,
                  nameController.text.trim(),
                  phoneController.text.trim(),
                  passwordController.text,
                  isLoginMode,
                );
                if (mounted) setState(() => submitting = false);
              },
              style: FilledButton.styleFrom(
                backgroundColor: primary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(submitting ? (isLoginMode ? 'جارٍ تسجيل الدخول...' : 'جارٍ حفظ الحساب...') : (isLoginMode ? 'تسجيل الدخول والدخول' : 'تأكيد الاشتراك والدخول'),
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(width: 8),
                  const Icon(Icons.check_circle, size: 18),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<PlanItem> get currentPlans => craftsman
      ? [
          const PlanItem(
            0,
            'باقة الورشة الناشئة المعتمدة Starter',
            '149 ر.س/شهر',
            [
              'استقبال طلبات التفصيل المخصصة القريبة جغرافياً',
              'لوحة تحكم ومراقبة جرد مستودع المواد الخام',
            ],
          ),
          const PlanItem(
            1,
            'باقة المصنع المتكامل المؤتمتة الفاخرة Pro',
            '399 ر.س/شهر',
            [
              'أولوية استقبال التدفقات الضخمة من خوارزميات موازنة الأحمال',
              'دعم مسح الباركود السريع للفنيين وتحديثات الكاميرا الحية',
              'تقارير وتحليلات جودة المقاسات والالتزام بالمواعيد الموثقة',
            ],
          ),
        ]
      : [
          const PlanItem(
            0,
            'الباقة الأساسية المجانية التنافسية',
            '0 ر.س',
            [
              'طلب تفصيل واحد نشط في الورش',
              'تتبع الخط الزمني الاعتيادي للمواصفات',
            ],
          ),
          const PlanItem(
            1,
            'عضوية التميز النخبوية النخبة VIP',
            '39 ر.س/شهر',
            [
              'أولوية قصوى وجدولة فورية في مكائن ليزر الورش الكبرى',
              'تفعيل فوري ومجاني لكرت الضمان الرقمي ضد تسريب المياه',
              'رفع غير محدود لملفات الأوتوكاد والمخططات المعقدة',
            ],
          ),
        ];
}

class PlanItem {
  final int id;
  final String title;
  final String price;
  final List<String> features;
  const PlanItem(this.id, this.title, this.price, this.features);
}
