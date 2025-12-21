# ⚡ حل مشكلة البناء البطيء على iOS

## المشكلة:

Xcode build يستغرق وقت طويل جداً عند "Running Xcode build..."

## الحل السريع (أول ما تفعله):

### 1. حذف DerivedData (الأسرع):

```bash
rm -rf ~/Library/Developer/Xcode/DerivedData/*
```

### 2. إيقاف Indexing في Xcode:

- افتح Xcode
- `Xcode` > `Settings` > `General`
- Uncheck `Enable Source Indexing`

### 3. استخدام Build Cache:

```bash
# في terminal قبل flutter run
export FLUTTER_BUILD_MODE=debug
export COMPILER_INDEX_STORE_ENABLE=NO
flutter run
```

## حلول إضافية:

### استخدام Simulator بدلاً من Device (أسرع 10x):

```bash
flutter run -d simulator
```

### Build بدون تشغيل أول مرة (للتسريع):

```bash
flutter build ios --debug --simulator --no-codesign
```

### تفعيل Parallel Builds:

في Xcode:

- `File` > `Project Settings` > `Build System` > `New Build System`
- `File` > `Workspace Settings` > `Build System` > `New Build System`

## ⚠️ ملاحظات مهمة:

1. **أول build دائماً بطيء** - هذا طبيعي (5-15 دقيقة)
2. **Builds التالية أسرع بكثير** (30 ثانية - 2 دقيقة)
3. **إذا استمر أكثر من 20 دقيقة**، جرب حذف DerivedData

## إذا استمرت المشكلة:

```bash
# تنظيف شامل
rm -rf ~/Library/Developer/Xcode/DerivedData/*
flutter clean
cd ios && rm -rf Pods Podfile.lock && pod install && cd ..
flutter run --debug
```
