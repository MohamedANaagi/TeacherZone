# بنية Firebase Collections - نظام كود الأدمن

## نظرة عامة

تم تحديث النظام ليدعم نظام كود الأدمن، حيث كل كود أدمن له:

- الكورسات الخاصة به
- الأكواد (كودات الطلاب) الخاصة به
- الفيديوهات الخاصة به

## Collections المطلوبة في Firebase

### 1. Collection: `adminCodes` ⭐ جديد

مجموعة أكواد الأدمن (منفصلة)

#### Fields المطلوبة:

```javascript
{
  "adminCode": "string",    // كود الأدمن (مثل: "ADMIN001") (مطلوب)
  "name": "string",          // اسم الأدمن (مطلوب)
  "description": "string",   // الوصف (اختياري)
  "createdAt": "string"      // تاريخ الإنشاء (ISO 8601) (مطلوب)
}
```

#### مثال:

```javascript
{
  "adminCode": "ADMIN001",
  "name": "أدمن الرئيسي",
  "description": "الأدمن الرئيسي للنظام",
  "createdAt": "2024-01-01T00:00:00Z"
}
```

**⚠️ مهم جداً:**

- هذا Collection يجب إنشاؤه وإضافة أكواد الأدمن فيه من Firebase Console فقط
- لا يمكن إضافة أكواد الأدمن من التطبيق
- عند تسجيل دخول الأدمن بكود، يتم جلب `adminCode` من هذا Collection تلقائياً

---

### 2. Collection: `codes`

مجموعة الأكواد (كودات الطلاب)

#### Fields المطلوبة:

```javascript
{
  "code": "string",              // الكود (مطلوب)
  "name": "string",               // اسم الطالب (مطلوب)
  "phone": "string",             // رقم الهاتف (مطلوب)
  "description": "string",       // الوصف (اختياري)
  "profileImageUrl": "string",   // رابط صورة البروفايل (اختياري)
  "createdAt": "string",         // تاريخ الإنشاء (ISO 8601) (مطلوب)
  "subscriptionEndDate": "string", // تاريخ انتهاء الاشتراك (ISO 8601) (اختياري)
  "deviceId": "string",           // معرف الجهاز (اختياري)
  "adminCode": "string"          // كود الأدمن المرتبط بهذا الكود (مطلوب) ⭐ جديد
}
```

#### مثال:

```javascript
{
  "code": "STU001",
  "name": "أحمد محمد",
  "phone": "01234567890",
  "description": "طالب في الصف الأول",
  "createdAt": "2024-01-15T10:30:00Z",
  "subscriptionEndDate": "2024-02-15T10:30:00Z",
  "adminCode": "ADMIN001"  // ⭐ يجب إضافته
}
```

---

### 3. Collection: `courses`

مجموعة الكورسات

#### Fields المطلوبة:

```javascript
{
  "title": "string",             // عنوان الكورس (مطلوب)
  "description": "string",       // وصف الكورس (مطلوب)
  "instructor": "string",         // اسم المدرب (مطلوب)
  "duration": "string",           // مدة الكورس (مطلوب)
  "lessonsCount": "number",       // عدد الدروس (افتراضي: 0)
  "createdAt": "string",         // تاريخ الإنشاء (ISO 8601) (مطلوب)
  "adminCode": "string"          // كود الأدمن المرتبط بهذا الكورس (مطلوب) ⭐ جديد
}
```

#### مثال:

```javascript
{
  "title": "كورس الرياضيات",
  "description": "كورس شامل في الرياضيات للمرحلة الثانوية",
  "instructor": "د. محمد علي",
  "duration": "20 ساعة",
  "lessonsCount": 15,
  "createdAt": "2024-01-10T08:00:00Z",
  "adminCode": "ADMIN001"  // ⭐ يجب إضافته
}
```

---

### 4. Collection: `videos`

مجموعة الفيديوهات

#### Fields المطلوبة:

```javascript
{
  "courseId": "string",           // معرف الكورس (مطلوب)
  "title": "string",              // عنوان الفيديو (مطلوب)
  "url": "string",                // رابط الفيديو (مطلوب)
  "description": "string",        // وصف الفيديو (اختياري)
  "duration": "string",           // مدة الفيديو (افتراضي: "00:00")
  "createdAt": "string",          // تاريخ الإنشاء (ISO 8601) (مطلوب)
  "adminCode": "string"           // كود الأدمن المرتبط بهذا الفيديو (مطلوب) ⭐ جديد
}
```

#### مثال:

```javascript
{
  "courseId": "1234567890",
  "title": "الدرس الأول: الجبر",
  "url": "https://example.com/video1.mp4",
  "description": "مقدمة في الجبر",
  "duration": "45:30",
  "createdAt": "2024-01-12T09:00:00Z",
  "adminCode": "ADMIN001"  // ⭐ يجب إضافته
}
```

---

## كيفية إضافة كود الأدمن

### ⚠️ مهم جداً:

**كود الأدمن يجب إضافته من Firebase Console فقط (Firestore)** - لا يمكن إضافته من التطبيق.

### خطوات إضافة كود الأدمن:

1. **افتح Firebase Console**
2. **اذهب إلى Firestore Database**
3. **أنشئ Collection جديد اسمه: `adminCodes`** (إذا لم يكن موجوداً)
4. **أضف Document جديد في Collection `adminCodes`**
5. **أضف Fields التالية:**
   - `adminCode`: قيمة كود الأدمن (مثال: "ADMIN001")
   - `name`: اسم الأدمن (مثال: "أدمن الرئيسي")
   - `description`: وصف اختياري
   - `createdAt`: تاريخ الإنشاء (ISO 8601)

### مثال:

```
Collection: adminCodes
Document ID: auto-generated
Fields:
  - adminCode: "ADMIN001"  ⭐ هذا هو كود الأدمن
  - name: "أدمن الرئيسي"
  - description: "الأدمن الرئيسي للنظام"
  - createdAt: "2024-01-01T00:00:00Z"
```

### خطوات ربط كود طالب بكود الأدمن:

1. **في Collection `codes`، أضف أو عدّل Document الكود**
2. **أضف Field: `adminCode`**
3. **أدخل قيمة كود الأدمن من Collection `adminCodes`** (مثال: "ADMIN001")

---

## كيفية ربط البيانات بكود الأدمن

### 1. عند تسجيل دخول الأدمن:

- ✅ الأدمن يدخل `adminCode` مباشرة من Collection `adminCodes`
- ✅ يتم البحث عن `adminCode` في Collection `adminCodes`
- ✅ يتم حفظ `adminCode` في `UserCubit` لاستخدامه لاحقاً
- ✅ **لا حاجة لـ Document في `codes` لتسجيل دخول الأدمن**

### 2. عند إضافة كود طالب جديد:

- يتم الحصول على `adminCode` تلقائياً من `UserCubit` (المسجل عند تسجيل الدخول)
- يتم ربط الكود الجديد بـ `adminCode` تلقائياً

### 3. عند إضافة كورس جديد:

- يتم الحصول على `adminCode` تلقائياً من `UserCubit` (المسجل عند تسجيل الدخول)
- يتم ربط الكورس الجديد بـ `adminCode` تلقائياً

### 4. عند إضافة فيديو جديد:

- يتم الحصول على `adminCode` تلقائياً من `UserCubit` (المسجل عند تسجيل الدخول)
- يتم ربط الفيديو الجديد بـ `adminCode` تلقائياً

---

## كيفية عمل التصفية (Filtering)

### عند جلب البيانات:

1. **جلب الكورسات**: يتم تصفية الكورسات حسب `adminCode` من كود المستخدم المسجل
2. **جلب الأكواد**: يتم تصفية الأكواد حسب `adminCode` من كود الأدمن المسجل
3. **جلب الفيديوهات**: يتم تصفية الفيديوهات حسب `adminCode` من كود المستخدم المسجل

### مثال على Query:

```javascript
// جلب الكورسات الخاصة بكود الأدمن "ADMIN001"
db.collection("courses").where("adminCode", "==", "ADMIN001").get();
```

---

## Firestore Rules الموصى بها

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // Rules لأكواد الأدمن
    match /adminCodes/{adminCodeId} {
      allow read: if request.auth != null;
      allow write: if false; // ⚠️ لا يمكن الكتابة من التطبيق - فقط من Firebase Console
    }

    // Rules للأكواد
    match /codes/{codeId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null &&
                    request.resource.data.adminCode is string &&
                    request.resource.data.adminCode.size() > 0;
    }

    // Rules للكورسات
    match /courses/{courseId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null &&
                    request.resource.data.adminCode is string &&
                    request.resource.data.adminCode.size() > 0;
    }

    // Rules للفيديوهات
    match /videos/{videoId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null &&
                    request.resource.data.adminCode is string &&
                    request.resource.data.adminCode.size() > 0;
    }
  }
}
```

---

## ملاحظات مهمة

1. **كود الأدمن إجباري**: جميع الأكواد والكورسات والفيديوهات يجب أن تحتوي على `adminCode`
2. **إضافة من Firestore فقط**: كود الأدمن يجب إضافته من Firebase Console فقط
3. **التوافق مع البيانات القديمة**: البيانات القديمة التي لا تحتوي على `adminCode` قد لا تظهر بشكل صحيح
4. **الترحيل (Migration)**: إذا كان لديك بيانات قديمة، يجب إضافة `adminCode` لها يدوياً من Firebase Console

---

## مثال كامل على البيانات

### كود الأدمن في Collection `adminCodes`:

```javascript
// Document في collection "adminCodes"
{
  "id": "admin_doc_1",
  "adminCode": "ADMIN001",  // ⭐ كود الأدمن
  "name": "أدمن الرئيسي",
  "description": "الأدمن الرئيسي للنظام",
  "createdAt": "2024-01-01T00:00:00Z"
}
```

### كود الأدمن في Collection `codes` (للتسجيل):

```javascript
// Document في collection "codes" - يستخدمه الأدمن لتسجيل الدخول
{
  "id": "admin_login_doc_1",
  "code": "ADMIN001",  // الكود المستخدم لتسجيل الدخول
  "name": "أدمن الرئيسي",
  "phone": "01234567890",
  "adminCode": "ADMIN001",  // ⭐ مرتبط بكود الأدمن من collection adminCodes
  "createdAt": "2024-01-01T00:00:00Z"
}
```

### كود طالب مرتبط بكود الأدمن:

```javascript
// Document في collection "codes"
{
  "id": "student_doc_1",
  "code": "STU001",
  "name": "أحمد محمد",
  "phone": "01111111111",
  "adminCode": "ADMIN001",  // ⭐ مرتبط بكود الأدمن
  "createdAt": "2024-01-15T10:30:00Z"
}
```

### كورس مرتبط بكود الأدمن:

```javascript
// Document في collection "courses"
{
  "id": "course_doc_1",
  "title": "كورس الرياضيات",
  "description": "كورس شامل",
  "instructor": "د. محمد",
  "duration": "20 ساعة",
  "lessonsCount": 15,
  "adminCode": "ADMIN001",  // ⭐ مرتبط بكود الأدمن
  "createdAt": "2024-01-10T08:00:00Z"
}
```

### فيديو مرتبط بكود الأدمن:

```javascript
// Document في collection "videos"
{
  "id": "video_doc_1",
  "courseId": "course_doc_1",
  "title": "الدرس الأول",
  "url": "https://example.com/video1.mp4",
  "adminCode": "ADMIN001",  // ⭐ مرتبط بكود الأدمن
  "createdAt": "2024-01-12T09:00:00Z"
}
```

---

## الخلاصة

- ✅ Collection `adminCodes` منفصل تماماً عن `codes`
- ✅ كود الأدمن يتم إضافته في Collection `adminCodes` من Firebase Console فقط
- ✅ عند تسجيل دخول الأدمن، يتم جلب `adminCode` من `adminCodes` وحفظه في `UserCubit`
- ✅ كل كود أدمن له كورساته الخاصة
- ✅ كل كود أدمن له أكواده (كودات الطلاب) الخاصة
- ✅ كل كود أدمن له فيديوهاته الخاصة
- ✅ جميع البيانات مرتبطة بكود الأدمن عبر Field `adminCode`
- ✅ عند إضافة كورس/كود/فيديو، يتم استخدام `adminCode` من `UserCubit` تلقائياً
