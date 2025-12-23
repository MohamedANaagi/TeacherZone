# إعداد Bunny Storage لرفع الفيديوهات

## نظرة عامة

تم إضافة ميزة رفع الفيديوهات إلى Bunny Storage بدلاً من إدخال URL يدوياً. الآن الأدمن يمكنه رفع الفيديو مباشرة من الأدمن بنل.

## الخطوات المطلوبة

### 1. إنشاء حساب في Bunny Storage

1. **اذهب إلى [Bunny.net](https://bunny.net/)**
2. **سجل حساب جديد** (إذا لم يكن لديك حساب)
3. **سجل الدخول**

### 2. إنشاء Storage Zone

1. **من Dashboard، اذهب إلى Storage**
2. **اضغط على "Add Storage Zone"**
3. **أدخل المعلومات:**
   - **Name**: اسم Storage Zone (مثل: `teacherzone-videos`)
   - **Region**: اختر أقرب منطقة (مثل: `Falkenstein` أو `New York`)
   - **Replication Regions**: (اختياري)
4. **اضغط "Add Storage Zone"**

### 3. الحصول على API Key

1. **بعد إنشاء Storage Zone، اضغط على Storage Zone**
2. **اذهب إلى تبويب "FTP & HTTP API"**
3. **انسخ "Password"** - هذا هو API Key الخاص بك

### 4. الحصول على CDN URL

1. **من صفحة Storage Zone**
2. **انسخ "Storage Zone Name"** (مثل: `teacherzone-videos`)
3. **CDN URL سيكون:** `https://teacherzone-videos.b-cdn.net`

### 5. تحديث الكود

افتح ملف `lib/core/services/bunny_storage_service.dart` وحدّث القيم التالية:

```dart
static const String _storageZoneName = 'YOUR_STORAGE_ZONE_NAME'; // ⚠️ ضع اسم Storage Zone هنا
static const String _apiKey = 'YOUR_API_KEY'; // ⚠️ ضع API Key هنا
static const String _cdnUrl = 'https://YOUR_STORAGE_ZONE_NAME.b-cdn.net'; // ⚠️ ضع CDN URL هنا
```

#### مثال:

```dart
static const String _storageZoneName = 'teacherzone-videos';
static const String _apiKey = 'abc123def456ghi789jkl012mno345pqr678';
static const String _cdnUrl = 'https://teacherzone-videos.b-cdn.net';
```

---

## كيفية الاستخدام

### 1. في الأدمن بنل:

1. **اذهب إلى "إدارة الفيديوهات"**
2. **اختر الكورس**
3. **أدخل عنوان الفيديو**
4. **اضغط على "اختر ملف الفيديو"**
5. **اختر ملف الفيديو من الجهاز**
6. **سيتم رفع الفيديو تلقائياً إلى Bunny Storage**
7. **بعد الرفع، اضغط "إضافة الفيديو"**
8. **سيتم حفظ URL في Firestore تلقائياً**

### 2. في التطبيق:

- الفيديوهات ستُعرض من Bunny Storage CDN
- الأداء سيكون أفضل بسبب CDN
- الفيديوهات ستكون محمية ومتاحة فقط عبر URL

---

## ملاحظات مهمة

### 1. حجم الملفات:

- Bunny Storage يدعم ملفات كبيرة
- لا توجد قيود صارمة على الحجم
- لكن يُنصح بعدم رفع ملفات أكبر من 2GB

### 2. الأمان:

- API Key يجب أن يبقى سرياً
- لا تشارك API Key مع أي شخص
- يمكنك إنشاء API Key جديد من Bunny Dashboard

### 3. التكلفة:

- Bunny Storage يوفر خطة مجانية محدودة
- بعد ذلك، التكلفة تعتمد على الاستخدام
- راجع [Bunny.net Pricing](https://bunny.net/pricing/) للتفاصيل

### 4. المناطق (Regions):

- اختر أقرب منطقة للمستخدمين
- هذا سيحسن سرعة التحميل
- يمكنك إضافة Replication Regions لتحسين الأداء

---

## استكشاف الأخطاء

### خطأ: "فشل رفع الفيديو: 401"

**السبب:** API Key غير صحيح

**الحل:**

1. تحقق من API Key في `bunny_storage_service.dart`
2. تأكد من نسخ API Key بشكل صحيح
3. جرب إنشاء API Key جديد من Bunny Dashboard

### خطأ: "فشل رفع الفيديو: 404"

**السبب:** Storage Zone Name غير صحيح

**الحل:**

1. تحقق من Storage Zone Name في `bunny_storage_service.dart`
2. تأكد من أن Storage Zone موجود في Bunny Dashboard
3. تأكد من كتابة الاسم بشكل صحيح (حساس لحالة الأحرف)

### خطأ: "فشل رفع الفيديو: 413"

**السبب:** حجم الملف كبير جداً

**الحل:**

1. قلل حجم الفيديو
2. استخدم ضغط الفيديو قبل الرفع
3. راجع حدود Bunny Storage

---

## مثال كامل

### 1. في Bunny Dashboard:

```
Storage Zone Name: teacherzone-videos
Region: Falkenstein
API Key: abc123def456ghi789jkl012mno345pqr678
CDN URL: https://teacherzone-videos.b-cdn.net
```

### 2. في الكود:

```dart
// lib/core/services/bunny_storage_service.dart
static const String _storageZoneName = 'teacherzone-videos';
static const String _apiKey = 'abc123def456ghi789jkl012mno345pqr678';
static const String _cdnUrl = 'https://teacherzone-videos.b-cdn.net';
```

### 3. النتيجة:

- عند رفع فيديو، سيتم حفظه في: `https://teacherzone-videos.b-cdn.net/courseId_timestamp_filename.mp4`
- URL سيتم حفظه في Firestore تلقائياً
- الفيديو سيكون متاحاً في التطبيق

---

## الخلاصة

✅ **تم إضافة:**

- رفع الفيديوهات إلى Bunny Storage
- اختيار ملف الفيديو من الجهاز
- حفظ URL تلقائياً في Firestore

✅ **المطلوب:**

1. إنشاء Storage Zone في Bunny.net
2. الحصول على API Key
3. تحديث القيم في `bunny_storage_service.dart`

✅ **بعد الإعداد:**

- يمكن للأدمن رفع الفيديوهات مباشرة من الأدمن بنل
- الفيديوهات ستُعرض من Bunny CDN
- الأداء سيكون أفضل
