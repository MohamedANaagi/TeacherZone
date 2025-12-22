# كيفية إضافة حقل createdAt في Firebase Console

## نظرة عامة

حقل `createdAt` هو تاريخ الإنشاء بتنسيق ISO 8601 (مثل: `"2024-01-15T10:30:00Z"`).

## الطريقة الأولى: إضافة يدوياً

### خطوات إضافة createdAt يدوياً:

1. **افتح Firebase Console**
   - اذهب إلى [Firebase Console](https://console.firebase.google.com/)
   - اختر مشروعك

2. **اذهب إلى Firestore Database**
   - من القائمة الجانبية، اختر **Firestore Database**

3. **اختر Collection**
   - اختر Collection المطلوب (مثل: `codes`, `courses`, `videos`, `adminCodes`)

4. **أضف Document جديد أو عدّل Document موجود**
   - اضغط على **Add document** لإضافة جديد
   - أو اضغط على Document موجود للتعديل

5. **أضف Field جديد:**
   - Field name: `createdAt`
   - Field type: اختر **string**
   - Field value: أدخل التاريخ بتنسيق ISO 8601

### مثال على القيمة:

```
2024-01-15T10:30:00Z
```

أو يمكنك استخدام التاريخ الحالي:
```
2024-12-19T12:00:00Z
```

---

## الطريقة الثانية: استخدام Timestamp (أسهل)

### خطوات استخدام Timestamp:

1. **أضف Field جديد:**
   - Field name: `createdAt`
   - Field type: اختر **timestamp** (بدلاً من string)

2. **اختر التاريخ:**
   - اضغط على أيقونة التقويم
   - اختر التاريخ والوقت
   - أو اضغط على **Set to current time** للتاريخ الحالي

3. **ملاحظة مهمة:**
   - إذا استخدمت `timestamp` type، سيتم تحويله تلقائياً إلى string عند القراءة
   - الكود في التطبيق يدعم كلا النوعين (string و timestamp)

---

## الطريقة الثالثة: استخدام Script (للمحترفين)

إذا كان لديك الكثير من Documents، يمكنك استخدام Firebase CLI أو Cloud Functions لتحديثها تلقائياً.

### مثال باستخدام Firebase CLI:

```bash
# تثبيت Firebase CLI
npm install -g firebase-tools

# تسجيل الدخول
firebase login

# استخدام Firestore emulator أو script
```

---

## أمثلة على القيم الصحيحة:

### تنسيق ISO 8601:
```
2024-01-15T10:30:00Z
2024-12-19T14:45:30Z
2024-03-20T08:00:00Z
```

### البنية:
- `YYYY-MM-DD` - التاريخ (سنة-شهر-يوم)
- `T` - فاصل بين التاريخ والوقت
- `HH:MM:SS` - الوقت (ساعة:دقيقة:ثانية)
- `Z` - يشير إلى UTC timezone

---

## مثال كامل لإضافة Document في adminCodes:

```
Collection: adminCodes
Document ID: (auto-generated أو أدخل ID يدوياً)

Fields:
┌─────────────────┬──────────┬─────────────────────────────┐
│ Field name      │ Type     │ Value                       │
├─────────────────┼──────────┼─────────────────────────────┤
│ adminCode       │ string   │ ADMIN001                    │
│ name            │ string   │ أدمن الرئيسي               │
│ description     │ string   │ الأدمن الرئيسي للنظام      │
│ createdAt       │ string   │ 2024-01-15T10:30:00Z        │
└─────────────────┴──────────┴─────────────────────────────┘
```

---

## مثال كامل لإضافة Document في codes:

```
Collection: codes
Document ID: (auto-generated أو أدخل ID يدوياً)

Fields:
┌─────────────────┬──────────┬─────────────────────────────┐
│ Field name      │ Type     │ Value                       │
├─────────────────┼──────────┼─────────────────────────────┤
│ code            │ string   │ STU001                      │
│ name            │ string   │ أحمد محمد                   │
│ phone           │ string   │ 01234567890                 │
│ description     │ string   │ طالب في الصف الأول          │
│ adminCode       │ string   │ ADMIN001                    │
│ createdAt       │ string   │ 2024-01-15T10:30:00Z        │
│ subscriptionEnd │ string   │ 2024-02-15T10:30:00Z        │
│ Date            │          │                             │
└─────────────────┴──────────┴─────────────────────────────┘
```

---

## نصائح مهمة:

1. **استخدم التاريخ الحالي:**
   - عند إضافة Document جديد، استخدم التاريخ والوقت الحالي
   - يمكنك نسخ هذا: `2024-12-19T12:00:00Z` وتعديل التاريخ

2. **استخدم Timestamp type:**
   - أسهل طريقة هي استخدام `timestamp` type
   - Firebase سيتعامل مع التحويل تلقائياً

3. **تنسيق موحد:**
   - استخدم نفس التنسيق لجميع Documents
   - يفضل استخدام UTC timezone (Z في النهاية)

4. **للتواريخ المستقبلية:**
   - `subscriptionEndDate` يمكن أن يكون تاريخ مستقبلي
   - مثال: `2025-01-15T10:30:00Z`

---

## كيفية الحصول على التاريخ الحالي بتنسيق ISO 8601:

### من المتصفح (JavaScript):
```javascript
new Date().toISOString()
// النتيجة: "2024-12-19T12:00:00.000Z"
```

### من Terminal (Mac/Linux):
```bash
date -u +"%Y-%m-%dT%H:%M:%SZ"
# النتيجة: 2024-12-19T12:00:00Z
```

### من موقع ويب:
- اذهب إلى [ISO 8601 Date Generator](https://www.iso.org/iso-8601-date-and-time-format.html)
- أو ابحث في Google: "current ISO 8601 date"

---

## ملاحظات مهمة:

1. **إذا نسيت إضافة createdAt:**
   - يمكنك إضافته لاحقاً
   - استخدم تاريخ قريب من تاريخ الإنشاء الفعلي

2. **للبيانات القديمة:**
   - إذا كان لديك بيانات قديمة بدون `createdAt`
   - يمكنك إضافة تاريخ تقريبي
   - أو استخدام تاريخ اليوم إذا لم تكن متأكداً

3. **التحقق من التنسيق:**
   - تأكد من أن التنسيق صحيح
   - يجب أن يحتوي على `T` و `Z`
   - مثال صحيح: `2024-01-15T10:30:00Z`
   - مثال خاطئ: `2024-01-15 10:30:00` (بدون T و Z)

---

## الخلاصة:

- ✅ استخدم `timestamp` type في Firebase Console (أسهل)
- ✅ أو استخدم `string` type مع تنسيق ISO 8601
- ✅ استخدم التاريخ الحالي عند إضافة Document جديد
- ✅ تأكد من التنسيق الصحيح: `YYYY-MM-DDTHH:MM:SSZ`

