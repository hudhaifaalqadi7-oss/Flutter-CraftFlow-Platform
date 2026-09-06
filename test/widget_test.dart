// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:craftflow/main.dart';
import 'package:craftflow/domain/entities/workshop.dart';
import 'package:craftflow/presentation/widgets/order_form.dart';
import 'package:craftflow/presentation/widgets/workshop_hub_page.dart';
import 'package:craftflow/presentation/state/app_store.dart';

void main() {
  testWidgets('CraftFlow completes the onboarding flow',
      (WidgetTester tester) async {
    await tester.pumpWidget(const CraftFlowApp());

    expect(find.text('CraftFlow'), findsOneWidget);
    await tester.tap(find.byType(InkWell).first);
    await tester.pumpAndSettle();
    expect(find.text('توزيع الأحمال الخوارزمي'), findsOneWidget);
    await tester.tap(find.text('التالي'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('التالي'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('ابدأ الآن'));
    await tester.pumpAndSettle();
    expect(find.text('إنشاء حساب جديد'), findsOneWidget);
    expect(find.text('عميل المنصة'), findsOneWidget);
    expect(find.text('عضوية التميز النخبوية النخبة VIP'), findsOneWidget);
  });

  test('each workshop exposes eight screens', () {
    for (final workshop in workshops) {
      expect(buildWorkshopScreens(workshop, () {}).length, 8);
    }
  });

  testWidgets('workshop hub filters categories by search and chip selection',
      (WidgetTester tester) async {
    await tester.pumpWidget(StoreScope(
      notifier: AppStore(),
      child: MaterialApp(
        home: Scaffold(
          body: WorkshopHubPage(workshop: workshops[2], onNewOrder: () {}),
        ),
      ),
    ));

    await tester.enterText(find.byType(TextField), 'سرايا');
    await tester.pumpAndSettle();

    expect(find.text('نوافذ قطاع سرايا عازل'), findsOneWidget);
    expect(find.text('واجهات وأبواب ألمنيوم'), findsNothing);

    await tester.tap(find.text('الروشان'));
    await tester.pumpAndSettle();

    expect(find.text('نوافذ قطاع سرايا عازل'), findsNothing);
    expect(find.text('لا توجد تصاميم مطابقة للبحث'), findsOneWidget);
  });

  testWidgets('order form validates required data',
      (WidgetTester tester) async {
    await tester.pumpWidget(StoreScope(
      notifier: AppStore(),
      child: MaterialApp(home: Scaffold(body: OrderFormPage(workshop: workshops.first))),
    ));

    expect(find.text('صمّم طلبك خطوة بخطوة'), findsOneWidget);
    expect(find.text('اسم العمل أو المشروع'), findsOneWidget);
    expect(find.text('وصف العمل والتفاصيل المطلوبة'), findsOneWidget);
  });
}
