import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/entities/workshop.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({required this.onContinue, super.key});
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Container(
          decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF092C38), primary], begin: Alignment.topRight, end: Alignment.bottomLeft)),
          child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [const Icon(Icons.handyman, size: 82, color: accent), const SizedBox(height: 20), const Text('CraftFlow', style: TextStyle(fontSize: 40, fontWeight: FontWeight.w900, color: accent)), const SizedBox(height: 32), FilledButton(onPressed: onContinue, child: const Text('متابعة'))])),
        ),
      );
}

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({required this.onContinue, super.key});
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('اكتشف CraftFlow')),
        body: ListView(padding: const EdgeInsets.all(24), children: [const Icon(Icons.auto_awesome, size: 72, color: accent), const SizedBox(height: 20), const Text('منصة واحدة لكل ورش الحرفيين', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: primary)), const SizedBox(height: 12), const Text('أنشئ الطلب، اختر النموذج، تابع الإنتاج، واعتمد التسليم من مكان واحد.'), const SizedBox(height: 24), ...[('طلب مخصص', Icons.assignment), ('توزيع ذكي', Icons.insights), ('جودة وضمان', Icons.verified)].map((item) => Card(child: ListTile(leading: Icon(item.$2, color: accent), title: Text(item.$1)))), const SizedBox(height: 20), FilledButton.icon(onPressed: onContinue, icon: const Icon(Icons.arrow_back), label: const Text('ابدأ الآن'))]),
      );
}

class AuthGateScreen extends StatelessWidget {
  const AuthGateScreen({required this.onWorkshopSelected, super.key});
  final ValueChanged<Workshop> onWorkshopSelected;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('بوابة الدخول')),
        body: ListView(padding: const EdgeInsets.all(24), children: [const Text('CraftFlow', style: TextStyle(fontSize: 34, fontWeight: FontWeight.w900, color: accent)), const SizedBox(height: 12), const Text('اختر مجال الورشة للمتابعة', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: primary)), const SizedBox(height: 8), const Text('ستتغير بيانات العمل والألوان حسب المجال المختار.', style: TextStyle(color: muted)), const SizedBox(height: 20), ...workshops.map((workshop) => Padding(padding: const EdgeInsets.only(bottom: 12), child: FilledButton.icon(onPressed: () => onWorkshopSelected(workshop), icon: Icon(workshop.icon), label: Text(workshop.name), style: FilledButton.styleFrom(backgroundColor: workshop.color, minimumSize: const Size.fromHeight(54)))))]),
      );
}
