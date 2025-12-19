# حل مشكلة "Xcode build failed due to concurrent builds"

## المشكلة:

Xcode build يفشل بسبب وجود بناء متزامن (concurrent builds)

## الحل السريع:

### 1. إيقاف جميع عمليات البناء:

```bash
# إيقاف جميع عمليات flutter
pkill -f flutter

# إيقاف جميع عمليات xcodebuild
killall xcodebuild

# إيقاف Xcode إذا كان مفتوحاً
killall Xcode
```

### 2. تنظيف البناء:

```bash
# تنظيف Flutter
flutter clean

# تنظيف iOS build folders
cd ios
rm -rf build
rm -rf ~/Library/Developer/Xcode/DerivedData/*
cd ..

# تنظيف pods (اختياري)
cd ios
rm -rf Pods Podfile.lock
pod install
cd ..
```

### 3. إعادة المحاولة:

```bash
flutter run
```

## حل بديل:

### افتح Xcode وأغلق جميع المشاريع:

1. افتح Xcode
2. أغلق جميع النوافذ المفتوحة
3. من القائمة: **File > Close Workspace** (أو Close Window)
4. أغلق Xcode تماماً
5. ثم شغل `flutter run` مرة أخرى

## إذا استمرت المشكلة:

### شغل Build مرة واحدة فقط:

```bash
# تأكد من عدم وجود عمليات أخرى
ps aux | grep -i xcode
ps aux | grep -i flutter

# إذا وجدت عمليات، أوقفها
killall -9 xcodebuild
killall -9 flutter

# ثم شغل مرة واحدة
flutter run
```

## ملاحظة على تحذير CocoaPods:

التحذير:

```
[!] CocoaPods did not set the base configuration...
```

هذا **تحذير فقط** وليس خطأ. Flutter يتعامل مع هذا تلقائياً، ولا تحتاج لفعل شيء.
