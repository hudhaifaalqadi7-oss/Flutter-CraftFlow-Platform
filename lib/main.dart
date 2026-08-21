import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'data/services/api_service.dart';
import 'domain/entities/workshop.dart';
import 'presentation/screens/initial_screens.dart';
import 'presentation/screens/carpentry_screens.dart';
import 'presentation/screens/blacksmith_screens.dart';
import 'presentation/screens/aluminum_screens.dart';
import 'presentation/widgets/order_sheet.dart';
import 'presentation/state/app_store.dart';

void main() => runApp(const CraftFlowApp());

class CraftFlowApp extends StatelessWidget {
  const CraftFlowApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'CraftFlow',
        theme: buildAppTheme(),
        home: StoreScope(notifier: AppStore(), child: const StudioShell()),
      );
}

class StudioShell extends StatefulWidget {
  const StudioShell({super.key});
  @override
  State<StudioShell> createState() => _StudioShellState();
}

class _StudioShellState extends State<StudioShell> {
  int stage = 0;
  Workshop? workshop;

  @override
  Widget build(BuildContext context) {
    if (stage == 0) return SplashScreen(onContinue: () => setState(() => stage = 1));
    if (stage == 1) return OnboardingScreen(onContinue: () => setState(() => stage = 2));
    if (workshop == null) return Directionality(textDirection: TextDirection.rtl, child: AuthGateScreen(onWorkshopSelected: (value) => setState(() => workshop = value)));
    return Directionality(textDirection: TextDirection.rtl, child: WorkshopShell(workshop: workshop!, onExit: () => setState(() => workshop = null)));
  }
}

class WorkshopShell extends StatefulWidget {
  const WorkshopShell({required this.workshop, required this.onExit, super.key});
  final Workshop workshop;
  final VoidCallback onExit;
  @override
  State<WorkshopShell> createState() => _WorkshopShellState();
}

class _WorkshopShellState extends State<WorkshopShell> {
  int page = 0;
  final api = const ApiService();
  late Future<Map<String, dynamic>> summary;

  @override
  void initState() {
    super.initState();
    summary = api.getWorkshopSummary(widget.workshop.id);
    WidgetsBinding.instance.addPostFrameCallback((_) => StoreScope.of(context).load(widget.workshop));
  }

  @override
  Widget build(BuildContext context) {
    final available = buildWorkshopScreens(widget.workshop, () => showOrderSheet(context, widget.workshop));
    return Scaffold(
      appBar: AppBar(
        title: Text(available[page].title),
        leading: Builder(
          builder: (context) => IconButton(
            onPressed: () => Scaffold.of(context).openDrawer(),
            tooltip: 'فتح القائمة',
            icon: const Icon(Icons.menu),
          ),
        ),
        actions: [
          if (page == 0) IconButton(onPressed: widget.onExit, tooltip: 'اختيار ورشة أخرى', icon: const Icon(Icons.arrow_forward)),
          if (page != 0) IconButton(onPressed: () => setState(() => page = 0), tooltip: 'الرئيسية', icon: const Icon(Icons.home_outlined)),
          IconButton(onPressed: () => setState(() => summary = api.getWorkshopSummary(widget.workshop.id)), tooltip: 'تحديث', icon: const Icon(Icons.sync)),
        ],
      ),
      drawer: AppDrawer(workshop: widget.workshop, screens: available, selected: page, onSelected: (index) { Navigator.pop(context); setState(() => page = index); }),
      body: available[page].builder(context, summary),
      bottomNavigationBar: NavigationBar(
        selectedIndex: page.clamp(0, 2),
        onDestinationSelected: (index) => setState(() => page = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: 'الرئيسية'),
          NavigationDestination(icon: Icon(Icons.photo_library_outlined), selectedIcon: Icon(Icons.photo_library), label: 'المعرض'),
          NavigationDestination(icon: Icon(Icons.add_task), label: 'طلب جديد'),
        ],
      ),
    );
  }
}

class AppDrawer extends StatelessWidget {
  const AppDrawer({required this.workshop, required this.screens, required this.selected, required this.onSelected, super.key});
  final Workshop workshop;
  final List<ScreenSpec> screens;
  final int selected;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) => Drawer(
        child: SafeArea(
          child: ListView(padding: const EdgeInsets.all(16), children: [
            Text('CraftFlow', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: workshop.color)),
            Text(workshop.name, style: const TextStyle(color: muted)),
            const Divider(height: 32),
            ...screens.asMap().entries.map((entry) => ListTile(selected: entry.key == selected, leading: Icon(entry.value.icon), title: Text(entry.value.title), onTap: () => onSelected(entry.key))),
          ]),
        ),
      );
}

class ScreenSpec {
  const ScreenSpec(this.title, this.icon, this.builder);
  final String title;
  final IconData icon;
  final Widget Function(BuildContext, Future<Map<String, dynamic>>) builder;
}

List<ScreenSpec> buildWorkshopScreens(Workshop workshop, VoidCallback newOrder) {
  if (workshop.id == 'carpentry') {
    return [
      ScreenSpec('رئيسية النجارة', workshop.icon, (context, data) => CarpentryHubScreen(workshop: workshop, onNewOrder: newOrder)),
      ScreenSpec('معرض أعمال النجارة', Icons.photo_library, (context, data) => CarpentryPortfolioScreen(workshop: workshop)),
      ScreenSpec('طلب تفصيل مخصص', Icons.assignment, (context, data) => CarpentryOrderScreen(workshop: workshop)),
      ScreenSpec('موازنة الأحمال الذكية', Icons.insights, (context, data) => CarpentryBalancerScreen(workshop: workshop)),
      ScreenSpec('الخط الزمني للإنتاج', Icons.timeline, (context, data) => CarpentryTimelineScreen(workshop: workshop)),
      ScreenSpec('لوحة الحرفي السريعة', Icons.build_circle, (context, data) => CarpentryCraftsmanScreen(workshop: workshop)),
      ScreenSpec('إدارة المواد الخام', Icons.inventory_2, (context, data) => CarpentryInventoryScreen(workshop: workshop)),
      ScreenSpec('تقييم جودة النجارة', Icons.verified, (context, data) => CarpentryReviewScreen(workshop: workshop)),
    ];
  }
  if (workshop.id == 'blacksmith') {
    return [
      ScreenSpec('رئيسية الحدادة', workshop.icon, (context, data) => BlacksmithHubScreen(workshop: workshop, onNewOrder: newOrder)),
      ScreenSpec('معرض الحديد المعشق', Icons.photo_library, (context, data) => BlacksmithPortfolioScreen(workshop: workshop)),
      ScreenSpec('تفصيل الحديد السفلي', Icons.assignment, (context, data) => BlacksmithOrderScreen(workshop: workshop)),
      ScreenSpec('سعة الورش والقدرات', Icons.insights, (context, data) => BlacksmithBalancerScreen(workshop: workshop)),
      ScreenSpec('الخط الزمني للتشكيل', Icons.timeline, (context, data) => BlacksmithTimelineScreen(workshop: workshop)),
      ScreenSpec('لوحة الأكشن للحداد', Icons.local_fire_department, (context, data) => BlacksmithCraftsmanScreen(workshop: workshop)),
      ScreenSpec('حديد التسليح والخامات', Icons.inventory_2, (context, data) => BlacksmithInventoryScreen(workshop: workshop)),
      ScreenSpec('تنسيق التسليم والتركيب', Icons.local_shipping, (context, data) => BlacksmithDeliveryScreen(workshop: workshop)),
    ];
  }
  return [
    ScreenSpec('رئيسية الألمنيوم', workshop.icon, (context, data) => AluminumHubScreen(workshop: workshop, onNewOrder: newOrder)),
    ScreenSpec('معرض أعمال الكلادينج', Icons.photo_library, (context, data) => AluminumPortfolioScreen(workshop: workshop)),
    ScreenSpec('مواصفات الألمنيوم', Icons.assignment, (context, data) => AluminumOrderScreen(workshop: workshop)),
    ScreenSpec('التوزيع الجغرافي', Icons.location_searching, (context, data) => AluminumBalancerScreen(workshop: workshop)),
    ScreenSpec('خط تجميع الألمنيوم', Icons.timeline, (context, data) => AluminumTimelineScreen(workshop: workshop)),
    ScreenSpec('واجهة الفني السريعة', Icons.qr_code_scanner, (context, data) => AluminumTechScreen(workshop: workshop)),
    ScreenSpec('مستودع القطاعات', Icons.inventory_2, (context, data) => AluminumInventoryScreen(workshop: workshop)),
    ScreenSpec('الفحص والضمان الرقمي', Icons.verified, (context, data) => AluminumWarrantyScreen(workshop: workshop)),
  ];
}
