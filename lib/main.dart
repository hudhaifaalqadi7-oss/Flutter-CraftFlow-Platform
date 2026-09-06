import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'domain/entities/workshop.dart';
import 'presentation/screens/initial_screens.dart';
import 'presentation/screens/carpentry_screens.dart';
import 'presentation/screens/blacksmith_screens.dart';
import 'presentation/screens/aluminum_screens.dart';
import 'presentation/widgets/order_sheet.dart';
import 'presentation/widgets/workshop_hub_page.dart';
import 'presentation/widgets/interactive_portfolio_page.dart';
import 'presentation/widgets/interactive_tracking_page.dart';
import 'presentation/widgets/interactive_inventory_page.dart';
import 'presentation/widgets/interactive_capacity_page.dart';
import 'presentation/widgets/interactive_operations_page.dart';
import 'presentation/widgets/interactive_quality_page.dart';
import 'presentation/state/app_store.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const CraftFlowApp());
}

class CraftFlowApp extends StatelessWidget {
  const CraftFlowApp({super.key});

  @override
  Widget build(BuildContext context) => StoreScope(
      notifier: AppStore()..restoreSession(),
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'CraftFlow Prototype Studio',
          theme: buildAppTheme(),
          home: const StudioShell(),
        ),
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
  bool craftsman = false;

  @override
  Widget build(BuildContext context) {
    if (stage == 0) {
      return Directionality(textDirection: TextDirection.rtl, child: SplashScreen(onContinue: () => setState(() => stage = 1)));
    }
    if (stage == 1) {
      return Directionality(textDirection: TextDirection.rtl, child: OnboardingScreen(onContinue: () => setState(() => stage = 2)));
    }
    if (workshop == null) {
      return Directionality(
        textDirection: TextDirection.rtl,
        child: AuthGateScreen(
          onSubmit: (value, role, name, phone, password, isLoginMode) async {
            final store = StoreScope.of(context);
            final success = isLoginMode
                ? await store.loginAccount(phone: phone, password: password)
                : await store.registerAccount(name: name, phone: phone, password: password, craftsman: role, workshopId: value.id);

            if (!success && context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(isLoginMode ? 'تعذر تسجيل الدخول، تحقق من رقم الجوال أو كلمة المرور' : 'تعذر إنشاء الحساب، تحقق من البيانات أو رقم الجوال')),
              );
              return;
            }

            if (mounted) setState(() { workshop = value; craftsman = role; });
          },
        ),
      );
    }
    return Directionality(
      textDirection: TextDirection.rtl,
      child: WorkshopShell(
        workshop: workshop!,
        craftsman: craftsman,
        onExit: () => setState(() {
          workshop = null;
          craftsman = false;
        }),
      ),
    );
  }
}

class WorkshopShell extends StatefulWidget {
  const WorkshopShell({required this.workshop, required this.craftsman, required this.onExit, super.key});
  final Workshop workshop;
  final bool craftsman;
  final VoidCallback onExit;

  @override
  State<WorkshopShell> createState() => _WorkshopShellState();
}

class _WorkshopShellState extends State<WorkshopShell> {
  late int page;

  @override
  void initState() {
    super.initState();
    page = widget.craftsman ? 5 : 0;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      StoreScope.of(context).load(widget.workshop);
    });
  }

  @override
  Widget build(BuildContext context) {
    final store = StoreScope.of(context);
    final available = buildWorkshopScreens(widget.workshop, () => showOrderSheet(context, widget.workshop), readOnlyTracking: !widget.craftsman);
    if (!widget.craftsman) {
      if (widget.workshop.id == 'blacksmith') {
        available.removeAt(7);
      }
      available.removeAt(6);
      available.removeAt(5);
    }
    final safePage = page.clamp(0, available.length - 1);

    return Scaffold(
      appBar: AppBar(
        title: Text(available[safePage].title),
        leading: Builder(
          builder: (context) => IconButton(
            onPressed: () => Scaffold.of(context).openDrawer(),
            icon: const Icon(Icons.menu),
          ),
        ),
        actions: [
          IconButton(
            onPressed: widget.onExit,
            tooltip: 'تبديل الورشة',
            icon: const Icon(Icons.swap_horiz),
          ),
          IconButton(
            onPressed: store.loading ? null : () => store.refresh(),
            tooltip: 'تحديث البيانات من السيرفر',
            icon: store.loading
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.sync),
          ),
        ],
      ),
      drawer: Drawer(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text('CraftFlow Studio', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: widget.workshop.color)),
              Text(widget.workshop.name, style: const TextStyle(color: textMuted, fontSize: 13)),
              const Divider(height: 24),
              ...available.asMap().entries.map(
                    (entry) => ListTile(
                      selected: entry.key == page,
                      selectedTileColor: accent.withValues(alpha: .15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      leading: Icon(entry.value.icon, color: entry.key == page ? primary : textMuted),
                      title: Text(entry.value.title, style: TextStyle(fontWeight: entry.key == page ? FontWeight.bold : FontWeight.normal, fontSize: 13)),
                      onTap: () {
                        Navigator.pop(context);
                        setState(() => page = entry.key);
                      },
                    ),
                  ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          if (store.loading) const LinearProgressIndicator(minHeight: 2, color: accent),
          if (store.error != null)
            MaterialBanner(
              backgroundColor: dangerColor.withValues(alpha: .1),
              leading: const Icon(Icons.cloud_off, color: dangerColor),
              content: const Text('تعذر تحديث بعض البيانات من الخادم. يمكنك إعادة المحاولة.'),
              actions: [TextButton(onPressed: store.loading ? null : () => store.refresh(), child: const Text('إعادة المحاولة'))],
            ),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              switchInCurve: Curves.easeOut,
              child: KeyedSubtree(key: ValueKey(safePage), child: available[safePage].builder(context)),
            ),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: safePage.clamp(0, 2),
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

class ScreenSpec {
  const ScreenSpec(this.title, this.icon, this.builder);
  final String title;
  final IconData icon;
  final Widget Function(BuildContext) builder;
}

List<ScreenSpec> buildWorkshopScreens(Workshop workshop, VoidCallback newOrder, {bool readOnlyTracking = false}) {
  if (workshop.id == 'carpentry') {
    return [
      ScreenSpec('منصة النجارة والأثاث', Icons.dashboard, (context) => WorkshopHubPage(workshop: workshop, onNewOrder: newOrder)),
      ScreenSpec('معرض أعمال المنجور الخشبي', Icons.photo_library, (context) => InteractivePortfolioPage(workshop: workshop)),
      ScreenSpec('طلب تفصيل أثاث مخصص', Icons.tune, (context) => CarpentryOrderScreen(workshop: workshop)),
      ScreenSpec('خوارزمية توزيع أحمال النجارة', Icons.alt_route, (context) => InteractiveCapacityPage(workshop: workshop)),
      ScreenSpec('تتبع إنتاج الخشب لطلبك', Icons.timeline, (context) => InteractiveTrackingPage(workshop: workshop, readOnly: readOnlyTracking)),
      ScreenSpec('لوحة نجارة المعلم الحرفي', Icons.construction, (context) => InteractiveOperationsPage(workshop: workshop)),
      ScreenSpec('مستودع الأخشاب الخام والمقابض', Icons.inventory_2, (context) => InteractiveInventoryPage(workshop: workshop)),
      ScreenSpec('مراجعة وتقييم جودة الأثاث', Icons.verified, (context) => InteractiveQualityPage(workshop: workshop)),
    ];
  }
  if (workshop.id == 'blacksmith') {
    return [
      ScreenSpec('منصة الحدادة والفولاذ المعشق', Icons.dashboard, (context) => WorkshopHubPage(workshop: workshop, onNewOrder: newOrder)),
      ScreenSpec('تصاميم قص الليزر والمشغول', Icons.photo_library, (context) => InteractivePortfolioPage(workshop: workshop)),
      ScreenSpec('مواصفات سماكة صاج الحديد', Icons.tune, (context) => BlacksmithOrderScreen(workshop: workshop)),
      ScreenSpec('سعة الورش ومكائن CNC المتاحة', Icons.precision_manufacturing, (context) => InteractiveCapacityPage(workshop: workshop)),
      ScreenSpec('مراحل تشكيل ومعالجة الحديد', Icons.account_tree, (context) => InteractiveTrackingPage(workshop: workshop, readOnly: readOnlyTracking)),
      ScreenSpec('لوحة أكشن فرن الحداد الناري', Icons.local_fire_department, (context) => InteractiveOperationsPage(workshop: workshop)),
      ScreenSpec('مخزون حديد التسليح والأقراص بار', Icons.inventory_2, (context) => InteractiveInventoryPage(workshop: workshop)),
      ScreenSpec('جدولة نقل ورفع حمايات الحديد', Icons.local_shipping, (context) => BlacksmithDeliveryScreen(workshop: workshop)),
    ];
  }
  return [
    ScreenSpec('منصة الألمنيوم والكلادينج العازل', Icons.dashboard, (context) => WorkshopHubPage(workshop: workshop, onNewOrder: newOrder)),
    ScreenSpec('معرض قطاعات النوافذ المعتمدة', Icons.photo_library, (context) => InteractivePortfolioPage(workshop: workshop)),
    ScreenSpec('تخصيص طبقات الزجاج وسرايا', Icons.tune, (context) => AluminumOrderScreen(workshop: workshop)),
    ScreenSpec('رصد أجهزة كبس الزوايا الآلية', Icons.compass_calibration, (context) => InteractiveCapacityPage(workshop: workshop)),
    ScreenSpec('خط تجميع وضغط الألمنيوم جلاس', Icons.view_in_ar, (context) => InteractiveTrackingPage(workshop: workshop, readOnly: readOnlyTracking)),
    ScreenSpec('ماسح باركود الورش السريع للألمنيوم', Icons.qr_code_scanner, (context) => InteractiveOperationsPage(workshop: workshop)),
    ScreenSpec('مستودع قطاعات الألمنيوم ومطاط ميرندي', Icons.inventory_2, (context) => InteractiveInventoryPage(workshop: workshop)),
    ScreenSpec('وثيقة الضمان الرقمي المعتمد', Icons.verified_user, (context) => InteractiveQualityPage(workshop: workshop)),
  ];
}
