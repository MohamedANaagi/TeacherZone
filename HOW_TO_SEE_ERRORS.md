# كيفية رؤية الأخطاء في Cursor

## الطريقة 1: من Terminal في Cursor

### افتح Terminal في Cursor:

1. اضغط `Ctrl + ~` (أو `Cmd + ~` على Mac) لفتح Terminal
2. أو من القائمة: **View > Terminal**

### شغل أحد هذه الأوامر:

```bash
# لفحص الأخطاء في الكود
flutter analyze

# لبناء التطبيق ومشاهدة الأخطاء
flutter build ios --verbose

# لتشغيل التطبيق ومشاهدة الأخطاء
flutter run --verbose
```

## الطريقة 2: من Problems Panel في Cursor

1. اضغط `Ctrl + Shift + M` (أو `Cmd + Shift + M` على Mac)
2. أو من القائمة: **View > Problems**
3. ستظهر جميع الأخطاء والتحذيرات في القائمة

## الطريقة 3: من Output Panel

1. اضغط `Ctrl + Shift + U` (أو `Cmd + Shift + U` على Mac)
2. أو من القائمة: **View > Output**
3. اختر "Dart" أو "Flutter" من القائمة المنسدلة

## الطريقة 4: من Debug Console

1. اضغط `F5` لبدء Debugging
2. أو من القائمة: **Run > Start Debugging**
3. ستظهر الأخطاء في Debug Console

## الطريقة 5: فحص الأخطاء في Terminal (الأفضل)

افتح Terminal في Cursor وشغل:

```bash
# فحص سريع للأخطاء
flutter analyze

# فحص شامل مع التفاصيل
flutter analyze --verbose

# محاولة بناء المشروع (سيظهر جميع الأخطاء)
flutter build ios

# أو للتشغيل مع رؤية جميع الأخطاء
flutter run -v
```

## إذا كان Build يفشل:

```bash
# تنظيف المشروع
flutter clean

# إعادة تثبيت dependencies
flutter pub get

# محاولة البناء مع verbose لرؤية الأخطاء بالتفصيل
flutter build ios --verbose 2>&1 | tee build_log.txt

# ثم افتح ملف build_log.txt لرؤية الأخطاء
```

## للأخطاء الخاصة بـ iOS:

```bash
# انتقل لمجلد iOS
cd ios

# تنظيف pods
rm -rf Pods Podfile.lock

# إعادة التثبيت
pod install

# العودة للمجلد الرئيسي
cd ..

# محاولة البناء مرة أخرى
flutter build ios --verbose
```

## نصائح:

1. ✅ **استخدم `--verbose`** دائماً لرؤية تفاصيل أكثر
2. ✅ **انسخ الأخطاء** من Terminal ولصقها هنا للمساعدة
3. ✅ **تحقق من Problems Panel** أولاً - قد تكون الأخطاء واضحة هناك
4. ✅ **شغل `flutter doctor`** للتحقق من إعداد Flutter
