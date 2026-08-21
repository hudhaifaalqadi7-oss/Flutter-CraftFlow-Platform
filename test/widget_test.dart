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

void main() {
  testWidgets('CraftFlow completes the onboarding flow',
      (WidgetTester tester) async {
    await tester.pumpWidget(const CraftFlowApp());

    expect(find.text('CraftFlow'), findsOneWidget);
    await tester.tap(find.text('متابعة'));
    await tester.pumpAndSettle();
    expect(find.text('اكتشف CraftFlow'), findsOneWidget);
    await tester.tap(find.text('ابدأ الآن'));
    await tester.pumpAndSettle();
    expect(find.text('اختر مجال الورشة للمتابعة'), findsOneWidget);
  });

  test('each workshop exposes eight screens', () {
    for (final workshop in workshops) {
      expect(buildWorkshopScreens(workshop, () {}).length, 8);
    }
  });

  testWidgets('order form validates required data', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: OrderFormPage(workshop: workshops.first))));

    await tester.tap(find.text('تأكيد وتشغيل التوزيع'));
    await tester.pump();

    expect(find.text('أدخل اسم الطلب'), findsOneWidget);
    expect(find.text('أدخل وصف العمل'), findsOneWidget);
    expect(find.text('أدخل رقمًا صحيحًا'), findsNWidgets(2));
  });
}
