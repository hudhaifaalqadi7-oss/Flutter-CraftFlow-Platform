# CraftFlow Flutter

تحويل واجهات CraftFlow إلى تطبيق Flutter عربي باتجاه RTL.

## Architecture

يتبع التطبيق تقسيمًا قريبًا من Clean Architecture:

- `lib/core`: الثيم والألوان والخدمات المشتركة.
- `lib/domain/entities`: نماذج المجال مثل `Workshop`.
- `lib/data/services`: التكامل مع API عبر `ApiService`.
- `lib/presentation/screens`: شاشات البداية، النجارة، الحدادة، والألمنيوم في ملفات مستقلة.
- `lib/presentation/widgets`: المكوّنات المشتركة مثل `FeaturePage` و`SheetModal`.
- `lib/main.dart`: Composition root للتطبيق، يركّب الطبقات ويعرّف التنقل فقط.

## الشاشات والتنقل

يحتوي التدفق الكامل على 27 شاشة:

- 3 شاشات بداية: Splash وOnboarding وAuth Gate.
- 8 شاشات للنجارة.
- 8 شاشات للحدادة.
- 8 شاشات للألمنيوم.

تتوفر الشاشات الثماني الخاصة بكل ورشة من Drawer، بينما تعرض NavigationBar الصفحة الرئيسية والمعرض والطلب الجديد. يحتوي كل مسار على AppBar موحد، وتستخدم الطلبات SheetModal مشتركة، مع اتجاه RTL وخط Cairo مخصص.

## API Integration

غيّر العنوان داخل `ApiService.getWorkshopSummary` إلى عنوان الخادم الحقيقي، ثم أضف المصادقة وواجهات الطلبات بحسب عقد API الخاص بالمشروع. حالياً يستخدم التطبيق بيانات تجريبية حتى يعمل التصميم دون خادم.

## التشغيل

بعد تثبيت Flutter وإضافته إلى PATH من مجلد المشروع:

```powershell
flutter pub get
flutter run
```

للتشغيل على Edge بعد إنشاء ملفات المنصة:

```powershell
flutter run -d edge
```
